//
//  NSUrlSessionViewModel.swift
//  WebViewApp-Swift
//
//  Created by Todd Bohman on 8/9/22.
//

import Foundation

class NSUrlSessionViewModel : ObservableObject, IHttpClientViewModel {
    @Published var data: String? = nil
    @Published var error: String? = nil
    
    func makeCall(url: String) {
        data = nil
        error = nil
        let u = URL(string: url)
        guard let u = u else {
            error = "Bad URL"
            return
        }
        URLSession.shared.dataTask(with: u) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    self.data = String(data: data, encoding: .utf8)
                }
                if let error = error {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }
}
