//
//  IntuneDelegate.h
//  ObjCSample
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#ifndef IntuneDelegate_h
#define IntuneDelegate_h

#import <IntuneMAMSwift/IntuneMAMSwift.h>

typedef void (^TokenRequestCallback)(NSString* _Nullable accessToken);

@interface IntuneDelegate : NSObject<IntuneMAMEnrollmentDelegate>

+ (instancetype)sharedDelegate;
- (BOOL)launchEnrollment;
- (NSDictionary *)getVpnConfig;
- (void)getAuthToken:(TokenRequestCallback)tokenCallback;
- (void)onTokenRequiredWithCallback:(TokenRequestCallback)tokenCallback withFailedToken:(NSString*)failedToken;
+ (BOOL)handleMSALResponse:(nonnull NSURL *)response sourceApplication:(nullable NSString *)sourceApplication;

@end

#endif /* IntuneDelegate_h */
