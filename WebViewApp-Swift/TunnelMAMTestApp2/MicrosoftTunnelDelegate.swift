//
// Copyright (c) Microsoft Corporation.  All rights reserved.
//

import Foundation
import MicrosoftTunnelApi
import SwiftUI

public protocol ConnectionListener {
    func onConnected() -> Void
    func onReconnecting() -> Void
    func onInitialized() -> Void
    func onDisconnected() -> Void
    func onError(_ error: MobileAccessError) -> Void
}

public class MicrosoftTunnelDelegate: NSObject, MicrosoftTunnelApi.MicrosoftTunnelDelegate {
    
    static var sharedDelegate: MicrosoftTunnelDelegate = {
        let delegate = MicrosoftTunnelDelegate()
        delegate.config.addEntries(from: [
            String.fromUtf8(kLoggingClassMobileAccess): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassConnect): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassInternal): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassHttp): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassPacket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassSocket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassIntune): String.fromUtf8(kLoggingSeverityDebug)
        ])
        delegate.api = MicrosoftTunnelAPI.sharedInstance
        return delegate
    }()
    
    var connectionListeners: Array<ConnectionListener> = []
    let config: NSMutableDictionary = NSMutableDictionary.init()
    var api: MicrosoftTunnelAPI?
    
    func launch(){
        guard let api = api else {
            NSLog("MicrosoftTunnelAPI not initialized");
            return;
        }
        if !api.launchEnrollment()  {
            let error = api.mobileAccessInitialize(with: MicrosoftTunnelDelegate.sharedDelegate, logDelegate: LogDelegate(), config: (self.config as! [String : String]))
            if error != NoError {
                NSLog("Failed to initialize MicrosoftTunnelAPI!")
            }
        }
    }
    
    public func registerConnectionListener(delegate: ConnectionListener) {
        connectionListeners.append(delegate)
    }
    
    public func onInitialized() {
        MicrosoftTunnelDelegate.sharedDelegate.connect()
        connectionListeners.forEach {
            $0.onInitialized()
        }
    }
    
    public func onConnected() {
        connectionListeners.forEach {
            $0.onConnected()
        }
    }
    
    public func onReconnecting() {
        connectionListeners.forEach {
            $0.onReconnecting()
        }
    }
    
    public func onUserInteractionRequired() {
        // implement later
    }
    
    public func onDisconnected() {
        connectionListeners.forEach {
            $0.onDisconnected()
        }
    }
    
    public func onError(_ error: MobileAccessError) {
        connectionListeners.forEach {
            $0.onError(error)
        }
    }

    func connect() {
        MicrosoftTunnelAPI.sharedInstance.connect()
    }
    
    func disconnect() {
        MicrosoftTunnelAPI.sharedInstance.disconnect()
    }
    
    func getStatus() -> MobileAccessStatus{
        return MicrosoftTunnelAPI.sharedInstance.getStatus()
    }
    
    func getStatusString() -> String {
        return MicrosoftTunnelAPI.sharedInstance.getStatusString()
    }
    
    public func onReceivedEvent(_ event: MobileAccessStatus) {
        // do nothing yet.
    }
}
