//
//  FVDocument.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Cocoa

@NSApplicationMain final class FVDocument: NSDocument, NSApplicationDelegate {
    @objc var resourceFile: FVResourceFile?
    var windowController: NSWindowController?

    override func makeWindowControllers() {
        super.makeWindowControllers()

        windowController = FVWindowController.windowController()
        addWindowController(windowController!)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        resourceFile = try FVResourceFile.resourceFileWithContentsOfURL(fileURL: url)
    }
}
