//
//  FVResourceType.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Foundation

class FVResourceType: NSObject {
    public var type: UInt32 = 0;
    public var count: UInt32 = 0;
    public var offset: UInt32 = 0;
    public var resources: NSArray = [];

    public var typeString: NSString {
        return NSString(format:"%c%c%c%c",
            (type & 0xFF000000) >> 24,
            (type & 0x00FF0000) >> 16,
            (type & 0x0000FF00) >> 8,
            (type & 0x000000FF)
        );
    }
};
