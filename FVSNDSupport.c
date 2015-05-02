//
//  FVSNDSupport.c
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#include "FVSNDSupport.h"

static void callback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    OSStatus status = AudioQueueStop(inAQ, true);
    if (status != noErr) {
        printf("AudioQueueStop: %ld\n", (long)status);
    }
}

OSStatus FVAudioQueueNewOutput(const AudioStreamBasicDescription *inFormat, AudioQueueRef *outAQ ) {
    return AudioQueueNewOutput(inFormat, callback, NULL, NULL, NULL, 0, outAQ);
}
