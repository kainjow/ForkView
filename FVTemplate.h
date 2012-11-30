//
//  FVTemplate.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResource.h"
#import "FVResourceType.h"

@class FVResource;

@protocol FVTemplate

- (id)initWithResource:(FVResource *)resource;

- (NSView *)view;

+ (NSString *)UTTypeForResource:(FVResource *)resource;

@end
