//
//  TunnelView.swift
//  TunnelMAMTestApp2
//
//  Created by Michael Liddle on 9/16/22.
//

import SwiftUI
import MobileAccessApi

struct TunnelTab: View {
    
    @ObservedObject var viewModel = TunnelViewModel()
    
    var body: some View {
        VStack{
            Text("Tunnel Status: \(viewModel.status)")
            Spacer()
            if MobileAccessDelegate.sharedDelegate.getStatusString() == "Connected" {
                HStack(alignment: .center, spacing: 5) {
                    Button(action: {
                        MobileAccessDelegate.sharedDelegate.disconnect()
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
                        MobileAccessDelegate.sharedDelegate.connect()
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
