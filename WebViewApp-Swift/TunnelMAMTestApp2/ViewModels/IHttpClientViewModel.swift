//
//  IHttpClientViewModel.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 8/29/22.
//

import Foundation

protocol IHttpClientViewModel : ObservableObject {
    var data: String? { get }
    var error: String? { get }
    
    func makeCall(url: String)
}
