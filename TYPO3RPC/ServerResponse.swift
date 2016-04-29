//
//  ServerResponse.swift
//  TYPO3RPC
//
//  Created by Claus Due on 29/04/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import Foundation
import Cocoa

class ServerResponse {
    
    var token: String!
    
    var task: String!
    
    var submitButtonLabel: String = "Submit"
    
    var sheet: [DynamicComponent] = []
    
    var report: Report = Report()
    
    var payload: AnyObject? = nil
    
    var completed: Bool = false
    
    func takeValuesFromJsonData(data: AnyObject) throws {
        if let token = data["token"] as? String {
            self.token = token
        } else {
            throw JSONDecodingErrorType.BadResponse("Server returned a response that does not contain a token - is the server RPC-enabled? Did the server raise an internal error?")
        }
        if let task = data["task"] as? String {
            self.task = task
        }
        
        if let sheet = data["sheet"] as? [String: AnyObject] {
            
            if let submitButtonLabel = sheet["submitButtonLabel"] as? String {
                self.submitButtonLabel = submitButtonLabel
            }
            
            if let fields = sheet["fields"] as? [AnyObject] {
                for field: AnyObject in fields {
                    if let componentType = field["type"] as? String {
                        if let componentType = DynamicComponentType(rawValue: componentType) {
                            if let component = ComponentFactory.createFromType(componentType) as DynamicComponent? {
                                
                                if let componentName = field["name"] as? String {
                                    component.attribute = componentName
                                    
                                    if let componentLabel = field["label"] as? String {
                                        if (!component.rendersOwnLabel) {
                                            let componentLabelComponent = TextLabel()
                                            componentLabelComponent.value = componentLabel as String
                                            componentLabelComponent.spaceAfter = 8
                                            componentLabelComponent.initializeProperties()
                                            self.sheet.append(componentLabelComponent)
                                        }
                                    }
                                    
                                    if let errorMessage = field["error"] as? String {
                                        let errorMessageLabel = TextLabel()
                                        errorMessageLabel.value = errorMessage
                                        errorMessageLabel.textColor = NSColor(CGColor: CGColorCreateGenericRGB(1, 0, 0, 1))
                                        errorMessageLabel.initializeProperties()
                                        self.sheet.append(errorMessageLabel)
                                    }
                                    
                                    component.jsonData = field
                                    component.initializeProperties()
                                    
                                    self.sheet.append(component)
                                } else {
                                    throw JSONDecodingErrorType.Unsupported("Component has no name, please make sure it is assigned one in the server's response")
                                }
                            } else {
                                throw JSONDecodingErrorType.Unsupported("Object type \(componentType) is not supported but the type is known!")
                            }
                        } else {
                            throw JSONDecodingErrorType.Unsupported("Object type \(componentType) is not supported by this client version! Any fields after the invalid one have been dropped.")
                        }
                    } else {
                        throw JSONDecodingErrorType.Unsupported("Cannot decode component type")
                    }
                }
            }
        }
        
        if let completed = data["completed"] as? Bool {
            self.completed = completed
        }

        if let payload = data["payload"] as? [AnyObject] {
            self.payload = payload
        } else if let payload = data["payload"] as? [String: AnyObject] {
            self.payload = payload
        } else if let payload = data["payload"] as? String {
            if (payload.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                self.payload = payload
            }
        } else {
            self.payload = nil
        }
        
        if let report = data["report"] as? [String: AnyObject] {
            if let reportTitle = report["title"] as? String {
                self.report.title = reportTitle
            }
            if let reportContent = report["content"] as? String {
                self.report.content = reportContent
            }
            if let reportSuppressed = report["suppressed"] as? Bool {
                self.report.suppressed = reportSuppressed
            }
            if let reportStep = report["step"] as? Int {
                self.report.step = reportStep
            }
            if let reportSteps = report["steps"] as? Int {
                self.report.steps = reportSteps
            }
        }
        
    }
    
}
