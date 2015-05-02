//
//  FVWindowController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/1/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVWindowController: NSWindowController, FVTableViewDelegate {
    @IBOutlet weak var resourcesArrayController: NSArrayController!
    @IBOutlet weak var tableView: FVTableView!
    
    var windowControllers = [NSWindowController]()
    
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
            viewResource(resource)
        }
    }
    
    func controllerForResource(resource: FVResource) -> FVTemplateController? {
        let str = resource.type?.typeString
        if str == nil {
            return nil
        }
        switch str! {
            case "icns", "PICT", "PNG ", "ICON", "ICN#", "ics#":
                return FVImageTemplate.template(resource)
            default:
                return nil
        }
    }

    func viewResource(resource: FVResource) {
        let controller = controllerForResource(resource)
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
}