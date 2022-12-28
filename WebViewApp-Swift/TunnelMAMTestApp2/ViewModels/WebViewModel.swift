//
//  WebViewModel.swift
//  SampleApplication
//
//  Created by Todd Bohman on 8/1/22.
//

import Foundation

class WebViewModel : ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var shouldNavigate: Bool = false
    @Published var title: String = ""
    @Published var error: String? = nil
    
    @Published var url: String
    
    init(url: String){
        self.url = url
    }
    
    func normalizeUrl(){
        if !(url.hasPrefix("https://", .caseInsensitive) || url.hasPrefix("http://", .caseInsensitive)) {
            url = "https://\(url)"
        }
    }
}
