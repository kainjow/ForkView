//
//  FVResource.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FVResourceFile;
@class FVResourceType;

@interface FVResource : NSObject
{
	uint16_t ident;
	NSString *name;
	uint32_t dataSize;
	uint32_t dataOffset;
	FVResourceType *type;
	FVResourceFile *file;
}

@property (readonly) FVResourceType *type;

@property (readonly) uint16_t ident;
@property (readonly) NSString *name;
@property (readonly) uint32_t dataSize;
@property (readonly) uint32_t dataOffset;

@property (readonly) NSData *data;

@end
