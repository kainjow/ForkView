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
        return ["icns", "PICT", "PNG ", "ICON", "ICN#", "ics#"]
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
    
    func imageFromBitmapData(data: NSData, size: Int) -> NSImage? {
        let ptr: UnsafePointer<UInt8> = UnsafePointer(data.bytes)
        let bitVector = CFBitVectorCreate(kCFAllocatorDefault, ptr, data.length * 8)
        if bitVector == nil {
            return nil
        }
        let bitmap = NSBitmapImageRep(
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
        if bitmap == nil {
            return nil
        }
        struct FVRGBColor {
            var r: UInt8
            var g: UInt8
            var b: UInt8
            var a: UInt8
        }
        let color = UnsafeMutablePointer<FVRGBColor>(bitmap!.bitmapData)
        let numPixels = size * size
        for (var i = 0; i < numPixels; ++i) {
            let value: UInt8 = CFBitVectorGetBitAtIndex(bitVector, i) == 1 ? 0 : 255
            color[i].r = value
            color[i].g = value
            color[i].b = value
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
