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
    func onError(_ error: MicrosoftTunnelError) -> Void
}

public class MicrosoftTunnelDelegate: NSObject, MicrosoftTunnelApi.MicrosoftTunnelDelegate {
    
    static var sharedDelegate: MicrosoftTunnelDelegate = {
        let delegate = MicrosoftTunnelDelegate()
        delegate.config.addEntries(from: [
            String.fromUtf8(kLoggingClassMicrosoftTunnel): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassConnect): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassInternal): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassHttp): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassPacket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassSocket): String.fromUtf8(kLoggingSeverityDebug),
            String.fromUtf8(kLoggingClassIntune): String.fromUtf8(kLoggingSeverityDebug)
        ])
        delegate.api = MicrosoftTunnel.sharedInstance
        return delegate
    }()
    
    var connectionListeners: Array<ConnectionListener> = []
    let config: NSMutableDictionary = NSMutableDictionary.init()
    var api: MicrosoftTunnel?
    
    func launch(){
        guard let api = api else {
            NSLog("MicrosoftTunnel not initialized");
            return;
        }
        if !api.launchEnrollment()  {
            let error = api.microsoftTunnelInitialize(with: MicrosoftTunnelDelegate.sharedDelegate, logDelegate: LogDelegate(), config: (self.config as! [String : String]))
            if error != NoError {
                NSLog("Failed to initialize MicrosoftTunnel!")
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
    
    public func onError(_ error: MicrosoftTunnelError) {
        connectionListeners.forEach {
            $0.onError(error)
        }
    }

    func connect() {
        MicrosoftTunnel.sharedInstance.connect()
    }
    
    func disconnect() {
        MicrosoftTunnel.sharedInstance.disconnect()
    }
    
    func getStatus() -> MicrosoftTunnelStatus{
        return MicrosoftTunnel.sharedInstance.getStatus()
    }
    
    func getStatusString() -> String {
        return MicrosoftTunnel.sharedInstance.getStatusString()
    }
    
    public func onReceivedEvent(_ event: MicrosoftTunnelStatus) {
        // do nothing yet.
    }
}
