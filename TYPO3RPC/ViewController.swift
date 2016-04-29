//
//  ViewController.swift
//  TYPO3RPC
//
//  Created by Claus Due on 29/04/16.
//  Copyright © 2016 Claus Due. All rights reserved.
//

import CoreData
import Cocoa

class ViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSURLConnectionDataDelegate, NSSplitViewDelegate, NSTextFieldDelegate, NSWindowDelegate {
    
    let appDelegate: AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    var connections: [Connection] = []
    
    var connection: Connection!
    
    var addButton: NSButton = NSButton()
    
    var deleteButton: NSButton = NSButton()
    
    var connectButton: NSButton = NSButton()
    
    var hostnameField: TextField = TextField()
    
    var tokenField: TextField = TextField()
    
    var outlineView: NSOutlineView = NSOutlineView()
    
    var mainView: NSStackView = NSStackView()
    
    var scrollView: NSScrollView! = NSScrollView()
    
    var leftScrollView: NSScrollView = NSScrollView()
    
    var leftPanel: NSStackView = NSStackView()
    
    var configurationActionsView: NSStackView = NSStackView()
    
    var progressIndicator: NSProgressIndicator = NSProgressIndicator()
    
    var dataBuffer: NSMutableData = NSMutableData()
    
    var statusView: TextLabel = TextLabel()
    
    var data: [String: AnyObject] = ["data": true]
    
    var fixedWindowSize: NSSize?
    
    var fixedLeftPanelSize: NSSize?
    
    // MARK: Main actions
     @IBAction func submit(sender: ActionButton) {
        self.compileDataFromFields(self.mainView.viewsInGravity(NSStackViewGravity.Center))
        self.call(sender.taskId)
    }
    
    @IBAction func startAction(sender: ActionButton) {
        self.call(sender.taskId)
    }
    
    @IBAction func connectToSelectedConnection(sender: AnyObject?) {
        guard (self.connection != nil) else {
            return
        }
        self.view.window?.title = "TYPO3 RPC Client @ " + self.connection!.hostname
        self.mainView.subviews.removeAll()
        self.call("list")
    }
    
    @IBAction func createNewConnection(sender: AnyObject?) {
        let newObject = NSEntityDescription.insertNewObjectForEntityForName("Connection", inManagedObjectContext: self.appDelegate.managedObjectContext) as! Connection
        newObject.hostname = "localhost"
        self.savePersistedObjects()
        self.appDelegate.saveAction(self)
        self.connections.append(newObject)
        self.outlineView.reloadData()
    }
    
    @IBAction func deleteSelectedConnection(sender: AnyObject?) {
        let selectedRow = self.outlineView.selectedRow
        guard (selectedRow >= 0) else {
            return
        }
        self.outlineView.deselectRow(self.outlineView.selectedRow)
        self.appDelegate.managedObjectContext.deleteObject(self.connections[selectedRow])
        self.appDelegate.saveAction(self)
        self.reloadConnections()
        self.mainView.subviews.removeAll()
        self.deleteButton.hidden = true
        self.presentInitialReport()
    }
    
    
    // MARK: View building functions
    func presentErrorAsReport(error: NSError) -> Void {
        self.mainView.subviews.removeAll()
        let report = Report()
        report.title = error.className
        if let explanation = error.userInfo["explanation"] as? String {
            report.content = explanation
        } else {
            report.content = error.localizedDescription + " (" + String(error.code) + ")"
        }
        self.presentReport(report)
        
        let cancelButton = ActionButton.initWithTitleAndTask("Return to task list", taskId: "list")
        cancelButton.target = self
        cancelButton.action = #selector(self.startAction)
        self.mainView.addView(cancelButton, inGravity: NSStackViewGravity.Center)
    }
    
