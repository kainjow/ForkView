//
//  FVDocument.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVDocument.h"
#import "FVWindowController.h"
#import "FVResourceFile.h"
#import "FVResource.h"

@implementation FVDocument

@synthesize resourceFile;

- (void)dealloc
{
	[windowController release];
	[resourceFile release];
	[super dealloc];
}

- (void)makeWindowControllers
{
	[super makeWindowControllers];
	
	windowController = [[FVWindowController alloc] init];
	[self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	self.resourceFile = [FVResourceFile resourceFileWithContentsOfURL:absoluteURL error:outError];
	if (self.resourceFile == nil) {
		return NO;
	}
	return YES;
}

@end
