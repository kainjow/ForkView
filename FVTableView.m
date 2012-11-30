//
//  FVTableView.m
//  ForkView
//
//  Created by Kevin Wojniak on 7/13/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVTableView.h"


@implementation FVTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger row = [self rowAtPoint:mouseLoc];
	if (row == -1) {
		return nil;
	}
	
	[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	[[self window] makeFirstResponder:self];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(tableViewMenuForSelection)]) {
		return [(id)[self delegate] tableViewMenuForSelection];
	}

	return nil;
}

@end
