//
//  CFHttpViewController.m
//  ObjCSample
//
//  Created by Alexis Koopmann on 10/14/22.
//

#import "CFHttpViewController.h"
#import "Constants.h"

@implementation CFHttpViewController {
@public
    NSString *data;
    NSString *error;
@private
    NSString *url;
    NSInputStream *input;
    NSOutputStream *output;
    NSMutableArray *dataBuffer;
    int max_len;
}

- (void) viewDidLoad {
    // Setup
    data = nil;
    error = nil;
    dataBuffer = [NSMutableArray new];
    max_len = 1024;
}

- (IBAction)UntrustedHandler:(id)sender {
    NSLog(@"Making untrusted call. \n");
    [self makeCall:untrustedPage];
}

- (IBAction)TrustedHandler:(id)sender {
    NSLog(@"Making trusted call. \n");
    [self makeCall:trustedPage];
}

-(void)makeCall: (NSString*) url {
    CFReadStreamRef read_stream;
    CFWriteStreamRef write_stream;
    self.trusted_button.enabled = false;
    self.untrusted_button.enabled = false;
    // Socket setup
    self->url = url;
    NSURL *temp_url = [NSURL URLWithString:url];
    int port = (int)[temp_url.port integerValue] ? : 443;
    NSLog(@"Hostname: %@ Port: %i \n", temp_url.host, port);
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef _Null_unspecified)(temp_url.host), port, &read_stream, &write_stream);
    input=(__bridge NSInputStream *)(read_stream);
    output=(__bridge NSOutputStream *)(write_stream);
    [input setDelegate:self];
    [output setDelegate:self];
    [input setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    [output open];
}

-(void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    if (stream == input){
        [self inputStreamEvent:stream event:eventCode];
    } else if (stream == output) {
        [self outputStreamEvent:stream event:eventCode];
    }
}

-(void) inputStreamEvent:(NSStream *)stream event:(NSStreamEvent)eventCode {
    if (input == nil){
        NSLog(@"Input stream is nil.");
        self.trusted_button.enabled = true;
        self.untrusted_button.enabled = true;
        return;
    }
    switch(eventCode){
        case NSStreamEventHasBytesAvailable: {
            uint8_t buff[max_len];
            NSInteger message_len=0;
            message_len = [input read:buff maxLength:sizeof(buff)];
            if (message_len < 0) {
                NSError *err = stream.streamError;
                NSLog(@"Read stream error occured %li: %@.", (long) err.code, err.localizedDescription);
                return;
            }
            if (message_len > 0) { // Reconstruct message when length is more than 0
                CFHTTPMessageRef response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, false);
                CFHTTPMessageAppendBytes(response, buff, message_len);
                CFDataRef body = CFHTTPMessageCopyBody(response);
                NSData *ns_body = (__bridge NSData *)body;
                
                NSString *responseString = [[NSString alloc] initWithData:ns_body encoding:kCFStringEncodingUTF8];
                NSLog(@"Reading CFHTTP response string %@.", responseString);
                [self closeStream:input];
            }
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"Input Stream opened.");
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *err = stream.streamError;
            NSLog(@"Input stream error occured %li: %@.", (long)err.code, err.localizedDescription);
            [self.response_data setText: [[NSString alloc] initWithFormat:@"An error occured %@", err.localizedDescription]];
            [self closeStream:input];
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog(@"Input stream end.");
            [self closeStream:input];
            break;
        }
        default: {
            NSLog(@"Unknown event occured!");
        }
    }
}

-(void) outputStreamEvent:(NSStream *)stream event:(NSStreamEvent)eventCode {
    if (output == nil){
        NSLog(@"Output stream is nil.");
        self.trusted_button.enabled = true;
        self.untrusted_button.enabled = true;
        return;
    }
    switch(eventCode){
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"making GET call to %@", url);
            CFStringRef bodyString = (CFStringRef)@"";
            CFURLRef url_ref = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)url, nil);
            CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)@"GET", url_ref, kCFHTTPVersion1_1);
            CFDataRef bodyData = CFStringCreateExternalRepresentation(kCFAllocatorDefault, bodyString, kCFStringEncodingUTF8, 0);
            CFHTTPMessageSetBody(request, bodyData);
            // Time to serializee
            CFDataRef serializedRequest = CFHTTPMessageCopySerializedMessage(request);
            uint8_t *outgoing_bytes = (uint8_t*) CFDataGetBytePtr(serializedRequest);
            if (outgoing_bytes == nil) {
                NSLog(@"Error getting request buffer, nil buffer.");
                return;
            }
            CFIndex requestLength = CFDataGetLength(serializedRequest);
            // Write message to stream
            [output write:outgoing_bytes maxLength:requestLength];
            [self closeStream:output];
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"Output stream opened.");
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *err = stream.streamError;
            NSLog(@"Output stream error occured %li: %@.", (long) err.code, err.localizedDescription);
            [self.response_data setText: [[NSString alloc] initWithFormat:@"An error occured %@", err.localizedDescription]];
            [self closeStream:output];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self closeStream:output];
            NSLog(@"Output stream end.");
            break;
        }
        default: {
            NSLog(@"Unknown event occured!");
        }
    }
}

-(void)closeStream:(NSStream *)stream {
    [stream close];
    stream = nil;
    self.trusted_button.enabled = true;
    self.untrusted_button.enabled = true;
}
    
@end
