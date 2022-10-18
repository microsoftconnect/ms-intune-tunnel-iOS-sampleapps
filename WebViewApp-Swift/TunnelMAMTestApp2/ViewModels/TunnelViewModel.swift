//
//  TunnelViewModel.swift
//  TunnelMAMTestApp2
//
//  Created by Michael Liddle on 9/16/22.
//

import Foundation
import MobileAccessApi

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
    
    @Published var status: String = MobileAccessDelegate.sharedDelegate.getStatusString()
    
    init(){
        MobileAccessDelegate.sharedDelegate.registerConnectionListener(delegate: self)
    }
    
    func getStatus(){
        status = MobileAccessDelegate.sharedDelegate.getStatusString()
    }
}
