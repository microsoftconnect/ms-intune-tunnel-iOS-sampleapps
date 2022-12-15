//
//  HttpClientTab.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 8/29/22.
//

import SwiftUI

struct HttpClientTab<ViewModel>: View where ViewModel: IHttpClientViewModel {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Data: \(viewModel.data ?? "None")")
            Spacer()
            if !(viewModel.error?.isEmpty ?? true) {
                Text("Error: \(viewModel.error ?? "None")")
                    .padding()
                    .frame(minWidth: .zero, maxWidth: .infinity)
                    .safeColor(.white, .red)
            }
            Divider()
            HStack(alignment: .center) {
                Button(action: {
                    viewModel.makeCall(url: Constants.trustedPage)
                }){
                    Text("Trusted")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .safeColor(.white, .blue)
                }
                Button(action: {
                    viewModel.makeCall(url: Constants.untrustedPage)
                }){
                        Text("Untrusted")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .safeColor(.white, .blue)
                }
            }
            .frame(maxHeight: 55)
        }.padding()
    }
}

struct UrlSessionView_Previews: PreviewProvider {
    static var previews: some View {
        HttpClientTab(viewModel: NSUrlSessionViewModel())
    }
}
