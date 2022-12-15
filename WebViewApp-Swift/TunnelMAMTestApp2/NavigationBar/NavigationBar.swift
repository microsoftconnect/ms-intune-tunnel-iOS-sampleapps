//
//  NavigationBar.swift
//  SampleApplication
//
//  Created by Todd Bohman on 8/2/22.
//

import SwiftUI

struct NavigationBar: View {
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        ScrollView(.horizontal){
            TextField("", text: $webViewModel.url)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .padding(10)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)){ obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)){ obj in
                    webViewModel.shouldNavigate = true
                }
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NavigationBar(webViewModel: WebViewModel(url:Constants.blankPage))
            Spacer()
        }
    }
}
