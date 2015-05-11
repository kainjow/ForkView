//
//  FVDataReader.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

final class FVDataReader {
    private var data = NSData()
    private var pos = 0
    
    var length: Int {
        get {
            return data.length
        }
    }
    
    var position: Int {
        get {
            return pos
        }
    }
    
    init(_ data: NSData) {
        self.data = data
    }
    
    init?(URL: NSURL, resourceFork: Bool) {
        // Apple's docs say "The maximum size of the resource fork in a file is 16 megabytes"
        let maxResourceSize = 16777216
        if !resourceFork {
            var fileSize: AnyObject?
            URL.getResourceValue(&fileSize, forKey: NSURLFileSizeKey, error: nil)
            let fileSizeNum = fileSize as? NSNumber
            if fileSizeNum == nil {
                return nil
            }
            if fileSizeNum!.integerValue == 0 || fileSizeNum!.integerValue >= maxResourceSize {
                return nil
            }
            let data = NSData(contentsOfURL: URL)
            if data == nil {
                return nil
            }
            self.data = data!
        } else {
            let rsrcSize = getxattr(URL.path!, XATTR_RESOURCEFORK_NAME, nil, 0, 0, 0)
            if rsrcSize <= 0 || rsrcSize >= maxResourceSize {
                return nil
            }
            let data = NSMutableData(length: rsrcSize)
            if data == nil {
                return nil
            }
            if getxattr(URL.path!, XATTR_RESOURCEFORK_NAME, data!.mutableBytes, rsrcSize, 0, 0) != rsrcSize {
                return nil
            }
            self.data = data!
        }
    }
    
    func read(size: Int) -> NSData? {
        if (pos + size > self.length) {
            return nil
        }
        let subdata = data.subdataWithRange(NSMakeRange(pos, size))
        pos += size
        return subdata
    }
    
    func seekTo(offset: Int) -> Bool {
        if (offset >= self.length) {
            return false
        }
        pos = offset
        return true
    }
    
    enum Endian {
        case Little, Big
    }
    
    func readUInt16(endian: Endian, inout _ val: UInt16) -> Bool {
        if let dat = read(sizeof(UInt16)) {
            dat.getBytes(&val)
            val = endian == .Big ? UInt16(bigEndian: val) : UInt16(littleEndian: val)
            return true
        }
        return false
    }

    func readInt16(endian: Endian, inout _ val: Int16) -> Bool {
        if let dat = read(sizeof(Int16)) {
            dat.getBytes(&val)
            val = endian == .Big ? Int16(bigEndian: val) : Int16(littleEndian: val)
            return true
        }
        return false
    }

    func readUInt32(endian: Endian, inout _ val: UInt32) -> Bool {
        if let dat = read(sizeof(UInt32)) {
            dat.getBytes(&val)
            val = endian == .Big ? UInt32(bigEndian: val) : UInt32(littleEndian: val)
            return true
        }
        return false
    }
    
    func readInt32(endian: Endian, inout _ val: Int32) -> Bool {
        if let dat = read(sizeof(Int32)) {
            dat.getBytes(&val)
            val = endian == .Big ? Int32(bigEndian: val) : Int32(littleEndian: val)
            return true
        }
        return false
    }
    
    func readUInt8(inout val: UInt8) -> Bool {
        if let dat = read(sizeof(UInt8)) {
            dat.getBytes(&val)
            return true
        }
        return false
    }

    func readInt8(inout val: Int8) -> Bool {
        if let dat = read(sizeof(Int8)) {
            dat.getBytes(&val)
            return true
        }
        return false
    }
}
