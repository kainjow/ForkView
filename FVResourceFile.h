//
//  FVResourceFile.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FVFork.h"

typedef struct FVResourceHeader FVResourceHeader;
typedef struct FVResourceMap FVResourceMap;

@interface FVResourceFile : NSObject
{
	FVFork *fork;
	FVResourceHeader *header;
	FVResourceMap *map;
	NSArray *types;
}

+ (instancetype)resourceFileWithContentsOfURL:(NSURL *)fileURL error:(NSError **)error;

@property (readonly) NSArray *types;

@property (readonly) FVForkType forkType;

@end
