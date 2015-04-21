//
//  FVFork.h
//  ForkView
//
//  Created by Kevin Wojniak on 7/9/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FVForkType) {
	FVForkTypeData,
	FVForkTypeResource,
};

@interface FVFork : NSObject
{
    NSData *data_;
	FVForkType type_;
    unsigned pos_;
}

- (instancetype)initWithURL:(NSURL *)fileURL type:(FVForkType)type;

- (BOOL)read:(unsigned)size into:(void*)buffer;
- (BOOL)seekTo:(unsigned)offset;

@property (readonly) unsigned length;
@property (readonly) unsigned position;
@property (readonly) FVForkType type;

@end
