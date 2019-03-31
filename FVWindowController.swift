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
        FVTextTypeController(),
		StringListView(),
    ]
    var viewController: NSViewController? = nil
    
    class func windowController() -> Self {
        return self.init(windowNibName: "FVWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        tableView.customDelegate = self
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: self.window, queue: nil) { note in
            for windowController in self.windowControllers {
                windowController.close()
            }
        }
        
        viewSelectedResource()
    }
    
    func tableViewMenuForSelection() -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: "Export\u{2026}", action: #selector(export), keyEquivalent: "")
        return menu
    }

    func selectedResource() -> FVResource? {
        return resourcesArrayController.selectedObjects.last as? FVResource
    }
    
    @objc func export() {
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: self.window!) { result in
            if result == .OK {
                self.selectedResource()?.data?.write(to: savePanel.url!, atomically: true)
            }
        }
    }
    
    func openSelectedResource() {
        if let resource = self.selectedResource() {
            openResource(resource: resource)
        }
    }
    
    func controllerForResource(resource: FVResource, errmsg: inout String) -> NSViewController? {
        if let rsrcData = resource.data, rsrcData.length > 0 {
            if let type = resource.type?.typeString {
                for controller in typeControllers {
                    if controller.supportedTypes.contains(type) {
                        return controller.viewControllerFromResourceData(data: rsrcData, type: type, errmsg: &errmsg)
                    }
                }
            }
        } else {
            errmsg = "No data"
        }
        return nil
    }

    func openResource(resource: FVResource) {
        var errmsg = String()
        let controller = controllerForResource(resource: resource, errmsg: &errmsg)
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
        var parentWinFrame = parentWin!.frameRect(forContentRect: parentWin!.contentView!.frame)
        parentWinFrame.origin = parentWin!.frame.origin
        
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        let window = NSWindow(contentRect: winFrame, styleMask: styleMask, backing: .buffered, defer: true)
        window.isReleasedWhenClosed = true
        window.contentView = controller!.view
        window.minSize = minSize
        
        let newPoint = window.cascadeTopLeft(from: NSMakePoint(NSMinX(parentWinFrame), NSMaxY(parentWinFrame)))
        window.cascadeTopLeft(from: newPoint)
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        windowControllers.append(windowController)
        let filename = (self.document as? NSDocument)?.fileURL?.lastPathComponent
        window.title = String(format: "%@ ID = %u from %@", resource.type!.typeString, resource.ident, filename!);

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: nil) { note in
            if let index = self.windowControllers.firstIndex(of: windowController) {
                self.windowControllers.remove(at: index)
            }
        }
    }
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        let doc = self.document as? FVDocument
        return String(format: "%@ [%@]", displayName, !doc!.resourceFile!.isResourceFork ? "Data Fork" : "Resource Fork")
    }
    
    func viewSelectedResource() {
        for subview in self.typeView.subviews {
            subview.removeFromSuperview()
        }
        self.viewController = nil
        var view: NSView? = nil
        if let resource = self.selectedResource() {
            var errmsg = String()
            if let controller = controllerForResource(resource: resource, errmsg: &errmsg) {
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
    
    func tableViewSelectionDidChange(_ note: Notification) {
        viewSelectedResource()
    }
}
