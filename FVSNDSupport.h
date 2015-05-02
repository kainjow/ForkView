//
//  FVSNDSupport.h
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#ifndef __ForkView__FVSNDSupport__
#define __ForkView__FVSNDSupport__

#include <AudioToolbox/AudioToolbox.h>

OSStatus FVAudioQueueNewOutput(const AudioStreamBasicDescription *inFormat, AudioQueueRef *outAQ);

#endif /* defined(__ForkView__FVSNDSupport__) */
