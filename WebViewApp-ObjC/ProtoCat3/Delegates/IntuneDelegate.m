//
//  IntuneDelegate.m
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import <Foundation/Foundation.h>
#import "IntuneDelegate.h"
#import <MobileAccessApi/MobileAccess.h>
#import "MobileAccessDelegate.h"
#import <MSAL/MSAL.h>

@implementation IntuneDelegate

static IntuneDelegate *sm_sharedDelegate = nil;
+ (instancetype)sharedDelegate
{
    if (nil == sm_sharedDelegate)
    {
        sm_sharedDelegate = [IntuneDelegate new];
    }
    return sm_sharedDelegate;
}

- (BOOL)launchEnrollment {
    [IntuneMAMEnrollmentManager.instance setDelegate:self];
    NSString *enrolledAccount = [IntuneMAMEnrollmentManager.instance enrolledAccount];
    if(enrolledAccount) {
        NSLog(@"Microsoft Intune account \"%@\" is already enrolled. Skipping enrollment.", enrolledAccount);
        
        // If we're already enrolled get the vpn config, set up the SDK, and connect
        NSDictionary *vpnConfig = [self getVpnConfig];
        if (nil != vpnConfig)
        {
            [MobileAccessDelegate.sharedDelegate setVpnConfiguration:vpnConfig];
            [MobileAccessDelegate.sharedDelegate configureSDK];
        }
        else
        {
            NSLog(@"Failed to get vpn config from Intune");
        }
        
        
        return NO;
    } else {
        NSLog(@"No Microsoft Intune account is enrolled. Beginning enrollment.");
        [IntuneMAMEnrollmentManager.instance loginAndEnrollAccount:nil];
        return YES;
    }
}

#pragma mark AppConfig Handling

static void appConfig_warnConflicting(NSString * _Nonnull key, NSObject *value, NSArray *values)
{
    NSLog(@"appConfig has conflicting values for key '%@'. Picked <%@> from values: %@",
                  key, value, values);
}


static NSNumber *appConfig_numberValueForKeyOrDefault(id<IntuneMAMAppConfig> _Nonnull appConfig,
                                                      NSString * _Nonnull key,
                                                      NSNumber * _Nonnull defaultIfValueIsNil)
{
    NSNumber *value = [appConfig numberValueForKey:key queryType:IntuneMAMNumberAny];

    if (value == nil)
    {
        value = defaultIfValueIsNil;
    }

    if ([appConfig hasConflict:key])
    {
        NSArray<NSNumber*> *values = [appConfig allNumbersForKey:key];
        appConfig_warnConflicting(key, value, values);
    }

    return value;
}

static NSString *appConfig_stringValueForKeyOrDefault(id<IntuneMAMAppConfig> _Nonnull appConfig,
                                             NSString * _Nonnull key,
                                             NSString * _Nonnull defaultIfValueIsNil)
{
    NSString *value = [appConfig stringValueForKey:key queryType:IntuneMAMStringAny];

    if (value == nil)
    {
        value = defaultIfValueIsNil;
    }

    if ([appConfig hasConflict:key])
    {
        NSArray<NSString*> *values = [appConfig allStringsForKey:key];
        appConfig_warnConflicting(key, value, values);
    }

    return value;
}

- (NSDictionary *)getVpnConfig
{
    NSString *identity = IntuneMAMEnrollmentManager.instance.enrolledAccount;

    if (identity == nil)
    {
        NSLog(@"Failed to get current user");
        return @{};
    }

    id<IntuneMAMAppConfig> _Nonnull appConfig = [IntuneMAMAppConfigManager.instance appConfigForIdentity:identity];

    if (appConfig == nil)
    {
        // Without a user id, we won't get any per-user MAM configs, but we should still get any per-device MDM configs.
        NSLog(@"Failed to get app config for user '%@'", identity);
    }

    NSLog(@"Got Intune app config for user '%@': %@", identity, appConfig.fullData);

    const char *kRandom = "Don't fail";
    NSString *randomString = @"randomValue";
    NSString *connectionType = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.connection_type", @"");
    NSString *connectionName = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.connection_name", @"");
    NSString *serverAddress = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.server_address", @"");
    NSString *proxyPacUrl = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.proxy_pacurl", @"");
    NSString *proxyAddress = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.proxy_address", @"");
    NSString *trustedCertificates = appConfig_stringValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.trusted_root_certificates", @"");
    NSNumber *proxyPort = appConfig_numberValueForKeyOrDefault(appConfig, @"com.microsoft.tunnel.proxy_port",
                                                               [NSNumber numberWithInt:-1]);
    NSLog(@"Have connection type: %@", connectionType);
    NSLog(@"Have connection name: %@", connectionName);
    NSLog(@"Have server address: %@", serverAddress);
    NSLog(@"Have proxy pac url: %@", proxyPacUrl);
    NSLog(@"Have proxy address: %@", proxyAddress);
    NSLog(@"Have proxy port: %@", proxyPort);
    
    return @{
           [NSString stringWithUTF8String:kConnectionType]: connectionType,
           [NSString stringWithUTF8String:kConnectionName]: connectionName,
           [NSString stringWithUTF8String:kServerAddress]: serverAddress,
           [NSString stringWithUTF8String:kPacUrl]: proxyPacUrl,
           [NSString stringWithUTF8String:kProxyAddress]: proxyAddress,
           [NSString stringWithUTF8String:kProxyPort]: [proxyPort stringValue],
           [NSString stringWithUTF8String:kTrustedCertificates]: trustedCertificates,
           [NSString stringWithUTF8String:kRandom]: randomString
    };
}

#pragma mark OAuth Token handling

+ (UIViewController *)getPresentationViewController
{
    return [self.class topPresentingViewControllerFromWindow:UIApplication.sharedApplication.keyWindow];
}

