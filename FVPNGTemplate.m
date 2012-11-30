//
//  FVPNGTemplate.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVPNGTemplate.h"
#import "FVResource.h"

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

- (void)dealloc
{
	[color release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	[color set];
	[NSBezierPath fillRect:rect];
}

@end

@implementation FVPNGTemplate

- (id)initWithResource:(FVResource *)resource
{
	self = [super init];
	if (self != nil) {
		NSImage *img = [[[NSImage alloc] initWithData:resource.data] autorelease];
		if (!img) {
			[self release];
			return nil;
		}
		
		NSRect rect;
		rect.origin = NSZeroPoint;
		rect.size = [img size];
		FVColorView *colorView = [[[FVColorView alloc] initWithFrame:rect] autorelease];
		colorView.color = [NSColor whiteColor];

		FVImageView *imgView = [[[FVImageView alloc] initWithFrame:[colorView bounds]] autorelease];
		[imgView setImage:img];
		[imgView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[colorView addSubview:imgView];
		
		[self setView:colorView];
	}
	return self;
}

+ (NSString *)UTTypeForResource:(FVResource *)resource
{
	switch (resource.type.type) {
		case 'PICT':
			return (NSString *)kUTTypePICT;
		case 'PNG ':
			return (NSString *)kUTTypePNG;
	}
	return nil;
}


@end
