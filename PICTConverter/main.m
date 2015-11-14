//
//  main.m
//  PICTConverter
//
//  Created by C.W. Betts on 5/11/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PICTConverter.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate> {
    PICTConverter *converter_;
}
@end

@implementation ServiceDelegate

- (instancetype)init {
    if ((self = [super init]) != nil) {
        converter_ = [PICTConverter new];
    }
    return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(PICTConverterProtocol)];
    newConnection.exportedObject = converter_;
    [newConnection resume];
    return YES;
}

@end

int main(int argc, const char *argv[]) {
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    
    [delegate release];
    
    return 0;
}
