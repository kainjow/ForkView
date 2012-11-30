//
//  FVWindowController.m
//  ForkView
//
//  Created by Kevin Wojniak on 8/16/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVWindowController.h"
#import "FVDocument.h"
#import "FVResourceFile.h"
#import "FVResourceType.h"
#import "FVResource.h"

#import "FVPNGTemplate.h"

@implementation FVWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"FVWindow"];
	return self;
}

- (void)dealloc
{
	[windowControllers release];
	[super dealloc];
}

- (Class)templateClassForResource:(FVResource *)resource
{
	Class class = nil;
	switch (resource.type.type) {
		case 'icns':
		case 'PICT':
		case 'PNG ':
			class = [FVPNGTemplate class];
			break;
		default:
			break;
	}
	return class;
}

- (void)viewResource:(FVResource *)resource
{
	Class class = [self templateClassForResource:resource];
	if (!class) {
		NSBeep();
		return;
	}
	
	id <FVTemplate> controller = [[[class alloc] initWithResource:resource] autorelease];
	if (!controller) {
		NSBeep();
		return;
	}
	
	NSView *view = [controller view];
	
	NSSize minSize = NSMakeSize(250.0, 150.0);
	NSRect winFrame = [view frame];
	if (NSWidth(winFrame) < minSize.width) {
		winFrame.size.width = minSize.width;
	}
	if (NSHeight(winFrame) < minSize.height) {
		winFrame.size.height = minSize.height;
	}
	
	NSWindow *parentWin = [self window];
	NSRect parentWinFrame = [parentWin frameRectForContentRect:[[parentWin contentView] frame]];
	parentWinFrame.origin = [parentWin frame].origin;
	//winFrame.origin.x = NSMinX(parentWinFrame) + 15;
	//winFrame.origin.y = NSMinY(parentWinFrame);// - 15 - NSHeight(winFrame);
	
	NSWindow *window = [[NSWindow alloc] initWithContentRect:winFrame styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:YES];
	[window setContentView:[controller view]];
	[window setMinSize:minSize];
	
	NSPoint newPoint = [window cascadeTopLeftFromPoint:NSMakePoint(NSMinX(parentWinFrame), NSMaxY(parentWinFrame))];
	[window cascadeTopLeftFromPoint:newPoint];
	
	NSWindowController *windowController = [[[NSWindowController alloc] initWithWindow:window] autorelease];
	[windowController showWindow:nil];
	[windowControllers addObject:windowController];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:window];
	
	[window setTitle:[NSString stringWithFormat:@"%@ ID = %u from %@", resource.type.typeString, resource.ident, [[[self document] fileURL] lastPathComponent]]];
}

- (void)windowWillClose:(NSNotification *)notif
{
	NSWindow *window = [notif object];
	NSWindowController *windowController = [window windowController];
	[windowControllers removeObject:windowController];
}

- (void)openSelectedResource
{
	[self viewResource:[[resourcesArrayController selectedObjects] lastObject]];
}

- (void)close
{
	for (NSWindowController *windowController in windowControllers) {
		[windowController close];
	}
	[super close];
}

- (NSMenu *)tableViewMenuForSelection
{
#if 0
	FVResource *resource = [[resourcesArrayController selectedObjects] lastObject];
	NSMenu *menu = [[[NSMenu alloc] init] autorelease];
	[[menu addItemWithTitle:@"Open\u2026" action:@selector(openSelectedResource) keyEquivalent:@""] setTarget:self];
	return menu;
#endif
	return nil;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	FVDocument *doc = [self document];
	return [NSString stringWithFormat:@"%@ [%@]", displayName, doc.resourceFile.forkType == FVForkTypeData ? @"Data Fork" : @"Resource Fork"];
}

@end
