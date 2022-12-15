//
//  StringExtensions.swift
//  SampleApplication
//
//  Created by Todd Bohman on 8/2/22.
//

import Foundation

extension String {
    func hasPrefix(_ string: String, _ options: String.CompareOptions = []) -> Bool {
        return range(of: string, options: options.union(.anchored)) != nil
    }
    
    func matchesRegex(_ string: String) -> Bool {
        return range(of: string, options: .regularExpression) != nil
    }
    
    static func fromUtf8(_ string: UnsafePointer<CChar>!) -> String {
        let value = String.init(utf8String: string)
        guard let value = value else {
            NSLog("Cannot parse string from UTF8")
            return ""
        }
        
        return value
    }
}
