//
//  PICTConverter.m
//  PICTConverter
//
//  Created by Kevin Wojniak on 5/10/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//
//  This is a helper tool to convert PICT to NSImage.
//  It must be compiled as 32-bit so NSPICTImageRep can use QuickDraw,
//  which is only available to 32-bit applications. 64-bit can render
//  some basic PICT files, but it seems to fail for most.

#import <Cocoa/Cocoa.h>
#import "PICTConverter.h"

#ifndef __i386__
#error Must be compiled 32-bit!
#endif

@implementation PICTConverter

- (void)convertPICTDataToTIFF:(NSData *)pictData withReply:(void (^)(NSData *))reply {
    @autoreleasepool {
        NSPICTImageRep *pictRep = [NSPICTImageRep imageRepWithData:pictData];
        if (pictRep) {
            NSImage *img = [[[NSImage alloc] initWithSize:pictRep.size] autorelease];
            [img addRepresentation:pictRep];
            NSData *data = [img TIFFRepresentation];
            if (data.length > 0) {
                reply(data);
                return;
            }
        }
        reply(nil);
    }
}

@end
