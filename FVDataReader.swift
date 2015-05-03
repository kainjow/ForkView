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
    
    func unpack(format: String, endian: Endian) -> [Any]? {
        if count(format) == 0 {
            return nil
        }
        let be = endian == .Big
        var ret = [Any]()
        for ch in format {
            switch ch {
            case "H": // UInt16
                if let dat = read(sizeof(UInt16)) {
                    var val = UInt16()
                    dat.getBytes(&val)
                    ret.append(be ? UInt16(bigEndian: val) : UInt16(littleEndian: val))
                } else {
                    return nil
                }
            case "h": // Int16
                if let dat = read(sizeof(Int16)) {
                    var val = Int16()
                    dat.getBytes(&val)
                    ret.append(be ? Int16(bigEndian: val) : Int16(littleEndian: val))
                } else {
                    return nil
                }
            case "I": // UInt32
                if let dat = read(sizeof(UInt32)) {
                    var val = UInt32()
                    dat.getBytes(&val)
                    ret.append(be ? UInt32(bigEndian: val) : UInt32(littleEndian: val))
                } else {
                    return nil
                }
            case "i": // Int32
                if let dat = read(sizeof(Int32)) {
                    var val = Int32()
                    dat.getBytes(&val)
                    ret.append(be ? Int32(bigEndian: val) : Int32(littleEndian: val))
                } else {
                    return nil
                }
            case "B": // UInt8
                if let dat = read(sizeof(UInt8)) {
                    ret.append(UnsafePointer<UInt8>(dat.bytes)[0])
                } else {
                    return nil
                }
            case "b": // Int8
                if let dat = read(sizeof(Int8)) {
                    ret.append(UnsafePointer<Int8>(dat.bytes)[0])
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
