//
//  TunnelViewModel.swift
//  TunnelMAMTestApp2
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
    
    func onError(_ error: MobileAccessError) {
        getStatus()
    }
    
    @Published var status: String = MicrosoftTunnelDelegate.sharedDelegate.getStatusString()
    
    init(){
        MicrosoftTunnelDelegate.sharedDelegate.registerConnectionListener(delegate: self)
    }
    
    func getStatus(){
        status = MicrosoftTunnelDelegate.sharedDelegate.getStatusString()
    }
}
