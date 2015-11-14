//
//  FVDocument.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Cocoa

@NSApplicationMain final class FVDocument: NSDocument, NSApplicationDelegate {
    var resourceFile: FVResourceFile? = nil
    var windowController: NSWindowController? = nil
    
    override func makeWindowControllers() {
        super.makeWindowControllers()
    
        windowController = FVWindowController.windowController()
        addWindowController(windowController!)
    }
    
    override func readFromURL(url: NSURL, ofType typeName: String) throws {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
		do {
            resourceFile = try FVResourceFile.resourceFileWithContentsOfURL(url)
        } catch let error as NSError {
            outError = error
            resourceFile = nil
        }
        if resourceFile != nil {
            return
        }
        throw outError
    }
}
