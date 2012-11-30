//
//  FVResource.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResource.h"
#import "FVResourcePriv.h"
#import "FVResourceFilePriv.h"

@implementation FVResource

@synthesize ident, name, dataSize, dataOffset, type, file;

- (void)setID:(uint16_t)anID
{
	ident = anID;
}

- (void)setName:(NSString *)aName
{
	if (name != aName) {
		[name release];
		name = [aName copy];
	}
}

- (void)setDataSize:(uint32_t)size offset:(uint32_t)offset
{
	dataSize = size;
	dataOffset = offset;
}

- (void)setType:(FVResourceType *)aType
{
	type = aType;
}

- (NSData *)data
{
	return [self.file dataForResource:self];
}

- (void)dealloc
{
	[name release];
	[super dealloc];
}

@end