    func presentReport(report: Report) -> Void {
        if (!report.suppressed) {
            let title = TextLabel()
            title.value = report.title
            title.font = NSFont(name: title.font!.fontName, size: 22)
            title.preferredMaxLayoutWidth = self.mainView.frame.size.width
            title.initializeProperties()
            self.mainView.addView(title, inGravity: NSStackViewGravity.Top)
            if (report.content != nil) {
                let content = TextLabel()
                content.value = report.content
                content.preferredMaxLayoutWidth = self.mainView.frame.size.width
                content.initializeProperties()
                self.mainView.addView(content, inGravity: NSStackViewGravity.Top)
                self.mainView.addConstraint(NSLayoutConstraint (item: content,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.LessThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(content.maximumHeight)))
                self.mainView.addConstraint(NSLayoutConstraint (item: content,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(content.minimumHeight)))
            }
            self.mainView.addConstraint(NSLayoutConstraint (item: title,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.LessThanOrEqual,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: CGFloat(title.maximumHeight)))
            self.mainView.addConstraint(NSLayoutConstraint (item: title,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 32))
        }
        if (report.steps > 1) {
            let progressView = NSProgressIndicator()
            
            self.mainView.addView(progressView, inGravity: NSStackViewGravity.Top)
            progressView.displayedWhenStopped = true
            progressView.indeterminate = false
            progressView.maxValue = CFStringGetDoubleValue(report.steps.description)
            progressView.incrementBy(CFStringGetDoubleValue(report.step.description))
        }
    }
    
    func presentConnectionView() -> Void {
        let report = Report()
        report.title = "Connection details"
        report.content = "Edit or connect to connection. Changes are saved automatically."
        
        let hostnameLabel = TextLabel()
        hostnameLabel.value = "Hostname"
        hostnameLabel.initializeProperties()
        
        let tokenLabel = TextLabel()
        tokenLabel.value = "Authentication token"
        tokenLabel.initializeProperties()
        
        self.hostnameField.value = self.connection!.hostname
        self.hostnameField.delegate = self
        self.hostnameField.initializeProperties()
        
        self.tokenField.value = self.connection!.token
        self.tokenField.delegate = self
        self.tokenField.initializeProperties()
        self.tokenField.hidden = self.connection!.token.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0
        
        self.mainView.subviews.removeAll()
        self.presentReport(report)
        self.mainView.addView(hostnameLabel, inGravity: NSStackViewGravity.Center)
        self.mainView.addView(self.hostnameField, inGravity: NSStackViewGravity.Center)
        self.mainView.addView(tokenLabel, inGravity: NSStackViewGravity.Center)
        
        if (self.connection!.token.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            let tokenNotice = TextLabel()
            tokenNotice.value = "No token has been requested yet. Connect to the server to request a token."
            tokenNotice.textColor = NSColor(CGColor: CGColorCreateGenericRGB(0.5, 0.5, 0, 1))
            tokenNotice.initializeProperties()
            self.mainView.addView(tokenNotice, inGravity: NSStackViewGravity.Center)
        }
        
        self.mainView.addView(self.tokenField, inGravity: NSStackViewGravity.Center)
        self.mainView.addView(self.connectButton, inGravity: NSStackViewGravity.Center)
        
        self.mainView.setCustomSpacing(45, afterView: tokenField)
        
        self.connectButton.title = "Connect to host"
        self.connectButton.action = #selector(self.connectToSelectedConnection)
        self.connectButton.target = self
        self.connectButton.bezelStyle = NSBezelStyle.RegularSquareBezelStyle
        
        self.controlLeftPanelSizes()
    }
    
    func presentFinishReportView(response: ServerResponse) {
        self.mainView.subviews.removeAll()
        self.data.removeAll()
        self.presentReport(response.report)
        
        if (response.payload != nil) {
            let payloadDisplay = PayloadDisplay()
            let scrollForPayload = NSScrollView()
            scrollForPayload.documentView = payloadDisplay
            self.mainView.addView(scrollForPayload, inGravity: NSStackViewGravity.Top)
            payloadDisplay.payload = response.payload
            payloadDisplay.setDataSource(payloadDisplay)
            payloadDisplay.reloadData()
        }
        
        let submitButton = ActionButton.initWithTitleAndTask("Return to task list", taskId: "list")
        submitButton.target = self
        submitButton.action = #selector(self.startAction)
        self.mainView.addView(submitButton, inGravity: NSStackViewGravity.Top)
        
        self.mainView.addView(self.statusView, inGravity: NSStackViewGravity.Bottom)
        self.controlLeftPanelSizes()
    }
    
