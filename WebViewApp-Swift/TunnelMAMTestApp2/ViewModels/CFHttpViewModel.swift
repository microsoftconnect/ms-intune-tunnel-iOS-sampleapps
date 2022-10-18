//
//  CFHttpViewModel.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 8/15/22.
//

import Foundation
import UIKit

class CFHttpViewModel : NSObject, IHttpClientViewModel, StreamDelegate {
    @Published var data: String? = nil
    @Published var error: String? = nil
    
    var url: String?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    lazy var dataBuffer: NSMutableData = NSMutableData()
    
    func makeCall(url: String) {
        data = nil
        error = nil
        self.url = url;
        let website = URL(string: url)
        guard let website = website else {
            self.error = "\(url) is not a valid URL"
            NSLog(self.error!)
            return
        }
        
        var readStream:Unmanaged<CFReadStream>?
        var writeStream:Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, website.host! as CFString, UInt32(website.port ?? 443), &readStream, &writeStream)

        guard let readStream = readStream else {
            LogError("Couldn't open read stream")
            return
        }
        guard let writeStream = writeStream else {
            LogError("Couldn't open write stream")
            return
        }

        self.dataBuffer = NSMutableData()
        
        let inputStream:InputStream = readStream.takeRetainedValue() as InputStream
        let outputStream:OutputStream = writeStream.takeRetainedValue() as OutputStream
        
        inputStream.delegate = self
        outputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .default)
        outputStream.schedule(in: .current, forMode: .default)
        inputStream.setProperty(StreamSocketSecurityLevel.negotiatedSSL, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        inputStream.open()
        outputStream.open()
        self.inputStream = inputStream;
        self.outputStream = outputStream;
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if (aStream == self.inputStream) {
            inputStreamEvent(eventCode)
        } else if (aStream == self.outputStream) {
            outputStreamEvent(eventCode)
        }
    }
    
    private func inputStreamEvent(_ eventCode: Stream.Event){
        guard let inputStream = self.inputStream else {
            LogError("Input stream is nil")
            return
        }

        switch eventCode {
        case .hasBytesAvailable:
            let size = 1024
            let buf: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            let len = inputStream.read(buf, maxLength: size)
            if len != 0 {
                self.dataBuffer.append(buf, length: len)
            } else {
                NSLog("no buffer")
            }
            let response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, false).takeUnretainedValue()
            
            CFHTTPMessageAppendBytes(response, buf, len)
            let body = CFHTTPMessageCopyBody(response)?.takeUnretainedValue()
            
            self.data = String(data: body as! Data, encoding: .utf8)
            CloseStream(inputStream)
            self.inputStream = nil
        case .errorOccurred:
            self.error = inputStream.streamError?.localizedDescription
            CloseStream(inputStream)
            self.inputStream = nil
        case .endEncountered:
            CloseStream(inputStream)
            self.inputStream = nil
        default:
            NSLog("Unhandled stream event")
        }
    }
    
    private func outputStreamEvent(_ eventCode: Stream.Event){
        guard let outputStream = self.outputStream else {
            LogError("Output stream is nil")
            return
        }
        guard let url = self.url else {
            LogError("Url is nil")
            return
        }
        
        switch eventCode {
        case .hasSpaceAvailable:
            NSLog("making GET call to \(url)");
            
            let bodyString:CFString = "" as CFString
            let myURL:CFURL = CFURLCreateWithString(kCFAllocatorDefault, url as CFString, nil)
            let myRequest:CFHTTPMessage = CFHTTPMessageCreateRequest(kCFAllocatorDefault, "GET" as CFString, myURL, kCFHTTPVersion1_1).takeUnretainedValue()
            let bodyDataExt:CFData = CFStringCreateExternalRepresentation(kCFAllocatorDefault, bodyString, CFStringBuiltInEncodings.UTF8.rawValue, 0)
            CFHTTPMessageSetBody(myRequest, bodyDataExt)
            
            let mySerializedRequest:CFData = CFHTTPMessageCopySerializedMessage(myRequest)!.takeUnretainedValue()
            
            let requestLength = CFDataGetLength(mySerializedRequest)
            guard let requestBuffer = CFDataGetBytePtr(mySerializedRequest) else {
                LogError("Could not get request buffer")
                return
            }
            outputStream.write(requestBuffer, maxLength: requestLength)
            outputStream.close()
            self.outputStream = nil
        case .errorOccurred:
            LogError(outputStream.streamError?.localizedDescription)
            CloseStream(outputStream)
            self.outputStream = nil
        case .endEncountered:
            CloseStream(outputStream)
            self.outputStream = nil
        default:
            NSLog("Unhandled output stream event")
        }
    }
    
    private func LogError(_ message: String?){
        self.error = message
        NSLog(message ?? "Undefined error")
    }
    
    private func CloseStream(_ stream: Stream?){
        stream?.close()
        stream?.remove(from: .current, forMode: .default)
    }
}

