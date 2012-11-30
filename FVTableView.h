//
//  FVTableView.h
//  ForkView
//
//  Created by Kevin Wojniak on 7/13/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FVTableView : NSTableView

@end

@interface NSObject (FVTableViewDelegate)

- (NSMenu *)tableViewMenuForSelection;

@end
