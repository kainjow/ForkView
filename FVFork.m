//
//  FVFork.m
//  ForkView
//
//  Created by Kevin Wojniak on 7/9/11.
//  Copyright 2011-2012 Kevin Wojniak. All rights reserved.
//

#import "FVFork.h"
#import "ForkView-Swift.h"

@implementation FVFork
{
    FVDataReader *dataReader_;
    FVForkType type_;
}

@synthesize type = type_;

- (instancetype)initWithURL:(NSURL *)fileURL type:(FVForkType)type
{
    FVDataReader *reader = [FVDataReader dataReader:fileURL resourceFork:type == FVForkTypeResource];
    if (reader == nil) {
        return nil;
    }
    
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
    dataReader_ = reader;
	type_ = type;
	
	return self;
}

- (unsigned)length
{
    return (unsigned)dataReader_.length;
}

- (unsigned)position
{
    return (unsigned)dataReader_.position;
}

- (BOOL)read:(unsigned)size into:(void*)buffer
{
    NSData *data = [dataReader_ read:size];
    if (data == nil) {
        return NO;
    }
    [data getBytes:buffer range:NSMakeRange(0, size)];
	return YES;
}

- (BOOL)seekTo:(unsigned)offset
{
    return [dataReader_ seekTo:offset];
}

@end
