//
//  FVTextTypeController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/9/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVTextTypeController: FVTypeController {
    func supportedTypes() -> [String] {
        return ["plst", "TEXT"]
    }
    
    func viewControllerFromResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
		if let str = stringFromResource(resource) {
        
        let scrollView = NSScrollView(frame: NSMakeRect(0, 0, 100, 100))
        let contentSize = scrollView.contentSize
        scrollView.borderType = .NoBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        
        let textView = NSTextView(frame: NSMakeRect(0, 0, contentSize.width, contentSize.height))
        textView.editable = false
        textView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        textView.minSize = NSMakeSize(0, contentSize.height)
        textView.maxSize = NSMakeSize(CGFloat.max, CGFloat.max)
        textView.verticallyResizable = true
        textView.horizontallyResizable = false
        textView.autoresizingMask = .ViewWidthSizable
        textView.textContainer?.containerSize = NSMakeSize(contentSize.width, CGFloat.max)
        textView.textContainer?.widthTracksTextView = true
        
        scrollView.documentView = textView
        
        textView.string = str
        
        let viewController = NSViewController()
        viewController.view = scrollView
        return viewController
        } else {
            return nil
        }
    }
    
    func stringFromResource(resource: FVResource) -> String? {
        if let rsrcData = resource.data {
            let type = resource.type!.typeString
            switch type {
            case "plst":
                let plist: AnyObject? = NSPropertyListSerialization.propertyListWithData(rsrcData, options: NSPropertyListReadOptions(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: nil)
                if plist != nil {
                    if let data = NSPropertyListSerialization.dataWithPropertyList(plist!, format: .XMLFormat_v1_0, options: NSPropertyListWriteOptions(0), error: nil) {
                        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                    }
                }
            case "TEXT":
                return NSString(data: rsrcData, encoding: NSMacOSRomanStringEncoding) as? String
            default:
                break;
            }
        }
        return nil
    }
}
