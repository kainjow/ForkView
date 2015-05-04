//
//  FVWindowController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/1/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVWindowController: NSWindowController, FVTableViewDelegate, NSTableViewDelegate {
    @IBOutlet weak var resourcesArrayController: NSArrayController!
    @IBOutlet weak var tableView: FVTableView!
    @IBOutlet weak var typeView: NSView!
    @IBOutlet weak var noSelectionView: NSView!
    @IBOutlet weak var noSelectionLabel: NSTextField!
    
    var windowControllers = [NSWindowController]()
    let typeControllers: [FVTypeController] = [
        FVImageTypeController(),
        FVSNDTypeController(),
    ]
    var viewController: NSViewController? = nil
    
    class func windowController() -> Self {
        return self(windowNibName: "FVWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        tableView.customDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowWillCloseNotification, object: self.window, queue: nil) { (note: NSNotification!) in
            for windowController in self.windowControllers {
                windowController.close()
            }
        }
        
        viewSelectedResource()
    }
    
    func tableViewMenuForSelection() -> NSMenu? {
        var menu = NSMenu()
        menu.addItemWithTitle("Export\u{2026}", action:Selector("export"), keyEquivalent:"")
        return menu
    }

    func selectedResource() -> FVResource? {
        return resourcesArrayController.selectedObjects.last as? FVResource
    }
    
    func export() {
        var savePanel = NSSavePanel()
        savePanel.beginSheetModalForWindow(self.window!, completionHandler: { (Int result) in
            if result == NSFileHandlingPanelOKButton {
                self.selectedResource()?.data?.writeToURL(savePanel.URL!, atomically:true)
            }
        })
    }
    
    func openSelectedResource() {
        if let resource = self.selectedResource() {
            openResource(resource)
        }
    }
    
    func controllerForResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
        if let type = resource.type?.typeString {
            for controller in typeControllers {
                if let index = find(controller.supportedTypes(), type) {
                    return controller.viewControllerFromResource(resource, errmsg: &errmsg)
                }
            }
        }
        return nil
    }

    func openResource(resource: FVResource) {
        var errmsg = String()
        let controller = controllerForResource(resource, errmsg: &errmsg)
        if controller == nil {
            return
        }
        
        let view = controller?.view
        let minSize = NSMakeSize(150, 150)
        var winFrame = view!.frame
        
        if NSWidth(winFrame) < minSize.width {
            winFrame.size.width = minSize.width
        }
        if NSHeight(winFrame) < minSize.height {
            winFrame.size.height = minSize.height
        }
        
        let parentWin = self.window
        var parentWinFrame = parentWin!.frameRectForContentRect(parentWin!.contentView.frame)
        parentWinFrame.origin = parentWin!.frame.origin
        
        let styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
        let window = NSWindow(contentRect: winFrame, styleMask: styleMask, backing: .Buffered, defer: true)
        window.releasedWhenClosed = true
        window.contentView = controller!.view
        window.minSize = minSize
        
        let newPoint = window.cascadeTopLeftFromPoint(NSMakePoint(NSMinX(parentWinFrame), NSMaxY(parentWinFrame)))
        window.cascadeTopLeftFromPoint(newPoint)
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        windowControllers.append(windowController)
        let filename = (self.document as? NSDocument)?.fileURL?.lastPathComponent
        window.title = String(format: "%@ ID = %u from %@", resource.type!.typeString, resource.ident, filename!);

        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowWillCloseNotification, object: window, queue: nil) { (note: NSNotification!) -> Void in
            if let index = find(self.windowControllers, windowController) {
                self.windowControllers.removeAtIndex(index)
            }
        }
    }
    
    override func windowTitleForDocumentDisplayName(displayName: String) -> String {
        let doc = self.document as? FVDocument
        return String(format: "%@ [%@]", displayName, doc!.resourceFile!.forkType == .Data ? "Data Fork" : "Resource Fork")
    }
    
    func viewSelectedResource() {
        for subview in self.typeView.subviews {
            subview.removeFromSuperview()
        }
        self.viewController = nil
        var view: NSView? = nil
        if let resource = self.selectedResource() {
            var errmsg = String()
            if let controller = controllerForResource(resource, errmsg: &errmsg) {
                self.viewController = controller
                view = controller.view
            } else {
                self.noSelectionLabel.stringValue = !errmsg.isEmpty ? errmsg : "Unsupported Type"
            }
        } else {
            self.noSelectionLabel.stringValue = "No Selection"
        }
        if view == nil {
            view = self.noSelectionView
        }
        view!.frame = self.typeView.bounds
        self.typeView.addSubview(view!)
    }
    
    func tableViewSelectionDidChange(note: NSNotification) {
        viewSelectedResource()
    }
}
