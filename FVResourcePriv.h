//
//  FVResourcePriv.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResource.h"

@interface FVResource (Private)

- (void)setID:(uint16_t)anID;
- (void)setName:(NSString *)aName;
- (void)setDataSize:(uint32_t)size offset:(uint32_t)offset;
- (void)setType:(FVResourceType *)aType;

@end

@interface FVResource ()

@property (readwrite, assign) FVResourceFile *file;

@end
