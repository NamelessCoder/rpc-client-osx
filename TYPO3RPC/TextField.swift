//
//  TextField.swift
//  TYPO3RPC
//
//  Created by Claus Due on 30/04/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class TextField: NSTextField, DynamicComponent {
    
    var spaceAfter: Int = 24
    
    var maximumHeight: Int = 100
    
    var minimumHeight: Int = 14
    
    var rendersOwnLabel: Bool = false
    
    var attribute: String = "attribute"
    
    var type: DynamicComponentType = DynamicComponentType.TextField
    
    var errorMessage: String?
    
    var error: String? {
        get {
            return self.errorMessage
        }
        set {
            self.errorMessage = error
            self.toolTip = error
            self.textColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))
            self.backgroundColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 0.3))
        }
    }
    
    var value: AnyObject {
        get {
            return self.stringValue
        }
        set {
            if let stringValue = newValue as? String {
                self.stringValue = stringValue
            }
        }
    }
    
    func initializeProperties() {
        self.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable]
    }
    
}
