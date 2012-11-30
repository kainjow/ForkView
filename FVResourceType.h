//
//  FVResourceType.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FVResourceType : NSObject
{
	uint32_t type;
	uint32_t count;
	uint32_t offset;
	NSString *typeString;
}

@property (readonly) uint32_t type;
@property (readonly) uint32_t count;

@property (readonly) NSString *typeString;

@property (readonly) NSArray *resources;

@end
