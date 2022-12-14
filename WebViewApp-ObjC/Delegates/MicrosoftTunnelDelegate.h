//
//  MicrosoftTunnelDelegate.h
//  ObjCSample
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#ifndef MicrosoftTunnelDelegate_h
#define MicrosoftTunnelDelegate_h

#import <Foundation/Foundation.h>
#import <MicrosoftTunnelApi/MicrosoftTunnel.h>

extern const NSNotificationName kMobileAccessStatusUpdatedNotificationName;

@interface MicrosoftTunnelDelegate : NSObject <MicrosoftTunnelDelegate>
@property(nonatomic, strong) MicrosoftTunnelAPI *m_api;
@property(nonatomic, strong) NSMutableDictionary *config;


+ (instancetype)sharedDelegate;
- (NSString *)getStatusString;
- (NSString *)getVersionString;
- (MobileAccessStatus)getStatus;

- (void)connect;
- (void)configureSDK;
- (void)disconnect;
- (void)onReceivedEvent:(MobileAccessStatus)event;
- (void)setVpnConfiguration:(NSDictionary *)vpnConfig;

@end

#endif /* MicrosoftTunnelDelegate_h */
