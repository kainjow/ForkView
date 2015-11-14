//
//  PICTConverterProtocol.h
//  PICTConverter
//
//  Created by C.W. Betts on 5/11/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PICTConverterProtocol

- (void)convertPICTDataToTIFF:(nonnull NSData *)pictData withReply:(nonnull void (^)(NSData * __nullable))reply;
    
@end
