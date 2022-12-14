//
//  EchoDelegate.m
//  ObjCSample
//
//  Created by Alexis Koopmann on 10/4/22.
//
//  Copyright © 2022 Microsoft. All rights reserved.
//

#import "EchoDelegate.h"
#import "Constants.h"

@implementation EchoDelegate {
    @public
    NSInputStream *input;
    NSOutputStream *output;
    NSMutableString *serverResponse;
    NSMutableArray *outgoing_buffer;
    @private
    int max_len;
    NSString* hostname;
    int port;
}

const NSNotificationName kServerResponseNotification = @"ServerResponseNotification";

-(void)initializeEchoDelegate{
    max_len= 1024;
    input = [NSInputStream new];
    output = [NSOutputStream new];
    outgoing_buffer = [NSMutableArray new];
    serverResponse = [NSMutableString new];
    hostname = defaultHost;
    port = defaultPort;
}

-(void)resetConnectionSettings: (NSString*) _hostname port: (int) _port {
    hostname = _hostname;
    port = _port;
}

-(void)setupNetworkConnection{
    CFReadStreamRef read_stream;
    CFWriteStreamRef write_stream;
    
    //Create socket pair
    CFStringRef host_ref = (__bridge CFStringRef)hostname;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host_ref, port, &read_stream, &write_stream);
    
    // Grabe refereces
    input=(__bridge NSInputStream *)(read_stream);
    output=(__bridge NSOutputStream *)(write_stream);
    
    // Set delegates to stop ARC deallocation
    [input setDelegate:self];
    [output setDelegate:self];
    
    // Add streams to a run loop
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // Open streams
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
                NSString *buffString = [[NSString alloc] initWithBytes:buff length:message_len encoding:NSUTF8StringEncoding];
                NSLog(@"Reading string %@.", buffString);
                serverResponse = buffString.mutableCopy;
                [NSNotificationCenter.defaultCenter postNotificationName:kServerResponseNotification object:nil];
                [input close];
                input = nil;
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
            [input close];
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog(@"Input stream end.");
            [input close];
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
        return;
    }
    switch(eventCode){
        case NSStreamEventHasSpaceAvailable: {
            NSInteger objectsToWrite = outgoing_buffer.count;
            if (objectsToWrite > 0) {
                NSData *outgoing_data = outgoing_buffer.lastObject;
                uint8_t *outgoing_bytes = (uint8_t*) outgoing_data.bytes;
                // Calculate message length
                NSUInteger out_len = 0;
                if (outgoing_data.length > max_len) {
                    out_len = max_len;
                } else {
                    out_len = outgoing_data.length;
                }
                // Write message to stream
                [output write:outgoing_bytes maxLength:out_len];
                // Clear buffer
                [outgoing_buffer removeLastObject];
                [output close];
            }
            break;
        }
        case NSStreamEventOpenCompleted: {
            NSLog(@"Output stream opened.");
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *err = stream.streamError;
            NSLog(@"Output stream error occured %li: %@.", (long) err.code, err.localizedDescription);
            [output close];
            break;
        }
        case NSStreamEventEndEncountered: {
            [output close];
            NSLog(@"Output stream end.");
            break;
        }
        default: {
            NSLog(@"Unknown event occured!");
        }
    }
}

-(NSString *)getServerResponse {
    return serverResponse;
}

-(NSString *)getConnectionStatus {
    return [[NSString alloc] initWithFormat:@"Recieved from host %@ on port %i", hostname, port];
}

-(void) sendMessage:(NSData *)sendData {
    [self->outgoing_buffer insertObject:sendData atIndex:0];
}

@end
