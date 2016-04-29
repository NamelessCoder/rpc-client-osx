//
//  ActionButton.swift
//  TYPO3RPC
//
//  Created by Claus Due on 30/04/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class ActionButton: NSButton {
    
    var taskId: String!
    
    static func initWithTitle(title: String) -> ActionButton {
        let button = ActionButton()
        button.title = title
        button.bezelStyle = NSBezelStyle.RegularSquareBezelStyle
        return button
    }
    
    static func initWithTitleAndTask(title: String, taskId: String) -> ActionButton {
        let button = self.initWithTitle(title)
        button.taskId = taskId
        button.invalidateIntrinsicContentSize()
        return button
    }
    

}
