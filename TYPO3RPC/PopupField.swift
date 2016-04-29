//
//  PopupField.swift
//  TYPO3RPC
//
//  Created by Claus Due on 08/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class PopupField: NSPopUpButton, DynamicComponent {
    
    var spaceAfter: Int = 24
    
    var maximumHeight: Int = 50
    
    var minimumHeight: Int = 10
    
    var rendersOwnLabel: Bool = false
    
    var attribute: String = "attribute"
    
    var type: DynamicComponentType = DynamicComponentType.PopupField
    
    let warningColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))!
    
    var value: AnyObject {
        get {
            if let stringValue = self.selectedItem!.attributedTitle?.string as String? {
                return stringValue
            }
            return self.titleOfSelectedItem!
        }
        set {
            if let stringValue = newValue as? String {
            
                if (stringValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    self.selectItemWithTitle(stringValue)
                } else if (!self.options!.isEmpty) {
                    self.selectItemWithTitle(self.options!.first as String!)
                }
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
            self.toolTip = newValue
        }
    }
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            if let componentOptions = newValue["options"] as? [String] {
                self.options = componentOptions
                for option in self.options! {
                    self.addItemWithTitle(option)
                }
            }
            self.processDefaultJsonDataParameters(newValue)
            if (self.error != nil) {
                for item in self.itemArray {
                    if (item.title == self.value as! String) {
                        item.attributedTitle = NSAttributedString(string: item.title, attributes: [NSForegroundColorAttributeName: self.warningColor])
                    }
                }
            }
        }
    }
    
    var options: [String]?
    
    func initializeProperties() {
    }
    
    func noop() {
        
    }
}
