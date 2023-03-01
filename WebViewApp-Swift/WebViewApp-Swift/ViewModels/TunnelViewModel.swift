//
//  TunnelViewModel.swift
//  WebViewApp-Swift
//
//  Created by Michael Liddle on 9/16/22.
//

import Foundation
import MicrosoftTunnelApi

class TunnelViewModel: ObservableObject, ConnectionListener {
    func onConnected() {
        getStatus()
    }
    
    func onReconnecting() {
        getStatus()
    }
    
    func onInitialized() {
        getStatus()
    }
    
    func onDisconnected() {
        getStatus()
    }
    
    func onError(_ error: MicrosoftTunnelError) {
        getStatus()
    }
    
    @Published var status: TunnelStatus = TunnelStatus(rawValue: MicrosoftTunnelDelegate.sharedDelegate.getStatus().rawValue)!
    @Published var statusString: String = MicrosoftTunnelDelegate.sharedDelegate.getStatusString()
    
    init(){
        MicrosoftTunnelDelegate.sharedDelegate.registerConnectionListener(delegate: self)
    }
    
    func getStatus(){
        statusString = MicrosoftTunnelDelegate.sharedDelegate.getStatusString()
        status = TunnelStatus(rawValue: MicrosoftTunnelDelegate.sharedDelegate.getStatus().rawValue)!
    }
}

enum TunnelStatus : UInt32{
    case uninitialized = 0,
         initialized,
         connected,
         disconnected,
         reconnecting,
         userInteractionRequired,
         errorEncountered
}
