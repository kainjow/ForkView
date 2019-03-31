//
//  FVLine.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVLine: NSBox {
    override func draw(_ dirtyRect: NSRect) {
        var bounds = self.bounds.insetBy(dx: -1.0, dy: -1.0)
        bounds.origin.x += 1
        NSColor(calibratedWhite: 0.6, alpha: 1.0).set()
        bounds.frame()
    }
}
