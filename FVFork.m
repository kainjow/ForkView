//
//  FVFork.m
//  ForkView
//
//  Created by Kevin Wojniak on 7/9/11.
//  Copyright 2011-2012 Kevin Wojniak. All rights reserved.
//

#import "FVFork.h"
#include <sys/stat.h>
#include <sys/xattr.h>

// Apple's docs say "The maximum size of the resource fork in a file is 16 megabytes"
#define FVFORK_MAX_RESOURCE_FORK_SIZE 16777216
#define FVFORK_RESOURCE_NAME "com.apple.ResourceFork"

@implementation FVFork
{
    NSData *data_;
    FVForkType type_;
    unsigned pos_;
}

@synthesize type = type_;
@synthesize position = pos_;

+ (NSData*)forkDataForFile:(NSString*)file type:(FVForkType)type
{
    const char *path = [file fileSystemRepresentation];
    struct stat sb;
    if (stat(path, &sb) != 0) {
        // Can't get file information
        return nil;
    }
    if (sb.st_size > FVFORK_MAX_RESOURCE_FORK_SIZE) {
        return nil;
    }
    if (type == FVForkTypeData) {
        return [NSData dataWithContentsOfFile:file];
    }
    ssize_t rsrcSize = 0;
    rsrcSize = getxattr(path, FVFORK_RESOURCE_NAME, NULL, 0, 0, 0);
    if (rsrcSize <= 0 || rsrcSize > FVFORK_MAX_RESOURCE_FORK_SIZE) {
        return nil;
    }
    NSMutableData *data = [NSMutableData dataWithLength:rsrcSize];
    if (getxattr(path, FVFORK_RESOURCE_NAME, [data mutableBytes], rsrcSize, 0, 0) != rsrcSize) {
        // ??? shouldn't happen
        return nil;
    }
    return data;
}

- (instancetype)initWithURL:(NSURL *)fileURL type:(FVForkType)type
{
    NSData *forkData = [[self class] forkDataForFile:[fileURL path] type:type];
    if (forkData == nil) {
        return nil;
    }
    
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
    data_ = forkData;
	type_ = type;
	
	return self;
}

- (unsigned)length
{
    return (unsigned)[data_ length];
}

- (BOOL)read:(unsigned)size into:(void*)buffer
{
    if (pos_ + size > self.length) {
        return NO;
    }
    [data_ getBytes:buffer range:NSMakeRange(pos_, size)];
    pos_ += size;
	return YES;
}

- (BOOL)seekTo:(unsigned)offset
{
    if (offset >= self.length) {
        return NO;
    }
    pos_ = offset;
	return YES;
}

@end
