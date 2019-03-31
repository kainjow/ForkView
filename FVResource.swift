//
//  FVResource.swift
//  ForkView
//
//  Created by Kevin Wojniak on 8/3/14.
//  Copyright (c) 2014 Kevin Wojniak. All rights reserved.
//

import Foundation

final public class FVResource: NSObject {
    @objc var ident: UInt16 = 0
    @objc var name: String = ""
    @objc var dataSize: UInt32 = 0
    @objc var dataOffset: UInt32 = 0
    @objc var type: FVResourceType? = nil
    @objc var file: FVResourceFile? = nil

    @objc var data: NSData? {
        return file?.dataForResource(resource: self)
    }
}
