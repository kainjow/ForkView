//
//  FVPNGTemplate.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVPNGTemplate.h"
#import "ForkView-Swift.h"

@interface FVImageView : NSImageView

@end

@implementation FVImageView

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)needsPanelToBecomeKey
{
	return YES;
}

@end

@interface FVColorView : NSView
{
	NSColor *color;
}

@property (readwrite, retain) NSColor *color;

@end

@implementation FVColorView

@synthesize color;

- (void)drawRect:(NSRect)rect
{
    if (color) {
        [color set];
        [NSBezierPath fillRect:rect];
    }
}

@end

struct FVRGBColor {
    uint8_t r, g, b, a;
};

@implementation FVPNGTemplate

+ (NSImage*)imageFromResource:(FVResource*)resource
{
    NSData *rsrcData = [resource data];
	switch (resource.type.type) {
		case 'icns':
		case 'PICT':
		case 'PNG ':
            return [[NSImage alloc] initWithData:rsrcData];
        case 'ICON':
        {
            if ([rsrcData length] == 128) {
                int width = 32, height = 32;
                CFBitVectorRef bitVector = CFBitVectorCreate(kCFAllocatorDefault, (const UInt8*)[rsrcData bytes], [rsrcData length]*8);
                NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                                 pixelsWide:width
                                                                                 pixelsHigh:height
                                                                              bitsPerSample:8
                                                                            samplesPerPixel:4
                                                                                   hasAlpha:YES
                                                                                   isPlanar:NO
                                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                                                bytesPerRow:width*4
                                                                               bitsPerPixel:32];
                struct FVRGBColor *color = (struct FVRGBColor*)[bmp bitmapData];
                const unsigned numPixels = width * height;
                for (int i = 0; i < numPixels; ++i, ++color) {
                    if (CFBitVectorGetBitAtIndex(bitVector, i)) {
                        color->r = color->g = color->b = 0;
                    } else {
                        color->r = color->g = color->b = 255;
                    }
                    color->a = 255;
                }
                CFRelease(bitVector);
                NSImage *img = [[NSImage alloc] init];
                [img addRepresentation:bmp];
                return img;
            }
            break;
        }
        case 'ICN#':
        {
            if ([rsrcData length] == 256) {
                int width = 32, height = 32;
                CFBitVectorRef bitVector = CFBitVectorCreate(kCFAllocatorDefault, (const UInt8*)[rsrcData bytes], [rsrcData length]*8);
                NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                                 pixelsWide:width
                                                                                 pixelsHigh:height
                                                                              bitsPerSample:8
                                                                            samplesPerPixel:4
                                                                                   hasAlpha:YES
                                                                                   isPlanar:NO
                                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                                                bytesPerRow:width*4
                                                                               bitsPerPixel:32];
                struct FVRGBColor *color = (struct FVRGBColor*)[bmp bitmapData];
                const unsigned numPixels = width * height;
                for (int i = 0; i < numPixels; ++i, ++color) {
                    if (CFBitVectorGetBitAtIndex(bitVector, i)) {
                        color->r = color->g = color->b = 0;
                    } else {
                        color->r = color->g = color->b = 255;
                    }
                    if (CFBitVectorGetBitAtIndex(bitVector, i + numPixels)) {
                        color->a = 255;
                    } else {
                        color->a = 0;
                    }
                }
                CFRelease(bitVector);
                NSImage *img = [[NSImage alloc] init];
                [img addRepresentation:bmp];
                return img;
            }
            break;
        }
        case 'ics#':
        {
            if ([rsrcData length] == 64) {
                int width = 16, height = 16;
                CFBitVectorRef bitVector = CFBitVectorCreate(kCFAllocatorDefault, (const UInt8*)[rsrcData bytes], [rsrcData length]*8);
                NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                                 pixelsWide:width
                                                                                 pixelsHigh:height
                                                                              bitsPerSample:8
                                                                            samplesPerPixel:4
                                                                                   hasAlpha:YES
                                                                                   isPlanar:NO
                                                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                                                bytesPerRow:width*4
                                                                               bitsPerPixel:32];
                struct FVRGBColor *color = (struct FVRGBColor*)[bmp bitmapData];
                const unsigned numPixels = width * height;
                for (int i = 0; i < numPixels; ++i, ++color) {
                    if (CFBitVectorGetBitAtIndex(bitVector, i)) {
                        color->r = color->g = color->b = 0;
                    } else {
                        color->r = color->g = color->b = 255;
                    }
                    color->a = 255;
                }
                CFRelease(bitVector);
                NSImage *img = [[NSImage alloc] init];
                [img addRepresentation:bmp];
                return img;
            }
            break;
        }
    }
    return nil;
}

- (instancetype)initWithResource:(FVResource *)resource
{
	self = [super init];
	if (self != nil) {
        NSImage *img = [[self class] imageFromResource:resource];
		if (!img) {
			return nil;
		}
		
		NSRect rect;
		rect.origin = NSZeroPoint;
		rect.size = [img size];
		FVColorView *colorView = [[FVColorView alloc] initWithFrame:rect];

		FVImageView *imgView = [[FVImageView alloc] initWithFrame:[colorView bounds]];
		[imgView setImage:img];
		[imgView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[colorView addSubview:imgView];
		
		[self setView:colorView];
	}
	return self;
}

@end