    func presentAutomaticView(response: ServerResponse) -> Void {
        self.mainView.subviews.removeAll()
        for component in response.sheet {
            if let componentView = component as? NSView {
                self.mainView.addView(componentView, inGravity: NSStackViewGravity.Center)
                let componentHeight = max(component.minimumHeight, Int(componentView.fittingSize.height))
                self.mainView.addConstraint(NSLayoutConstraint (item: componentView,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.LessThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(component.maximumHeight)))
                self.mainView.addConstraint(NSLayoutConstraint (item: componentView,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(componentHeight)))
                self.mainView.setCustomSpacing(CGFloat(component.spaceAfter), afterView: componentView)
            }
        }
        if (response.sheet.count > 0) {
            let submitButton = ActionButton.initWithTitleAndTask(response.submitButtonLabel, taskId: response.task)
            submitButton.target = self
            submitButton.action = #selector(self.submit)
            
            let cancelButton = ActionButton.initWithTitleAndTask("Cancel", taskId: "list")
            cancelButton.target = self
            cancelButton.action = #selector(self.connectToSelectedConnection)
            
            let stackView = NSStackView()
            stackView.distribution = NSStackViewDistribution.GravityAreas
            stackView.alignment = NSLayoutAttribute.Bottom
            
            stackView.addView(submitButton, inGravity: NSStackViewGravity.Top)
            stackView.addView(cancelButton, inGravity: NSStackViewGravity.Bottom)
            self.mainView.addView(stackView, inGravity: NSStackViewGravity.Center)
        }
        self.mainView.addView(self.statusView, inGravity: NSStackViewGravity.Bottom)
        self.presentReport(response.report)
        self.controlLeftPanelSizes()
    }
    
    func presentInitialReport() {
        let initialReport = Report()
        initialReport.title = "TYPO3 RPC Client"
        initialReport.content = "Getting started:\n\n* Create a new connection by clicking the 'plus' icon below to the left\n* Click " +
        "the newly created connection to edit the hostname and connect to the host\n\n"
        initialReport.content.appendContentsOf("For more information you can read the README.md file of the 'rpc' extension.")
        self.presentReport(initialReport)
    }
    
