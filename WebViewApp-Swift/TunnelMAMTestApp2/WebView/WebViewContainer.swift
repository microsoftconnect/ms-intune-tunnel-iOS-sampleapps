//
//  WebViewContainer.swift
//  SampleApplication
//
//  Created by Todd Bohman on 8/1/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebViewContainer : UIViewRepresentable {
    @ObservedObject var webViewModel: WebViewModel
    
    func makeCoordinator() -> WebViewContainer.Coordinator {
        Coordinator(self, webViewModel)
    }
    
    func makeUIView(context: Context) -> some WKWebView {
        guard let url = URL(string: self.webViewModel.url) else {
            return WKWebView()
        }
        
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if webViewModel.shouldGoBack {
            webViewModel.shouldGoBack = false
            uiView.goBack()
        }
        if webViewModel.shouldNavigate {
            webViewModel.shouldNavigate = false
            webViewModel.normalizeUrl()
            var url = URL(string: Constants.searchPage)!
            if(URL(string: webViewModel.url) != nil){
                url = URL(string: webViewModel.url)!
            }
            uiView.load(URLRequest(url: url))
        }
    }
}

extension WebViewContainer {
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject private var webViewModel: WebViewModel
        private let parent: WebViewContainer
        
        init(_ parent: WebViewContainer, _ webViewModel: WebViewModel) {
            self.parent = parent
            self.webViewModel = webViewModel
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webViewModel.isLoading = true
            webViewModel.error = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            updateViewModel(webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            updateViewModel(webView, error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            updateViewModel(webView, error)
        }
        
        private func updateViewModel(_ webView: WKWebView, _ error: Error? = nil){
            webViewModel.isLoading = false
            webViewModel.title = webView.title ?? ""
            webViewModel.canGoBack = webView.canGoBack
            webViewModel.url = webView.url?.absoluteString ?? ""
            if let error = error {
                webViewModel.error = error.localizedDescription
            }
        }
    }
}


