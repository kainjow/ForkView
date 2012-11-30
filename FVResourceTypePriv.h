//
//  FVResourceType.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResourceType.h"

@interface FVResourceType (Private)

- (void)setType:(uint32_t)value;
- (void)setCount:(uint32_t)value;
- (void)setResources:(NSArray *)theResources;

@end

@interface FVResourceType ()

@property (readwrite) uint32_t offset;

@end
