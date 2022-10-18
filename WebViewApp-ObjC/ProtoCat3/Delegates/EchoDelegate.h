//
//  EchoClientDelegate.h
//  ProtoCat3
//
//  Created by Alexis Koopmann on 10/4/22.
//
//  Copyright © 2022 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const NSNotificationName kServerResponseNotification;

@interface EchoDelegate : NSObject<NSStreamDelegate>

-(void) initializeEchoDelegate;
-(void) setupNetworkConnection;
-(NSString *) getServerResponse;
-(NSString *) getConnectionStatus;
-(void) inputStreamEvent:(NSStream *)stream event:(NSStreamEvent)eventCode;
-(void) outputStreamEvent:(NSStream *)stream event:(NSStreamEvent)eventCode;
-(void) sendMessage:(NSData *)sendData;
-(void)resetConnectionSettings: (NSString*) _hostname port: (int) _port;

@end

