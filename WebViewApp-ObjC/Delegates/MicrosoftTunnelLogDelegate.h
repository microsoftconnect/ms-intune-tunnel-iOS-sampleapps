//
//  MicrosoftTunnelLogDelegate.h
//  ObjCSample
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#ifndef MicrosoftTunnelLogDelegate_h
#define MicrosoftTunnelLogDelegate_h

#import <Foundation/Foundation.h>
#import <MicrosoftTunnelApi/MicrosoftTunnel.h>

@interface MicrosoftTunnelLogDelegate : NSObject <MicrosoftTunnelLogDelegate>

+ (instancetype)logDelegate;
- (void)logMessage:(unsigned)level
          logClass:(unsigned)logClass
             pTime:(const char*)pTime
            pLevel:(const char*)pLevel
       pClassLabel:(const char*)pClassLabel
              pLog:(const char*)pLog;

@end

#endif /* MicrosoftTunnelLogDelegate_h */
