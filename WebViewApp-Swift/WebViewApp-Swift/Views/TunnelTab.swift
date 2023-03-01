//
//  TunnelView.swift
//  WebViewApp-Swift
//
//  Created by Michael Liddle on 9/16/22.
//

import SwiftUI
import MicrosoftTunnelApi

struct TunnelTab: View {
    
    @ObservedObject var viewModel = TunnelViewModel()
    
    var body: some View {
        VStack{
            Text("Tunnel Status: \(viewModel.statusString)")
            Spacer()
            if viewModel.status == .connected {
                HStack(alignment: .center, spacing: 5) {
                    Button(action: {
                        MicrosoftTunnelDelegate.sharedDelegate.disconnect()
                        viewModel.getStatus()
                    }) {
                        Label("Disconnect", systemImage: "lock")
                            .padding(.all, 10).frame(maxWidth: .infinity)
                            .safeColor(.white, .blue)
                            .font(.subheadline)
                    }
                }
                .padding([.top, .bottom], 10)
            } else {
                HStack(alignment: .center, spacing: 5) {
                    Button(action: {
                        MicrosoftTunnelDelegate.sharedDelegate.connect()
                        viewModel.getStatus()
                    }) {
                        Label("Connect", systemImage: "lock")
                            .padding(.all, 10).frame(maxWidth: .infinity)
                            .safeColor(.white, .blue)
                            .font(.subheadline)
                    }
                }
                .padding([.top, .bottom], 10)
            }
        }
        .onAppear(perform: viewModel.getStatus)
    }
    
}

struct TunnelTab_Previews: PreviewProvider {
    static var previews: some View {
        TunnelTab()
    }
}
