//
//  MobileAccessLogDelegate.h
//  ProtoCat3
//
//  Copyright © 2021 Blue Cedar Networks. All rights reserved.
//  Licensed to Microsoft under Contract #7267038.
//

#ifndef MobileAccessLogDelegate_h
#define MobileAccessLogDelegate_h

#import <Foundation/Foundation.h>
#import <MobileAccessApi/MobileAccess.h>

@interface MobileAccessLogDelegate : NSObject <MobileAccessLogDelegate>

+ (instancetype)logDelegate;
- (void)logMessage:(unsigned)level
          logClass:(unsigned)logClass
             pTime:(const char*)pTime
            pLevel:(const char*)pLevel
       pClassLabel:(const char*)pClassLabel
              pLog:(const char*)pLog;

@end

#endif /* MobileAccessLogDelegate_h */
