//
//  StringListTemplate.swift
//  ForkView
//
//  Created by C.W. Betts on 4/22/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa
import Carbon

//Code taken from PlayerPRO Player's Sctf importer, modified to work in Swift
private func pascalStringFromData(aResource: NSData, index indexID: Int16) -> [UInt8]? {
	let handSize = aResource.length
	var curSize = 2
	var aId = indexID
	
	var data = aResource.bytes.assumingMemoryBound(to: UInt8.self)
	let count = aResource.bytes.assumingMemoryBound(to: Int16.self)[0].bigEndian
	
	// First 2 bytes are the count of strings that this resource has.
	if count < aId {
		return nil
	}
	
	// skip count
	data += 2
	
	// looking for data.  data is in order
    aId -= 1
	while aId >= 0 {
		let toAdd = Int(data.pointee) + 1;
		curSize += toAdd
		if curSize >= handSize {
			return nil;
		}
		data += toAdd
        aId -= 1
	}
	
	return {
		var aRet = [UInt8]()
		for i in 0...Int(data.pointee) {
			aRet.append(data[i])
		}
		
		return aRet
	}()
}

private func pascalStringToString(_ aStr: UnsafePointer<UInt8>) -> String? {
	return CFStringCreateWithPascalString(kCFAllocatorDefault, aStr, CFStringBuiltInEncodings.macRoman.rawValue) as String
}

final class StringListObject: NSObject {
	let name: String
	let index: Int
	
	init(string: String, index: Int) {
		self.name = string
		self.index = index
		
		super.init()
	}
}

final class StringListView: FVTypeController {
	let supportedTypes = ["STR#"]
	
	func viewControllerFromResourceData(data: NSData, type: String, errmsg: inout String) -> NSViewController? {
        return StringListTemplate(resData: data, type: type)
	}
}

final class StringListTemplate: NSViewController {
	@objc let stringList: [StringListObject]
	@IBOutlet weak var arrayController: NSArrayController!

    required init?(resData: NSData, type: String) {
        var tmpStrList = [StringListObject]()
        var strIdx: Int16 = 0
        while let aPasString = pascalStringFromData(aResource: resData, index: strIdx) {
            if let cStr = pascalStringToString(aPasString) {
                tmpStrList.append(StringListObject(string: cStr, index: Int(strIdx)))
            } else {
                tmpStrList.append(StringListObject(string: "!!Unable to decode \(strIdx)!!", index: Int(strIdx)))
            }
            strIdx += 1
        }

        stringList = tmpStrList
        super.init(nibName: "StringListView", bundle: nil)
        return
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
