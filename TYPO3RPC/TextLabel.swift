//
//  TextLabel.swift
//  TYPO3RPC
//
//  Created by Claus Due on 02/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class TextLabel: TextField {
    
    override func initializeProperties() {
        self.bezeled = false
        self.drawsBackground = false
        self.editable = false
    }
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            self.processDefaultJsonDataParameters(newValue)
        }
    }
    
}
