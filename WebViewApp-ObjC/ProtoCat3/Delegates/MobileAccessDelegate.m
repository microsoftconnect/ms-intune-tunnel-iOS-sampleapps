//
//  MobileAccessDelegate.m
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <Foundation/Foundation.h>
#import "MobileAccessDelegate.h"
#import "MobileAccessLogDelegate.h"
#import "IntuneDelegate.h"

const NSNotificationName kMobileAccessStatusUpdatedNotificationName = @"MobileAccessStatusUpdatedNotification";

@implementation MobileAccessDelegate

static MobileAccessDelegate *sm_sharedDelegate = NULL;

+ (instancetype)sharedDelegate
{
    if (NULL == sm_sharedDelegate)
    {
        sm_sharedDelegate = [MobileAccessDelegate new];
        sm_sharedDelegate.config = [NSMutableDictionary dictionary];
        [sm_sharedDelegate.config addEntriesFromDictionary: @{
            [NSString stringWithUTF8String:kLoggingClassMobileAccess]: [NSString stringWithUTF8String:kLoggingSeverityDebug],
            [NSString stringWithUTF8String:kLoggingClassConnect]: [NSString stringWithUTF8String:kLoggingSeverityDebug],
            [NSString stringWithUTF8String:kLoggingClassInternal]: [NSString stringWithUTF8String:kLoggingSeverityDebug]
        }];
    }
    return sm_sharedDelegate;
}

- (void)configureSDK
{
    self.m_api = MobileAccessAPI.sharedInstance;
    MobileAccessError err = [sm_sharedDelegate.m_api mobileAccessInitializeWithDelegate:sm_sharedDelegate logDelegate:MobileAccessLogDelegate.logDelegate config:self.config];
    if (NoError != err)
    {
        NSLog(@"Failed to initialize MobileAccessAPI!");
    }
}

- (void)setVpnConfiguration:(NSDictionary *)vpnConfig
{
    const char *kRandom = "Don't fail";
    for (NSString *key in [vpnConfig allKeys]) {
        if ([key isEqualToString:[NSString stringWithUTF8String:kConnectionType]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kConnectionName]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kServerAddress]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kPacUrl]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kProxyAddress]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kProxyPort]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kTrustedCertificates]] ||
            [key isEqualToString:[NSString stringWithUTF8String:kRandom]])
        {
            continue;
        }
        else
        {
            NSLog(@"Unexpected key in vpn config: %@", key);
            return;
        }
    }
    [self.config addEntriesFromDictionary:vpnConfig];
}

- (MobileAccessStatus)getStatus
{
    return [self.m_api getStatus];
}

- (NSString *)getStatusString
{
    return [self.m_api getStatusString];
}

- (NSString *)getVersionString
{
    return [self.m_api getVersionString];
}

- (void)connect
{
    [self.m_api connect];
}

- (void)disconnect
{
    [self.m_api disconnect];
}

- (void)onReceivedEvent:(MobileAccessStatus)event
{
    NSLog(@"%s event: %u", __PRETTY_FUNCTION__, event);

    [NSNotificationCenter.defaultCenter postNotificationName:kMobileAccessStatusUpdatedNotificationName object:nil];
}

- (void)onConnected
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)onDisconnected
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)onError:(MobileAccessError)error
{
    NSLog(@"%s: error: %u", __PRETTY_FUNCTION__, error);
}


- (void)onInitialized
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self connect];
}


- (void)onReconnecting
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)onUserInteractionRequired
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)onTokenRequiredWithCallback:(TokenRequestCallback)tokenCallback withFailedToken:(NSString *)failedToken
{
    [IntuneDelegate.sharedDelegate onTokenRequiredWithCallback:tokenCallback withFailedToken:failedToken];
}



@end
