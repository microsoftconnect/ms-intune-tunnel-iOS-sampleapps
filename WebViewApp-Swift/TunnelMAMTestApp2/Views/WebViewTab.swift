//
//  WebViewTab.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 8/29/22.
//

import SwiftUI

struct WebViewTab: View {
    
    @ObservedObject var viewModel = WebViewModel(url: Constants.searchPage)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 0){
                    NavigationBar(webViewModel: viewModel)
                    ZStack {
                        WebViewContainer(webViewModel: viewModel)
                        if let error = viewModel.error {
                            Text("Error: \(viewModel.error ?? "None")")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .safeColor(.white, .red)
                        }
                    }
                    HStack(alignment: .center, spacing: 5) {
                        Button(action: {
                            viewModel.url = Constants.searchPage
                            viewModel.shouldNavigate = true
                        }) {
                            Label("Search", systemImage: "magnifyingglass")
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .safeColor(.white, .blue)
                                .font(.subheadline)
                        }
                        Button(action: {
                            viewModel.url = Constants.untrustedPage
                            viewModel.shouldNavigate = true
                        }) {
                            Label("Untrusted", systemImage: "exclamationmark.triangle")
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .safeColor(.white, .blue)
                                .font(.subheadline)
                        }
                        Button(action: {
                            viewModel.url = Constants.trustedPage
                            viewModel.shouldNavigate = true
                        }) {
                            Label("Trusted", systemImage: "checkmark.shield")
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .safeColor(.white, .blue)
                                .font(.subheadline)
                        }
                    }
                    .ignoresSafeArea()
                    .padding([.top, .bottom], 10)
                    .frame(maxWidth: .infinity)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                viewModel.shouldGoBack.toggle()
            }, label: {
                if viewModel.canGoBack {
                    Image(systemName: "arrow.left")
                        .frame(width: 44, height: 44, alignment: .center).foregroundColor(.white)
                } else {
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .center)
                }
            }))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WebViewTab_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WebViewTab()
            WebViewTab()
                .previewDevice("iPad Pro (9.7-inch)")
        }
    }
}
