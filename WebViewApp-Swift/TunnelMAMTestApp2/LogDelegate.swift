//
// Copyright (c) Microsoft Corporation.  All rights reserved.
//

import Foundation
import MobileAccessApi

public class LogDelegate: NSObject, MobileAccessApi.MobileAccessLogDelegate {
    public func logMessage(_ level: UInt32, logClass: UInt32, pTime: UnsafePointer<CChar>!, pLevel: UnsafePointer<CChar>!, pClassLabel: UnsafePointer<CChar>!, pLog: UnsafePointer<CChar>!) {
        NSLog("%s [%s] [%d] %s\n", pLevel, pClassLabel, pthread_mach_thread_np(pthread_self()), pLog)
    }

}
