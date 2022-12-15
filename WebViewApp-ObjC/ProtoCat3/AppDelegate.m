//
//  AppDelegate.m
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#import "AppDelegate.h"

#import "MobileAccessDelegate.h"
#import "IntuneDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [IntuneDelegate.sharedDelegate launchEnrollment];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [IntuneDelegate handleMSALResponse:url
                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];

}

@end
