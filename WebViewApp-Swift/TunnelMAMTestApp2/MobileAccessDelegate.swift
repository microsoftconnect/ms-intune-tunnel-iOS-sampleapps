//
// Copyright (c) Microsoft Corporation.  All rights reserved.
//

import Foundation
import MobileAccessApi
import SwiftUI

public protocol ConnectionListener {
    func onConnected() -> Void
    func onReconnecting() -> Void
    func onInitialized() -> Void
    func onDisconnected() -> Void
    func onError(_ error: MobileAccessError) -> Void
}

public class MobileAccessDelegate: NSObject, MobileAccessApi.MobileAccessDelegate {
    
    static var sharedDelegate: MobileAccessDelegate = {
        let delegate = MobileAccessDelegate()
        delegate.config.addEntries(from: [
            String.fromUtf8(kLoggingClassMobileAccess): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassConnect): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassInternal): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassHttp): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassPacket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassSocket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassIntune): String.fromUtf8(kLoggingSeverityDebug)
        ])
        return delegate
    }()
    
    var connectionListeners: Array<ConnectionListener> = []
    let config: NSMutableDictionary = NSMutableDictionary.init()
    var api: MobileAccessAPI?
    
    func setVpnConfiguration(vpnConfig: Dictionary<String, Any>) {
        self.config.addEntries(from: vpnConfig)
    }
    
    func configureSDK(){
        self.api = MobileAccessAPI.sharedInstance
        let error = MobileAccessDelegate.sharedDelegate.api?.mobileAccessInitialize(with: MobileAccessDelegate.sharedDelegate, logDelegate: LogDelegate(), config: (self.config as! [String : String]))
        if error != NoError {
            NSLog("Failed to initialize MobileAccessAPI!")
        }
    }
    
    public func registerConnectionListener(delegate: ConnectionListener) {
        connectionListeners.append(delegate)
    }
    
    public func onTokenRequired(callback tokenCallback: TokenRequestCallback!, withFailedToken failedToken: String!) {
        IntuneDelegate.sharedDelegate.onTokenRequiredWithCallback(tokenCallback: tokenCallback, failedToken: "")
    }
    
    public func onInitialized() {
        MobileAccessDelegate.sharedDelegate.connect()
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
        MobileAccessAPI.sharedInstance.connect()
    }
    
    func disconnect() {
        MobileAccessAPI.sharedInstance.disconnect()
    }
    
    func getStatus() -> MobileAccessStatus{
        return MobileAccessAPI.sharedInstance.getStatus()
    }
    
    func getStatusString() -> String {
        return MobileAccessAPI.sharedInstance.getStatusString()
    }
    
    public func onReceivedEvent(_ event: MobileAccessStatus) {
        // do nothing yet.
    }
}
