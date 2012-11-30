//
//  FVResourceFilePriv.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResourceFile.h"

@interface FVResourceFile (Data)

- (NSData *)dataForResource:(FVResource *)resource;

@end

