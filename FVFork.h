//
//  FVFork.h
//  ForkView
//
//  Created by Kevin Wojniak on 7/9/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	FVForkTypeData,
	FVForkTypeResource,
};
typedef NSInteger FVForkType;

@interface FVFork : NSObject
{
	FSIORefNum forkRef;
	FVForkType forkType;
}

- (id)initWithURL:(NSURL *)fileURL type:(FVForkType)theForkType;

- (off_t)length;
- (off_t)position;

- (BOOL)read:(size_t)size into:(void *)buffer;
- (BOOL)seekTo:(off_t)offset;

@property (readonly) FVForkType forkType;

@end
