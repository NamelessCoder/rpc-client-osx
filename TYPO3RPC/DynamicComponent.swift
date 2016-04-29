//
//  DynamicComponent.swift
//  TYPO3RPC
//
//  Created by Claus Due on 08/05/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

enum DynamicComponentType: String {
    case Unknown
    case TextField
    case TextArea
    case TextLabel
    case SelectField
    case ToggleField
    case PopupField
}

protocol DynamicComponent : class {
    var type: DynamicComponentType { get }
    var attribute: String { get set }
    var spaceAfter: Int { get set }
    var maximumHeight: Int { get set }
    var minimumHeight: Int { get set }
    var value: AnyObject { get set }
    var errorMessage: String? { get set }
    var error: String? { get set }
    var rendersOwnLabel: Bool { get }
    var jsonData: AnyObject { get set }
    func initializeProperties() -> Void
}

extension DynamicComponent {
    
    var error: String? {
        get {
            return self.errorMessage
        }
        set {
            self.errorMessage = newValue
        }
    }
    
    var jsonData: AnyObject {
        get {
            return []
        }
        set {
            self.processDefaultJsonDataParameters(newValue)
        }
    }
    
    func processDefaultJsonDataParameters(jsonData: AnyObject) {
        if let componentError = jsonData["error"] as? String {
            self.error = componentError
        }
        if let fieldName = jsonData["name"] as? String {
            self.attribute = fieldName
        }
        self.value = jsonData["value"] as AnyObject!
    }
    
}

class ComponentFactory {
    
    internal static func createFromType(type: DynamicComponentType) -> DynamicComponent? {
        var component: DynamicComponent?
        switch type {
        case DynamicComponentType.TextLabel: component = TextLabel()
        case DynamicComponentType.TextField: component = TextField()
        case DynamicComponentType.SelectField: component = SelectField()
        case DynamicComponentType.PopupField: component = PopupField()
        case DynamicComponentType.ToggleField: component = ToggleField()
        case DynamicComponentType.TextArea: component = TextArea()
        default: return nil
        }
        return component
    }
    
}
