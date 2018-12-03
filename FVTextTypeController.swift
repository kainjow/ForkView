//
//  FVTextTypeController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/9/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVTextTypeController: FVTypeController {
    let supportedTypes = ["plst", "TEXT", "utf8", "utxt", "ut16", "weba", "RTF ", "rtfd", "STR "]
    
    func viewControllerFromResourceData(data: NSData, type: String, errmsg: inout String) -> NSViewController? {
        guard let str = attributedStringFromResource(data, type: type) else {
            return nil
        }
        let viewController = NSViewController(nibName: "TextView", bundle: nil)
        let scrollView = viewController.view as! NSScrollView
        let textView = scrollView.documentView as! NSTextView
        textView.textStorage?.setAttributedString(str)
        return viewController
    }
    
    func attributedStringFromResource(_ rsrcData: NSData, type: String) -> NSAttributedString? {
        switch type {
        case "RTF ":
            return NSAttributedString(rtf: rsrcData as Data, documentAttributes: nil)
        case "rtfd":
            return NSAttributedString(rtfd: rsrcData as Data, documentAttributes: nil)
        default:
            if let str = stringFromResource(rsrcData, type: type) {
                return NSAttributedString(string: str)
            }
            break;
        }
        return nil
    }
    
    func stringFromResource(_ rsrcData: NSData, type: String) -> String? {
        switch type {
        case "plst", "weba":
            let plist = try? PropertyListSerialization.propertyList(from: rsrcData as Data, options: [.mutableContainers], format: nil)
            if plist != nil {
                if let data = try? PropertyListSerialization.data(fromPropertyList: plist!, format: .xml, options: PropertyListSerialization.WriteOptions(0) ) {
                    return String(data: data, encoding: .utf8)
                }
            }
        case "TEXT":
            return String(data: rsrcData as Data, encoding: .macOSRoman)
        case "utf8":
            return String(data: rsrcData as Data, encoding: .utf8)
        case "utxt":
            return String(data: rsrcData as Data, encoding: .utf16BigEndian)
        case "ut16":
            return String(data: rsrcData as Data, encoding: .unicode)
        case "STR ":
            return stringFromPascalStringData(rsrcData)
        default:
            break;
        }
        return nil
    }
    
    func stringFromPascalStringData(_ data: NSData) -> String? {
        if data.length < 2 {
            return nil
        }
        let ptr = data.bytes.assumingMemoryBound(to: UInt8.self)
        let strLen = Int(ptr[0])
        if data.length < (strLen + 1) {
            return nil
        }
        let strData = Data(bytes: ptr.successor(), count: strLen)
        return String(bytes: strData, encoding: .macOSRoman)
    }
}
