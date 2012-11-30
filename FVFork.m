//
//  FVFork.m
//  ForkView
//
//  Created by Kevin Wojniak on 7/9/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVFork.h"


@implementation FVFork

@synthesize forkType;

- (id)initWithURL:(NSURL *)fileURL type:(FVForkType)theForkType
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	FSRef ref;
	if (!CFURLGetFSRef((CFURLRef)fileURL, &ref)) {
		[self release];
		return nil;
	}
	
	HFSUniStr255 forkName;
	if (theForkType == FVForkTypeResource) {
		if (FSGetResourceForkName(&forkName) != noErr) {
			[self release];
			return nil;
		}
	} else {
		if (FSGetDataForkName(&forkName) != noErr) {
			[self release];
			return nil;
		}
	}
	
	FSIORefNum tmpForkRef;
	OSErr err = FSOpenFork(&ref, forkName.length, forkName.unicode, fsRdPerm, &tmpForkRef);
	if (err != noErr) {
		[self release];
		return nil;
	}
	
	forkRef = tmpForkRef;
	
	if ([self length] <= 0 || ![self seekTo:0]) {
		[self release];
		return nil;
	}
	
	forkType = theForkType;
	
	return self;
}

- (void)dealloc
{
	if (forkRef) {
		(void)FSCloseFork(forkRef);
	}
	[super dealloc];
}

- (off_t)length
{
	SInt64 size;
	OSErr err = FSGetForkSize(forkRef, &size);
	if (err != noErr) {
		NSLog(@"FSGetForkSize error: %d", err);
		return -1;
	}
	return size;
}

- (off_t)position
{
	SInt64 pos;
	OSErr err = FSGetForkPosition(forkRef, &pos);
	if (err != noErr) {
		NSLog(@"FSGetForkPosition error: %d", err);
		return -1;
	}
	return pos;
}

- (BOOL)read:(size_t)size into:(void *)buffer
{
	OSErr err = FSReadFork(forkRef, fsAtMark, 0, size, buffer, NULL);
	if (err != noErr) {
		NSLog(@"FSReadFork error: %d", err);
		return NO;
	}
	return YES;
}

- (BOOL)seekTo:(off_t)offset
{
	OSErr err = FSSetForkPosition(forkRef, fsFromStart, offset);
	if (err != noErr) {
		NSLog(@"FSSetForkPosition error: %d", err);
		return NO;
	}
	return YES;
}

@end
