//
//  FVDocument.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class FVResourceFile;
@class FVWindowController;

@interface FVDocument : NSDocument
{
	FVResourceFile *resourceFile;
	FVWindowController *windowController;
}

@property (readwrite, retain) FVResourceFile *resourceFile;

@end
