//
//  FVResourceType.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResourceType.h"
#import "FVResourceTypePriv.h"

@implementation FVResourceType

@synthesize type, count, offset, resources;

- (void)setType:(uint32_t)value
{
	type = value;
}

- (void)setCount:(uint32_t)value
{
	count = value;
}

- (void)setResources:(NSArray *)theResources
{
	if (resources != theResources) {
        resources = theResources;
	}
}

- (NSString *)typeString
{
	if (typeString == nil) {
		typeString = [[NSString alloc] initWithFormat:@"%c%c%c%c",
					  (type & 0xFF000000) >> 24,
					  (type & 0x00FF0000) >> 16,
					  (type & 0x0000FF00) >> 8,
					  (type & 0x000000FF)];
	}
	return typeString;
}

@end
