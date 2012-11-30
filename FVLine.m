//
//  FVLine.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVLine.h"


@implementation FVLine

- (void)drawRect:(NSRect)rect
{
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
	NSRect bounds = NSInsetRect([self bounds], -1, -1);
	bounds.origin.x += 1;
	NSFrameRect(bounds);
}

@end
