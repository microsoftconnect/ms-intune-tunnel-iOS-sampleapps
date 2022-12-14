//
//  MicrosoftTunnelLogDelegate.m
//  ObjCSample
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//
#import <Foundation/Foundation.h>
#import <pthread.h>
#import "MicrosoftTunnelLogDelegate.h"


@implementation MicrosoftTunnelLogDelegate

static MicrosoftTunnelLogDelegate *sm_logDelegate = NULL;

+ (instancetype)logDelegate
{
    if (NULL == sm_logDelegate)
    {
        sm_logDelegate = [MicrosoftTunnelLogDelegate new];
    }
    return sm_logDelegate;
}

- (void)logMessage:(unsigned)level
          logClass:(unsigned)logClass
             pTime:(const char*)pTime
            pLevel:(const char*)pLevel
       pClassLabel:(const char*)pClassLabel
              pLog:(const char*)pLog
{
    NSLog(@"%s [%s] [%d] %s\n", pLevel, pClassLabel, pthread_mach_thread_np(pthread_self()), pLog);
}

@end