+ (UIViewController *)topPresentingViewControllerFromWindow:(UIWindow *)window
{
    return [self topPresentingViewControllerFromController:window.rootViewController];
}

+ (UIViewController*)topPresentingViewControllerFromController:(UIViewController *)viewController
{
    while (nil != viewController.presentedViewController)
    {
        if (viewController.presentedViewController.isBeingDismissed)
        {
            return viewController;
        }
        viewController = viewController.presentedViewController;
    }

    return viewController;
}

- (void)onTokenRequiredWithCallback:(TokenRequestCallback) tokenCallback withFailedToken:(NSString*)failedToken
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getAuthToken:tokenCallback];
    });
}

- (void)acquireTokenInteractiveWithCallback:(TokenRequestCallback)tokenCallback application:(MSALPublicClientApplication *)application resource:(NSString *)fixedUpResource
{
    // Needs access to UI-related properties. Must be performed on the main thread.
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopDefaultMode, ^{
        MSALInteractiveTokenParameters *interactive;
        UIViewController *vc = [self.class getPresentationViewController];
        if (!vc)
        {
            NSLog(@"No view controller for Intune authentication");
            tokenCallback(@"");
            return;
        }

        MSALWebviewParameters *params = [[MSALWebviewParameters alloc] initWithAuthPresentationViewController:vc];
        params.webviewType = MSALWebviewTypeWKWebView;
        interactive = [[MSALInteractiveTokenParameters alloc] initWithScopes:@[fixedUpResource] webviewParameters:params];
        interactive.promptType = MSALPromptTypeSelectAccount;

        [application acquireTokenWithParameters:interactive completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
            if (result)
            {
                tokenCallback(result.accessToken);
                return;
            }
            else
            {
                NSLog(@"Failed to get token interactively for gateway auth with error: %@!", error);
                tokenCallback(@"");
                return;
            }
        }];
    });
}

- (void)getAuthToken:(TokenRequestCallback)tokenCallback
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"Info" ofType:@"plist"]];
    NSDictionary *intuneSettings = [dictionary objectForKey:@"IntuneMAMSettings"];
    
    // Use the intuitively-named special tunnel config uuid resource identifier
    NSString *resource = @"3678c9e9-9681-447a-974d-d19f668fcd88/.default";
    NSString *client = intuneSettings[@"ADALClientId"];
    NSString *redirectUri = intuneSettings[@"ADALRedirectUri"];
    NSString *authorityStr = intuneSettings[@"ADALAuthority"];

    NSError *error = nil;
    MSALAuthority *authority = [MSALAuthority authorityWithURL:[NSURL URLWithString:authorityStr] error:&error];
    if (error)
    {
        NSLog(@"Failed to create MSALAuthority: %@", error);
        tokenCallback(@"");
        return;
    }

    MSALPublicClientApplicationConfig *configuration = [[MSALPublicClientApplicationConfig alloc] initWithClientId:client redirectUri:redirectUri authority:authority];
    MSALPublicClientApplication *application = [[MSALPublicClientApplication alloc]
                                                initWithConfiguration:configuration
                                                error:&error];

    if (error)
    {
        NSLog(@"Failed to create MSALPublicClientApplication: %@", error);
        tokenCallback(@"");
        return;
    }
    
    
    MSALParameters *params = [MSALParameters new];
    // Try to pull MSAL account
    [application getCurrentAccountWithParameters:params completionBlock:^(MSALAccount * _Nullable account, MSALAccount * _Nullable previousAccount, NSError * _Nullable error) {
        MSALSilentTokenParameters *silentParameters;
        if (account && !error) {
            silentParameters = [[MSALSilentTokenParameters alloc] initWithScopes:@[resource] account:account];
        }
        
        if (silentParameters) {
            [application acquireTokenSilentWithParameters:silentParameters
                                          completionBlock:^(MSALResult *result, NSError *error)
            {
                if (result)
                {
                    tokenCallback(result.accessToken);
                }
                else
                {
                    // Check the error
                    if ([error.domain isEqual:MSALErrorDomain] && error.code == MSALErrorInteractionRequired)
                    {
                        // Interactive auth will be required
                        NSLog(@"SSO Token auth requires interactive login");
                        [self acquireTokenInteractiveWithCallback:tokenCallback application:application resource:resource];
                    }
                    else
                    {
                        NSLog(@"Failed to get token for gateway auth with error: %@!", error);
                        tokenCallback(@"");
                    }
                }
            }];
        } else {
            // No token can be pulled from cache
            NSLog(@"Failed to find cached token, accquiring new one interactively");
            tokenCallback(@"");
        }
    }];
}

+ (BOOL)handleMSALResponse:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication
{
    return [MSALPublicClientApplication handleMSALResponse:url sourceApplication:sourceApplication];
}

#pragma mark Intune Enrollment Delegate Methods

- (void)enrollmentRequestWithStatus:(IntuneMAMEnrollmentStatus *)status
{
    NSDictionary *vpnConfig = [self getVpnConfig];
    if (nil != vpnConfig)
    {
        [MobileAccessDelegate.sharedDelegate setVpnConfiguration:vpnConfig];
        [MobileAccessDelegate.sharedDelegate configureSDK];
    }
    // MobileAccessApi::Initialize is called during the singleton construction
    NSLog(@"%s - status: %@", __PRETTY_FUNCTION__, status);
}

- (void)policyRequestWithStatus:(IntuneMAMEnrollmentStatus *)status
{
    NSLog(@"%s - status: %@", __PRETTY_FUNCTION__, status);
}

-(void)unenrollRequestWithStatus:(IntuneMAMEnrollmentStatus *)status
{
    NSLog(@"%s - status: %@", __PRETTY_FUNCTION__, status);
}

@end
