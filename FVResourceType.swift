//
//  FVResourceType.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Foundation

final public class FVResourceType: NSObject {
    public var type: OSType = 0
    public var count: UInt32 = 0
    public var offset: UInt32 = 0
    public var resources: NSArray = []

    public var typeString: String {
        return UTCreateStringForOSType(type).takeRetainedValue() as String
    }
};
