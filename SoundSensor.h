//
//  SoundSensor.h
//  detector
//
//  Created by ran turgeman on 5/31/11.
//  Copyright 2011 seebo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundSensor : NSObject {
	AudioQueueLevelMeterState *levels;
	
	AudioQueueRef queue;
	AudioStreamBasicDescription format;
	Float64 sampleRate;
}

+ (SoundSensor *)sharedListener;

- (void)listen;
- (BOOL)isListening;
- (void)pause;
- (void)stop;

- (Float32)averagePower;
- (Float32)peakPower;
- (AudioQueueLevelMeterState *)levels;

@end
