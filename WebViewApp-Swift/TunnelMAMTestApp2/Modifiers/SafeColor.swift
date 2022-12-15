//
//  SafeColor.swift
//  TunnelMAMTestApp2
//
//  Created by Todd Bohman on 8/29/22.
//

import Foundation
import SwiftUI

struct SafeColor: ViewModifier {
    let foreground: Color
    let background: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .foregroundColor(foreground)
                .background(background)
        }
        else {
            ZStack{
                background
                content
                    .foregroundColor(foreground)
            }
        }
    }
}

extension View {
    func safeColor(_ foreground: Color, _ background: Color) -> some View {
        return self.modifier(SafeColor(foreground: foreground, background: background))
    }
}
