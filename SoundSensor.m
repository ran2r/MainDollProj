//
//  SoundSensor.m
//  detector
//
//  Created by ran turgeman on 5/31/11.
//  Copyright 2011 seebo. All rights reserved.
//



#import "SoundSensor.h"

@interface SoundSensor (Private)

- (void)updateLevels;
- (void)setupQueue;
- (void)setupFormat;
- (void)setupBuffers;
- (void)setupMetering;

@end

static SoundSensor *sharedListener = nil;

static void listeningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketsDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
    NSLog(@"listeningCallback "); 
	SoundSensor *listener = (SoundSensor *)inUserData;
	if ([listener isListening])
		AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
}

@implementation SoundSensor

+ (SoundSensor *)sharedListener {
	@synchronized(self) {
		if (sharedListener == nil)
			[[self alloc] init];
	}
	NSLog(@"sharedListener ");
	return sharedListener;
}

- (void)dealloc {
	[sharedListener stop];
	[super dealloc];
}

#pragma mark -
#pragma mark Listening

- (void)listen {
	NSLog(@"listen");
	if (queue == nil)
		[self setupQueue];
	AudioQueueStart(queue, NULL);
}

- (void)pause {
	NSLog(@"pause  ");
	if (![self isListening])
		
		return;
	
	AudioQueueStop(queue, true);
}

- (void)stop {
	NSLog(@"stop  ");
	if (queue == nil)
		return;
	
	AudioQueueDispose(queue, true);
	queue = nil;
}

- (BOOL)isListening {
	if (queue == nil)
		return NO;
	
	UInt32 isListening, ioDataSize = sizeof(UInt32);
	OSStatus result = AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &isListening, &ioDataSize);
	return (result != noErr) ? NO : isListening;
}

#pragma mark -
#pragma mark Levels getters

- (Float32)averagePower {	
	if (![self isListening])
		return 0.0;
	float tmp = [self levels][0].mAveragePower;
	tmp = tmp * 100;	
	return tmp;
}

- (Float32)peakPower {
	if (![self isListening])
		return 0.0;
	
	return [self levels][0].mPeakPower;
}

- (AudioQueueLevelMeterState *)levels {
	if (![self isListening])
		return nil;
	
	[self updateLevels];
	return levels;
}

- (void)updateLevels {
	UInt32 ioDataSize = format.mChannelsPerFrame * sizeof(AudioQueueLevelMeterState);
	AudioQueueGetProperty(queue, (AudioQueuePropertyID)kAudioQueueProperty_CurrentLevelMeter, levels, &ioDataSize);
}

#pragma mark -
#pragma mark Setup

- (void)setupQueue {
	NSLog(@"setupQueue");
	if (queue)
		return;
	
	[self setupFormat];
	[self setupBuffers];
	AudioQueueNewInput(&format, listeningCallback, self, NULL, NULL, 0, &queue);
	[self setupMetering];	
}

- (void)setupFormat {
	NSLog(@"setupFormat ");
#if TARGET_IPHONE_SIMULATOR
	format.mSampleRate = 44100.0;
#else
	UInt32 ioDataSize = sizeof(sampleRate);
	AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &ioDataSize, &sampleRate);
	format.mSampleRate = sampleRate;
#endif
	format.mFormatID = kAudioFormatLinearPCM;
	format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	format.mFramesPerPacket = format.mChannelsPerFrame = 1;
	format.mBitsPerChannel = 16;
	format.mBytesPerPacket = format.mBytesPerFrame = 2;
}

- (void)setupBuffers {
	NSLog(@"setupBuffers ");
	AudioQueueBufferRef buffers[3];
	for (NSInteger i = 0; i < 3; ++i) { 
		AudioQueueAllocateBuffer(queue, 735, &buffers[i]); 
		AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL); 
	}
}

- (void)setupMetering {
	NSLog(@"setupMetering");
	levels = (AudioQueueLevelMeterState *)calloc(sizeof(AudioQueueLevelMeterState), format.mChannelsPerFrame);
	UInt32 trueValue = true;
	AudioQueueSetProperty(queue, kAudioQueueProperty_EnableLevelMetering, &trueValue, sizeof(UInt32));
}

#pragma mark -
#pragma mark Singleton Pattern

+ (id)allocWithZone:(NSZone *)zone {
	NSLog(@"allocWithZone");
	@synchronized(self) {
		if (sharedListener == nil) {
			sharedListener = [super allocWithZone:zone];
			return sharedListener;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	NSLog(@"copyWithZone");
	return self;
}

- (id)init {
	if ([super init] == nil)
		return nil;
	
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (void)release {
	// Do nothing.
}

- (id)autorelease {
	return self;
}

@end
