//
//  ContentView.swift
//  WebViewApp-Swift
//
//  Created by Todd Bohman on 8/1/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WebViewTab()
                .tabItem{
                    Label("Browser", systemImage: "network")
                }
            HttpClientTab(viewModel: NSUrlSessionViewModel())
                .tabItem{
                    Label("UrlSession", systemImage: "curlybraces")
                }
            HttpClientTab(viewModel: CFHttpViewModel())
                .tabItem{
                    Label("CFHTTP", systemImage: "atom")
                }
            TunnelTab()
                .tabItem{
                    Label("Tunnel", systemImage: "lock")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
