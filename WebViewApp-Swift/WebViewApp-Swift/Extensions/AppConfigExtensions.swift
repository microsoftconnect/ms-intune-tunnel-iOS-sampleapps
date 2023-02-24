//
//  AppConfigExtensions.swift
//  WebViewApp-Swift
//
//  Created by Todd Bohman on 9/16/22.
//

import Foundation
import IntuneMAMSwift

extension IntuneMAMAppConfig {
    func stringValue(forKey: String, defaultValue: String)  -> String{
        let value = self.stringValue(forKey: forKey, queryType: .any) ?? defaultValue
        
        if hasConflict(forKey) {
            let values = self.allStrings(forKey: forKey)
            NSLog("appConfig has conflicting values for key '\(forKey)'. Picked <\(String(describing: value))> from values: \(String(describing: values))")
        }
        
        return value
    }
    
    func numberValue(forKey: String, defaultValue: NSNumber) -> NSNumber {
        let value = self.numberValue(forKey: forKey, queryType: .any) ?? defaultValue
        
        if hasConflict(forKey) {
            let values = self.allNumbers(forKey: forKey)
            NSLog("appConfig has conflicting values for key '\(forKey)'. Picked <\(String(describing: value))> from values: \(String(describing: values))")
        }
        
        return value
    }
}
