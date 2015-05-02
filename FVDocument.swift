//
//  FVDocument.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import AppKit

@NSApplicationMain final class FVDocument: NSDocument, NSApplicationDelegate {
    var resourceFile: FVResourceFile? = nil
    var windowController: NSWindowController? = nil
    
    override func makeWindowControllers() {
        super.makeWindowControllers()
    
        windowController = FVWindowController.windowController()
        addWindowController(windowController!)
    }
    
    override func readFromURL(url: NSURL, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
		resourceFile = FVResourceFile(contentsOfURL: url, error: outError)
        return resourceFile != nil
    }
}
