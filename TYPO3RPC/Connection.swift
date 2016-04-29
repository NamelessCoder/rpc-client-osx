//
//  ConnectionSetting.swift
//  CmisBrowser
//
//  Created by Claus Due on 27/04/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import CoreData

enum ConnectionAttributes : String {
    case
    hostname = "hostname",
    token = "token",
    endpointUrl = "endpointUrl"
    
    static let getAll = [
        hostname,
        token,
        endpointUrl
    ]
}

@objc(Connection)

class Connection: NSManagedObject {
    
    var endpointUrl: String {
        get {
            return "https://" + self.hostname + "/?type=991"
        }
    }
    
    @NSManaged var hostname: String
    
    @NSManaged var token: String
    
}