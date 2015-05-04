//
//  FVDataReader.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

final class FVDataReader {
    private var data: NSData
    private var pos: Int = 0
    
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
    
    func readUInt8() -> UInt8? {
        if let dat = read(sizeof(UInt8)) {
            return UnsafePointer<UInt8>(dat.bytes)[0]
        }
        return nil
    }

    func readInt8() -> Int8? {
        if let dat = read(sizeof(Int8)) {
            return UnsafePointer<Int8>(dat.bytes)[0]
        }
        return nil
    }

    func unpack(format: String, endian: Endian) -> [Any]? {
        if count(format) == 0 {
            return nil
        }
        let be = endian == .Big
        var ret = [Any]()
        for ch in format {
            switch ch {
            case "H": // UInt16
                var val = UInt16()
                if readUInt16(endian, &val) {
                    ret.append(val)
                } else {
                    return nil
                }
            case "h": // Int16
                var val = Int16()
                if readInt16(endian, &val) {
                    ret.append(val)
                } else {
                    return nil
                }
            case "I": // UInt32
                var val = UInt32()
                if readUInt32(endian, &val) {
                    ret.append(val)
                } else {
                    return nil
                }
            case "i": // Int32
                var val = Int32()
                if readInt32(endian, &val) {
                    ret.append(val)
                } else {
                    return nil
                }
            case "B": // UInt8
                if let val = readUInt8() {
                    ret.append(val)
                } else {
                    return nil
                }
            case "b": // Int8
                if let val = readInt8() {
                    ret.append(val)
                } else {
                    return nil
                }
            default:
                println("Unknown format code \(ch)")
                return nil
            }
        }
        return ret
    }
}
