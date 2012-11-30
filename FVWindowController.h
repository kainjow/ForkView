//
//  FVWindowController.h
//  ForkView
//
//  Created by Kevin Wojniak on 8/16/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FVWindowController : NSWindowController
{
	IBOutlet NSArrayController *resourcesArrayController;
	NSMutableArray *windowControllers;
}

@end
