//
//  FVResourceType.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Foundation

final public class FVResourceType: NSObject {
    @objc var type: OSType = 0
    @objc var count: UInt32 = 0
    @objc var offset: UInt32 = 0
    @objc var resources: NSArray = []

    @objc var typeString: String {
        return UTCreateStringForOSType(type).takeRetainedValue() as String
    }
};
