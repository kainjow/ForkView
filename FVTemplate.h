//
//  FVTemplate.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <AppKit/AppKit.h>

@class FVResource;

@protocol FVTemplate <NSObject>

- (instancetype)initWithResource:(FVResource *)resource;

- (NSView *)view;

@end
