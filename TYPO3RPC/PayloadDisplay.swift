//
//  PayloadDisplay.swift
//  TYPO3RPC
//
//  Created by Claus Due on 18/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class PayloadDisplay: NSTableView, NSTableViewDataSource {
    
    var data: AnyObject!
    
    var keys: [String]!
    
    var payload: AnyObject! {
        set {
            for tableColumn in self.tableColumns {
                self.removeTableColumn(tableColumn)
            }
            let valueColumn = NSTableColumn(identifier: "value")
            valueColumn.headerCell.stringValue = "Value"
            
            if let payload = newValue as? [String: AnyObject] {
                let nameLabel = TextLabel()
                nameLabel.value = "Attribute"
                nameLabel.initializeProperties()
                let valueLabel = TextLabel()
                valueLabel.value = "Value"
                valueLabel.initializeProperties()
                
                self.data = payload
                self.keys = Array(payload.keys)
                
                let nameColumn = NSTableColumn(identifier: "name")
                nameColumn.headerCell.stringValue = "Name"
                self.addTableColumn(nameColumn)
                nameColumn.minWidth = 100
                nameColumn.resizingMask = [NSTableColumnResizingOptions.AutoresizingMask]
            } else {
                self.data = newValue
            }

            self.addTableColumn(valueColumn)
            valueColumn.resizingMask = [NSTableColumnResizingOptions.AutoresizingMask]
            self.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable]
            self.autoresizesSubviews = true
            self.headerView!.hidden = false
            valueColumn.sizeToFit()
            self.sizeToFit()
        }
        get {
            return self.data
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard (self.data != nil) else {
            return 0
        }
        if let payloadArray = self.data as? [String: AnyObject] {
            return payloadArray.count
        }
        if let payloadArray = self.data as? [AnyObject] {
            return payloadArray.count
        }
        return 1
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let payloadArray = self.data as? [String: AnyObject] {
            let key = self.keys[row]
            if (tableColumn!.identifier == "name") {
                return key
            } else {
                return payloadArray[key]
            }
        }
        if let payloadArray = self.data as? [AnyObject] {
            return payloadArray[row]
        }
        return self.data
    }
    
}
