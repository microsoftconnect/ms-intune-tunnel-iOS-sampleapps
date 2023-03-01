//
//  HostController.swift
//  WebViewApp-Swift
//
//  Created by Todd Bohman on 8/9/22.
//

import Foundation
import SwiftUI

class HostController : UIHostingController<ContentView> {
    required init?(coder aDecoder: NSCoder){
        super.init(rootView: ContentView())
    }
}
