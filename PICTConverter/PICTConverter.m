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

#ifndef __i386__
#error Must be compiled 32-bit!
#endif

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc == 2) {
            NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:argv[1] length:strlen(argv[1])];
            NSImage *img = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
            if (img) {
                NSData *data = [img TIFFRepresentation];
                if (data.length > 0) {
                    if (write(STDOUT_FILENO, [data bytes], data.length) == data.length) {
                        return EXIT_SUCCESS;
                    }
                }
            }
        }
    }
    return EXIT_FAILURE;
}
