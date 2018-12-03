//
//  FVTableView.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/1/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

protocol FVTableViewDelegate {
    func tableViewMenuForSelection() -> NSMenu?
}

final class FVTableView: NSTableView {
    var customDelegate: FVTableViewDelegate?
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let row = self.row(at: convert(event.locationInWindow, from: nil))
        if row == -1 {
            return nil
        }
        
        selectRowIndexes(NSIndexSet(index: row) as IndexSet, byExtendingSelection: false)
        self.window?.makeFirstResponder(self)
        
        return customDelegate?.tableViewMenuForSelection()
    }
}
