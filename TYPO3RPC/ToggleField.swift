//
//  ToggleField.swift
//  TYPO3RPC
//
//  Created by Claus Due on 08/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class ToggleField: NSButton, DynamicComponent {
    
    var spaceAfter: Int = 24
    
    var maximumHeight: Int = 50
    
    var minimumHeight: Int = 10
    
    var rendersOwnLabel: Bool = true
    
    var attribute: String = "attribute"
    
    var type: DynamicComponentType = DynamicComponentType.ToggleField
    
    var internalValue: AnyObject? = false

    var originalTitle: String?
    
    let warningColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))!
    
    var value: AnyObject {
        get {
            if (self.isChecked) {
                return self.internalValue!
            } else {
                return false
            }
        }
        set {
            self.internalValue = newValue
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
            //self.bezelStyle = NSBezelStyle.RegularSquareBezelStyle
        }
    }
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            self.processDefaultJsonDataParameters(newValue)
            if let componentLabel = newValue["label"] as? String {
                self.originalTitle = componentLabel
            } else {
                self.originalTitle = "Enable?"
            }
            if let componentChecked = newValue["on"] as? Bool {
                self.isChecked = componentChecked
                if (self.isChecked) {
                    self.setNextState()
                }
            }
        }
    }
    
    var isChecked: Bool = false
    
    func initializeProperties() {
        self.setButtonType(NSButtonType.SwitchButton)
        self.target = self
        self.action = #selector(self.buttonClicked)
        if (self.error != nil) {
            self.attributedTitle = NSAttributedString(string: self.originalTitle!, attributes: [NSForegroundColorAttributeName: self.warningColor])
        } else {
            self.title = self.originalTitle!
        }
    }
    
    func buttonClicked(sender: NSButton) {
        isChecked = !isChecked
    }

}

