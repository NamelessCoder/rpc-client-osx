//
//  SelectField.swift
//  TYPO3RPC
//
//  Created by Claus Due on 08/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class SelectField: NSComboBox, DynamicComponent {
    
    var spaceAfter: Int = 24
    
    var maximumHeight: Int = 50
    
    var minimumHeight: Int = 12
    
    var rendersOwnLabel: Bool = false
    
    var attribute: String = "attribute"
    
    var type: DynamicComponentType = DynamicComponentType.TextField
    
    let warningColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))!
    
    var value: AnyObject {
        get {
            return self.selectedCell()!.stringValue
        }
        set {
            let stringValue = newValue as! String
            if (self.error != nil) {
                self.attributedStringValue = NSAttributedString(string: stringValue, attributes: [NSForegroundColorAttributeName: self.warningColor])
            } else {
                self.stringValue = stringValue
            }

            if (stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                self.selectItemWithObjectValue(stringValue)
            } else if (!self.options!.isEmpty) {
                self.selectItemWithObjectValue(stringValue)
            }
        }
    }
    
    var errorMessage: String?
    
    var error: String? {
        get {
            return self.errorMessage
        }
        set {
            self.errorMessage = newValue
            self.textColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))
            self.backgroundColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 0.3))
        }
    }
    
    var options: [String]?
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            
            if let componentOptions = newValue["options"] as? [String] {
                self.options = componentOptions
                for option in self.options! {
                    self.addItemWithObjectValue(option)
                }
            }
            self.processDefaultJsonDataParameters(newValue)
        }
    }
    
    func initializeProperties() {
        if (self.error != nil) {
            self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: [NSForegroundColorAttributeName: self.warningColor])
        }
    }
    
    func noop() {
        
    }
    
}