    func presentActions(response: ServerResponse) -> Void {
        self.mainView.subviews.removeAll()
        self.data.removeAll()
        
        if let actions = response.payload as? [String: String] {
            
            self.presentReport(response.report)
            
            for (action, actionDescription) in actions {
                guard (action != "list") else {
                    continue
                }
                let actionButton = ActionButton.initWithTitle(actionDescription)
                actionButton.target = self
                actionButton.taskId = action
                actionButton.action = #selector(self.startAction)
                actionButton.bezelStyle = NSBezelStyle.RegularSquareBezelStyle
                self.mainView.addView(actionButton, inGravity: NSStackViewGravity.Top)
                self.mainView.addConstraint(NSLayoutConstraint (item: actionButton,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: CGFloat(28)))
            }
            
            self.mainView.frame.size.height = CGFloat(actions.count * 40)
            self.scrollView.scrollClipView(self.scrollView.contentView, toPoint: NSPoint(x: 0, y: self.mainView.frame.size.height - self.view.window!.frame.size.height + 22))
        } else {
            fatalError("Cannot read actions from server")
        }
        
        self.mainView.addView(self.statusView, inGravity: NSStackViewGravity.Bottom)
        self.controlLeftPanelSizes()
    }
    
    
    // MARK: Window handling
    func controlLeftPanelSizes() {
        let view = self.view as! NSSplitView
        view.setPosition(self.fixedLeftPanelSize!.width, ofDividerAtIndex: 0)
        self.leftPanel.frame.size = self.fixedLeftPanelSize!
        self.mainView.frame.size.height = max(self.scrollView.frame.size.height - 22, self.fixedWindowSize!.height - 22, self.mainView.frame.size.height)
        self.scrollView.scrollClipView(self.scrollView.contentView, toPoint: NSPoint(x: 0, y: self.mainView.frame.size.height - self.view.window!.frame.size.height + 22))
    }
    
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        if (sender.inLiveResize) {
            self.fixedWindowSize = frameSize
            self.mainView.frame.size.height = max(self.scrollView.frame.size.height - 22, self.fixedWindowSize!.height - 22, self.mainView.frame.size.height)
            self.controlLeftPanelSizes()
        }
        return self.fixedWindowSize!
    }
    
    // MARK: View initialisation and management
    func splitView(splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return view.identifier != "left"
    }
    
    override func viewDidAppear() {
        self.leftPanel.frame.size.width = 200
        self.scrollView.frame.size.width = 600
        self.mainView.frame.size.width = self.scrollView.frame.size.width
        self.mainView.frame.size.height = self.scrollView.frame.size.height - 22
        
        self.fixedLeftPanelSize = self.leftPanel.frame.size
        if let window = self.view.window as NSWindow? {
            window.delegate = self
            window.setContentSize(NSSize(width: 800, height: 578))
            self.fixedWindowSize = window.frame.size
        }
        
        self.controlLeftPanelSizes()
    }
    
    override func viewDidLoad() {
        
        self.view.addSubview(self.leftPanel)
        self.view.addSubview(self.scrollView)
        self.view.autoresizesSubviews = false
        
        self.statusView.value = "Ready to connect"
        self.statusView.initializeProperties()
        self.mainView.addView(self.statusView, inGravity: NSStackViewGravity.Bottom)
        
        self.scrollView.documentView = self.mainView
        self.leftScrollView.documentView = self.outlineView
        
        self.leftPanel.addView(self.configurationActionsView, inGravity: NSStackViewGravity.Bottom)
        self.leftPanel.addView(self.leftScrollView, inGravity: NSStackViewGravity.Top)
        
        self.mainView.addView(self.statusView, inGravity: NSStackViewGravity.Bottom)
        
        self.configurationActionsView.addView(self.addButton, inGravity: NSStackViewGravity.Center)
        self.configurationActionsView.addView(self.deleteButton, inGravity: NSStackViewGravity.Center)
        
        self.configurationActionsView.distribution = NSStackViewDistribution.GravityAreas
        self.configurationActionsView.alignment = NSLayoutAttribute.Bottom
        self.configurationActionsView.autoresizingMask = [NSAutoresizingMaskOptions.ViewNotSizable]
        
        self.leftScrollView.drawsBackground = false
        
        self.leftPanel.orientation = NSUserInterfaceLayoutOrientation.Vertical
        self.leftPanel.autoresizingMask = [NSAutoresizingMaskOptions.ViewNotSizable]
        self.leftPanel.autoresizesSubviews = true
        self.leftPanel.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        self.leftPanel.identifier = "left"
        self.leftPanel.distribution = NSStackViewDistribution.GravityAreas
        
        self.outlineView.setDelegate(self)
        self.outlineView.setDataSource(self)
        self.outlineView.addTableColumn(NSTableColumn(identifier: "Outline"))
        self.outlineView.headerView = nil
        self.outlineView.tableColumns[0].dataCell.textField?!.editable = false
        self.outlineView.backgroundColor = NSColor(white: 1, alpha: 0)
        self.outlineView.focusRingType = NSFocusRingType.None
        self.outlineView.translatesAutoresizingMaskIntoConstraints = false
        self.outlineView.autoresizesOutlineColumn = false
        self.outlineView.autoresizesSubviews = false
        self.outlineView.allowsColumnResizing = false
        self.outlineView.allowsColumnSelection = false
        self.outlineView.allowsColumnReordering = false
        self.outlineView.allowsMultipleSelection = false
        
        self.addButton.image = NSImage(named: NSImageNameAddTemplate)
        self.addButton.action = #selector(self.createNewConnection)
        self.addButton.target = self
        self.addButton.bezelStyle = NSBezelStyle.RecessedBezelStyle
        self.addButton.toolTip = "Add a new host configuration"
        
        self.deleteButton.image = NSImage(named: NSImageNameRemoveTemplate)
        self.deleteButton.action = #selector(self.deleteSelectedConnection)
        self.deleteButton.target = self
        self.deleteButton.bezelStyle = NSBezelStyle.RecessedBezelStyle
        self.deleteButton.toolTip = "Delete selected host configuration"
        self.deleteButton.hidden = true
        
        self.scrollView.identifier = "right"
        self.scrollView.hasVerticalScroller = true
        self.scrollView.autohidesScrollers = true
        self.scrollView.drawsBackground = false
        self.scrollView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable]
        
        self.mainView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable]
        self.mainView.distribution = NSStackViewDistribution.GravityAreas
        self.mainView.orientation = NSUserInterfaceLayoutOrientation.Vertical
        self.mainView.alignment = NSLayoutAttribute.Left
        self.mainView.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 10, right: 20)
        
        self.statusView.textColor = NSColor(CGColor: CGColorCreateGenericGray(0.6, 1))
        
        self.progressIndicator.style = NSProgressIndicatorStyle.SpinningStyle
        self.progressIndicator.indeterminate = true
        self.progressIndicator.startAnimation(self.progressIndicator)
        self.progressIndicator.controlSize = NSControlSize.SmallControlSize
        
        self.reloadConnections()
        
        self.presentInitialReport()
        
        self.view.window?.title = "TYPO3 RPC Client"
    }
    
    // MARK: editing support (via TextField delegation)
    override func controlTextDidEndEditing(obj: NSNotification) {
        self.connection.hostname = self.hostnameField.stringValue
        self.connection.token = self.tokenField.stringValue
        self.appDelegate.saveAction(self)
        self.reloadConnections()
    }
    
    func reloadConnections() {
        do {
            try self.connections = self.getAllConnections()
        } catch {
            fatalError("Unable to create new connection settings! (error)")
        }
        if (self.outlineView.selectedRow >= 0) {
            self.connection = self.connections[self.outlineView.selectedRow]
        }
        self.outlineView.reloadData()
        //self.outlineView.invalidateIntrinsicContentSize()
    }
    
    func getAllConnections() throws -> [Connection] {
        do {
            return try self.appDelegate.managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Connection")) as! [Connection]
        } catch {
            fatalError("Could not fetch stored connections - (error)")
        }
    }
    
    // MARK: OutlineView delegations
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        do {
            return try self.getAllConnections().count
        } catch {
            fatalError("Invalid data set, cannot count item list of stored connections")
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard (self.connections.count > 0) else {
            return false
        }
        return self.connections[index]
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let object = item as? Connection {
            return object.hostname
        }
        return "(unnamed)"
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        guard (self.outlineView.selectedRow < self.connections.count && self.outlineView.selectedRow >= 0) else {
            self.controlLeftPanelSizes()
            return
        }
        if let selectedConnection = self.connections[self.outlineView.selectedRow] as Connection? {
            self.connection = selectedConnection
        }
        self.deleteButton.hidden = false
        self.presentConnectionView()
        self.controlLeftPanelSizes()
    }
    
    
    // MARK: networking support and data collection functions
    func call(taskId: String) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: self.connection.endpointUrl)!)
        let postData: [String: AnyObject] = [
            "token": self.connection.token,
            "task": taskId,
            "arguments": self.data
        ]
        request.HTTPMethod = "POST"
        request.HTTPBody = self.encodeJson(postData)
        self.dataBuffer.setData(NSData())
        NSURLConnection(request: request, delegate: self, startImmediately: true)
        if (self.mainView.views.contains(self.statusView)) {
            self.mainView.removeView(self.statusView)
        }
        self.mainView.addView(self.progressIndicator, inGravity: NSStackViewGravity.Bottom)
        
    }
    
    func compileDataFromFields(fields: [AnyObject]) {
        for field in fields {
            if let component = field as? DynamicComponent {
                guard (component.attribute != "attribute") else {
                    continue
                }
                self.data[component.attribute] = component.value
            }
        }
    }
    
    func savePersistedObjects() {
        do {
            try self.appDelegate.managedObjectContext.save()
        } catch {
            fatalError("Could not save objects to persistence!")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.dataBuffer.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.presentErrorAsReport(error)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        guard let responseString = NSString(data: self.dataBuffer, encoding: NSUTF8StringEncoding) as String? else {
            return
        }
        
        let jsonResponse: ServerResponse = self.decodeJson(responseString as String)
        
        if (self.connection.token.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            self.connection.token = jsonResponse.token as String!
        }
        
        self.statusView.stringValue = "Received " + responseString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding).description +  " bytes from " + self.connection.hostname
        if (jsonResponse.task != nil && jsonResponse.task == "list") {
            // special case: a list of tasks was requested and returned; now we need to display this
            // data (a simple list of possible actions allowed for the token) as buttons which is
            // not a normal/automatic view
            self.presentActions(jsonResponse)
        } else if (jsonResponse.completed) {
            // display the "task completed" view with a return to task list button
            self.presentFinishReportView(jsonResponse)
        } else {
            // display an automatically generated view consisting of components and reports returned
            // in the server response.
            self.presentAutomaticView(jsonResponse)
        }
        self.savePersistedObjects()
    }
    
    
    // MARK: utility functions
    func encodeJson(data: AnyObject) -> NSData {
        do {
            return try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            fatalError("Unable to encode JSON from data - \(error)")
        }
    }
    
    func decodeJson(json: String) -> ServerResponse {
        let response: ServerResponse = ServerResponse()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
            try response.takeValuesFromJsonData(json)
        } catch {
            response.report.title = "Error"
            response.report.content = "Error while decoding JSON \(error)\n\n" + json
            response.completed = true
        }
        return response
    }
    
    
    
}

