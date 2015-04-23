//
//  FVWindowController.h
//  ForkView
//
//  Created by Kevin Wojniak on 8/16/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FVTableView.h"

@interface FVWindowController : NSWindowController <FVTableViewDelegate>
{
	IBOutlet NSArrayController *resourcesArrayController;
	NSMutableArray *windowControllers;
}

@end
