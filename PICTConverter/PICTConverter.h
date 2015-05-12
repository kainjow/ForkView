//
//  pictConverter2.h
//  pictConverter2
//
//  Created by C.W. Betts on 5/11/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PICTConverterProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface PICTConverter : NSObject <PICTConverterProtocol>
@end
