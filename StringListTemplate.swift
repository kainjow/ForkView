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
	
	var data = UnsafePointer<UInt8>(aResource.bytes)
	let count = UnsafePointer<Int16>(aResource.bytes).memory.bigEndian
	
	// First 2 bytes are the count of strings that this resource has.
	if count < aId {
		return nil
	}
	
	// skip count
	data += 2
	
	// looking for data.  data is in order
	while (--aId >= 0) {
		var toAdd = Int(data.memory) + 1;
		curSize += toAdd
		if (curSize >= handSize) {
			return nil;
		}
		data += toAdd
	}
	
	return {
		var aRet = [UInt8]()
		for i in 0...Int(data.memory) {
			aRet.append(data[i])
		}
		
		return aRet
	}()
}

private func pascalStringToString(aStr: UnsafePointer<UInt8>) -> String? {
	if let CFaStr = CFStringCreateWithPascalString(kCFAllocatorDefault, aStr, CFStringBuiltInEncodings.MacRoman.rawValue) as? String {
		return CFaStr
		// Perhaps the string is in another encoding. Try using the system's encoding to test this theory.
	} else if let CFaStr = CFStringCreateWithPascalString(kCFAllocatorDefault, aStr, CFStringGetMostCompatibleMacStringEncoding(CFStringGetSystemEncoding())) as? String {
		return CFaStr
		// Maybe GetApplicationTextEncoding can get the right format?
	} else if let CFaStr = CFStringCreateWithPascalString(kCFAllocatorDefault, aStr, GetApplicationTextEncoding()) as? String {
		return CFaStr
	}
	
	return nil
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
	func supportedTypes() -> [String] {
		return ["STR#"]
	}
	
	func viewControllerFromResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
		return StringListTemplate(resource: resource)
	}
}

final class StringListTemplate: NSViewController {
	@objc let stringList: [StringListObject]
	@IBOutlet weak var arrayController: NSArrayController!

	required init?(resource: FVResource) {
		
		if let resData = resource.data where resource.type!.typeString == "STR#" {
			var tmpStrList = [StringListObject]()
			var strIdx: Int16 = 0
			while let aPasString = pascalStringFromData(resData, index: strIdx++) {
				if let cStr = pascalStringToString(aPasString) {
					tmpStrList.append(StringListObject(string: cStr, index: strIdx - 1))
				} else {
					tmpStrList.append(StringListObject(string: "!!Unable to decode \(strIdx - 1)!!", index: strIdx - 1))
				}
			}

			stringList = tmpStrList
			super.init(nibName: "StringListView", bundle: nil)
			return
		}
		
		stringList = []
		super.init(nibName: "StringListView", bundle: nil)
		return nil

	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
