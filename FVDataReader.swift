//
//  FVDataReader.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation
import Darwin.POSIX.sys.xattr

final class FVDataReader {
    private var data = NSData()
    private(set) var position = 0
    
    var length: Int {
        get {
            return data.length
        }
    }
    
    init(_ data: NSData) {
        self.data = data
    }
    
    init?(url: NSURL, resourceFork: Bool) {
        // Apple's docs say "The maximum size of the resource fork in a file is 16 megabytes"
        let maxResourceSize = 16777216
        if !resourceFork {
            var fileSize: AnyObject?
            do {
                try url.getResourceValue(&fileSize, forKey: .fileSizeKey)
            } catch _ {
            }
            guard let fileSizeNum = fileSize as? NSNumber else {
                return nil
            }
            if fileSizeNum.intValue == 0 || fileSizeNum.intValue >= maxResourceSize {
                return nil
            }
            guard let data = NSData(contentsOf: url as URL) else {
                return nil
            }
            self.data = data
        } else {
            guard let path = url.path else {
                return nil
            }
            let rsrcSize = getxattr(path, XATTR_RESOURCEFORK_NAME, nil, 0, 0, 0)
            if rsrcSize <= 0 || rsrcSize >= maxResourceSize {
                return nil
            }
            guard let data = NSMutableData(length: rsrcSize) else {
                return nil
            }
            if getxattr(path, XATTR_RESOURCEFORK_NAME, data.mutableBytes, rsrcSize, 0, 0) != rsrcSize {
                return nil
            }
            self.data = data
        }
    }
    
    class func dataReader(URL: NSURL, resourceFork: Bool) -> FVDataReader? {
        return FVDataReader(url: URL, resourceFork: resourceFork)
    }
    
    func read(_ size: Int) -> NSData? {
        if (position + size > self.length) {
            return nil
        }
        let subdata = data.subdata(with: NSMakeRange(position, size))
        position += size
        return subdata as NSData
    }
    
    func read(_ size: CUnsignedInt, into buf: UnsafeMutableRawPointer) -> Bool {
        guard let data = self.read(Int(size)) else {
            return false
        }
        data.getBytes(buf)
        return true
    }
    
    func seekTo(_ offset: Int) -> Bool {
        if (offset >= self.length) {
            return false
        }
        position = offset
        return true
    }
    
    enum Endian {
        case Little, Big
    }
    
    func readUInt16(_ endian: Endian, _ val: inout UInt16) -> Bool {
        if let dat = read(MemoryLayout<UInt16>.size) {
            dat.getBytes(&val)
            val = endian == .Big ? UInt16(bigEndian: val) : UInt16(littleEndian: val)
            return true
        }
        return false
    }

    func readInt16(_ endian: Endian, _ val: inout Int16) -> Bool {
        if let dat = read(MemoryLayout<Int16>.size) {
            dat.getBytes(&val)
            val = endian == .Big ? Int16(bigEndian: val) : Int16(littleEndian: val)
            return true
        }
        return false
    }

    func readUInt32(_ endian: Endian, _ val: inout UInt32) -> Bool {
        if let dat = read(MemoryLayout<UInt32>.size) {
            dat.getBytes(&val)
            val = endian == .Big ? UInt32(bigEndian: val) : UInt32(littleEndian: val)
            return true
        }
        return false
    }
    
    func readInt32(_ endian: Endian, _ val: inout Int32) -> Bool {
        if let dat = read(MemoryLayout<Int32>.size) {
            dat.getBytes(&val)
            val = endian == .Big ? Int32(bigEndian: val) : Int32(littleEndian: val)
            return true
        }
        return false
    }
    
    func readUInt8(_ val: inout UInt8) -> Bool {
        if let dat = read(MemoryLayout<UInt8>.size) {
            dat.getBytes(&val)
            return true
        }
        return false
    }

    func readInt8(_ val: inout Int8) -> Bool {
        if let dat = read(MemoryLayout<Int8>.size) {
            dat.getBytes(&val)
            return true
        }
        return false
    }
}
