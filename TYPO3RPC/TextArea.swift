//
//  TextArea.swift
//  TYPO3RPC
//
//  Created by Claus Due on 09/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class TextArea: NSScrollView, DynamicComponent {
    
    var spaceAfter: Int = 24
    
    var maximumHeight: Int = 200
    
    var minimumHeight: Int = 40
    
    var rendersOwnLabel: Bool = false
    
    var attribute: String = "attribute"
    
    var type: DynamicComponentType = DynamicComponentType.TextArea
    
    var textView: NSTextView = NSTextView()
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            self.processDefaultJsonDataParameters(newValue)
            if let richtextFlag = newValue["richtext"] as? Bool {
                self.textView.richText = richtextFlag
            }
        }
    }
    
    var value: AnyObject {
        get {
            return (self.textView.string)!
        }
        set {
            if let stringValue = newValue as? String {
                self.textView.string = stringValue
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
            self.textView.textColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))
            self.textView.backgroundColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 0.3))!
        }
    }
    
    func initializeProperties() {
        self.documentView = self.textView
        self.textView.selectable = true
        self.textView.editable = true
        self.textView.verticallyResizable = true
        self.textView.horizontallyResizable = true
        self.borderType = NSBorderType.BezelBorder
        self.autohidesScrollers = true
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = true
    }
    
}
