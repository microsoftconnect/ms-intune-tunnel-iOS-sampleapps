//
//  MobileAccessDelegate.h
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#ifndef MobileAccessDelegate_h
#define MobileAccessDelegate_h

#import <Foundation/Foundation.h>
#import <MobileAccessApi/MobileAccess.h>

extern const NSNotificationName kMobileAccessStatusUpdatedNotificationName;

@interface MobileAccessDelegate : NSObject <MobileAccessDelegate>
@property(nonatomic, strong) MobileAccessAPI *m_api;
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

#endif /* MobileAccessDelegate_h */
