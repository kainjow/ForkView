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
        return ["plst", "TEXT", "utf8", "utxt", "ut16", "weba"]
    }
    
    func viewControllerFromResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
        let str = stringFromResource(resource)
        if str == nil {
            return nil
        }
        let viewController = NSViewController(nibName: "TextView", bundle: nil)
        if viewController == nil {
            return nil
        }
        let scrollView = viewController!.view as! NSScrollView
        let textView = scrollView.documentView as! NSTextView
        textView.string = str!
        return viewController
    }
    
    func stringFromResource(resource: FVResource) -> String? {
        let rsrcData = resource.data
        if rsrcData == nil {
            return nil
        }
        let type = resource.type?.typeString
        switch type! {
        case "plst", "weba":
            let plist: AnyObject? = NSPropertyListSerialization.propertyListWithData(rsrcData!, options: NSPropertyListReadOptions(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: nil)
            if plist != nil {
                if let data = NSPropertyListSerialization.dataWithPropertyList(plist!, format: .XMLFormat_v1_0, options: NSPropertyListWriteOptions(0), error: nil) {
                    return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                }
            }
        case "TEXT":
            return NSString(data: rsrcData!, encoding: NSMacOSRomanStringEncoding) as? String
        case "utf8":
            return NSString(data: rsrcData!, encoding: NSUTF8StringEncoding) as? String
        case "utxt":
            return NSString(data: rsrcData!, encoding: NSUTF16BigEndianStringEncoding) as? String
        case "ut16":
            return NSString(data: rsrcData!, encoding: NSUnicodeStringEncoding) as? String
        default:
            break;
        }
        return nil
    }
}
