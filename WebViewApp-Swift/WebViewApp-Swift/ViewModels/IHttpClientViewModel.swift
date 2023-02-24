//
//  IHttpClientViewModel.swift
//  WebViewApp-Swift
//
//  Created by Todd Bohman on 8/29/22.
//

import Foundation

protocol IHttpClientViewModel : ObservableObject {
    var data: String? { get }
    var error: String? { get }
    
    func makeCall(url: String)
}
