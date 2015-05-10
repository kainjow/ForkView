//
//  FVImageTemplate.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa

final class FVImageTypeController: FVTypeController {
    func supportedTypes() -> [String] {
        return ["icns", "PICT", "PNG ", "ICON", "ICN#", "ics#", "CURS", "PAT ", "icl4"]
    }
    
    func viewControllerFromResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
        let img = imageFromResource(resource)
        if img == nil {
            return nil
        }
        
        let rect = NSMakeRect(0, 0, img!.size.width, img!.size.height)
        let imgView = FVImageView(frame: rect)
        imgView.image = img
        imgView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
        let viewController = NSViewController()
        viewController.view = imgView
        return viewController
    }
    
    private struct FVRGBAColor {
        var r: UInt8
        var g: UInt8
        var b: UInt8
        var a: UInt8
    }

    private struct FVRGBColor {
        var r: UInt8
        var g: UInt8
        var b: UInt8
    }
    
    func makeBitmap(size: Int) -> NSBitmapImageRep? {
        return NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: size,
            pixelsHigh: size,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSCalibratedRGBColorSpace,
            bytesPerRow: size * 4,
            bitsPerPixel: 32
        )
    }

    func imageFromBitmapData(data: NSData, maskData: NSData? = nil, size: Int) -> NSImage? {
        let ptr: UnsafePointer<UInt8> = UnsafePointer(data.bytes)
        let bitVector = CFBitVectorCreate(kCFAllocatorDefault, ptr, data.length * 8)
        if bitVector == nil {
            return nil
        }
        
        let haveAlpha  = maskData != nil
        var maskBitVector: CFBitVectorRef
        if haveAlpha {
            if data.length != maskData!.length {
                println("Data and mask lengths mismatch!")
                return nil
            }
            let maskPtr: UnsafePointer<UInt8> = UnsafePointer(maskData!.bytes)
            maskBitVector = CFBitVectorCreate(kCFAllocatorDefault, maskPtr, maskData!.length * 8)
        } else {
            // create a dummy value since CFBitVector can't be nil
            maskBitVector = CFBitVectorCreate(kCFAllocatorDefault, ptr, data.length * 8)
        }
        
        let bitmap = makeBitmap(size)
        if bitmap == nil {
            return nil
        }
        let color = UnsafeMutablePointer<FVRGBAColor>(bitmap!.bitmapData)
        let numPixels = size * size
        for (var i = 0; i < numPixels; ++i) {
            let value: UInt8 = CFBitVectorGetBitAtIndex(bitVector, i) == 1 ? 0 : 255
            color[i].r = value
            color[i].g = value
            color[i].b = value
            color[i].a = !haveAlpha ? 255 : (CFBitVectorGetBitAtIndex(maskBitVector, i) == 1 ? 255 : 0)
        }
        
        let img = NSImage()
        img.addRepresentation(bitmap!)
        return img
    }
    
    func imageFrom4BitColorData(data: NSData, size: Int) -> NSImage? {
        let ptr: UnsafePointer<UInt8> = UnsafePointer(data.bytes)
        
        let palette: [FVRGBColor] = [
            FVRGBColor(r: 255, g: 255, b: 255),
            FVRGBColor(r: 251, g: 242, b: 5),
            FVRGBColor(r: 255, g: 100, b: 2),
            FVRGBColor(r: 220, g: 8, b: 6),
            FVRGBColor(r: 241, g: 8, b: 132),
            FVRGBColor(r: 70, g: 0, b: 164),
            FVRGBColor(r: 0, g: 0, b: 211),
            FVRGBColor(r: 2, g: 170, b: 234),
            FVRGBColor(r: 31, g: 182, b: 20),
            FVRGBColor(r: 0, g: 100, b: 17),
            FVRGBColor(r: 85, g: 44, b: 5),
            FVRGBColor(r: 144, g: 112, b: 57),
            FVRGBColor(r: 191, g: 191, b: 191),
            FVRGBColor(r: 127, g: 127, b: 127),
            FVRGBColor(r: 63, g: 63, b: 63),
            FVRGBColor(r: 0, g: 0, b: 0),
        ]
        
        let bitmap = makeBitmap(size)
        if bitmap == nil {
            return nil
        }
        let color = UnsafeMutablePointer<FVRGBAColor>(bitmap!.bitmapData)
        let numPixels = size * size
        for var i = 0, ptrIndex = 0; i < numPixels; ++i {
            let index: UInt8
            if i & 1 == 0 {
                index = (ptr[ptrIndex] & 0xF0) >> 4
            } else {
                index = (ptr[ptrIndex] & 0x0F)
            }
            if i > 0 && (i & 1) == 1 {
                ++ptrIndex
            }
            let rgb = palette[Int(index)]
            color[i].r = rgb.r
            color[i].g = rgb.g
            color[i].b = rgb.b
            color[i].a = 255
        }
        
        let img = NSImage()
        img.addRepresentation(bitmap!)
        return img
    }
    
    func imageFromResource(resource: FVResource) -> NSImage? {
        if let rsrcData = resource.data {
            if let type = resource.type?.typeString {
                switch type {
                case "icns", "PICT", "PNG ":
                    return NSImage(data: rsrcData)
                case "ICON":
                    if rsrcData.length == 128 {
                        return imageFromBitmapData(rsrcData, size: 32)
                    }
                case "ICN#":
                    if rsrcData.length == 256 {
                        return imageFromBitmapData(rsrcData, size: 32)
                    }
                case "ics#":
                    if rsrcData.length == 64 {
                        return imageFromBitmapData(rsrcData, size: 16)
                    }
                case "CURS":
                    if rsrcData.length == 68 {
                        let data = rsrcData.subdataWithRange(NSMakeRange(0, 32))
                        let mask = rsrcData.subdataWithRange(NSMakeRange(32, 32))
                        return imageFromBitmapData(data, maskData: mask, size: 16)
                    }
                case "PAT ":
                    if rsrcData.length == 8 {
                        return imageFromBitmapData(rsrcData, size: 8)
                    }
                case "icl4":
                    if rsrcData.length == 512 {
                        return imageFrom4BitColorData(rsrcData, size: 32)
                    }
                default:
                    return nil
                }
            }
        }
        return nil
    }
}

final class FVImageView: NSImageView {
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }

    override var needsPanelToBecomeKey: Bool {
        get {
            return true
        }
    }
}
