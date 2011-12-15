//
//  detectorViewController.h
//  detector
//
//  Created by ran turgeman on 5/31/11.
//  Copyright 2011 seebo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SoundSensor.h"
#import<AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import "HelloWorldScene.h" 
#import <CoreMotion/CoreMotion.h>



@class SoundSensor;

@interface detectorViewController : UIViewController
{
	CMMotionManager *motionManager;
	CMAttitude *referenceAttitude;
    
	HelloWorld  *ran;
	
    
}

@property (nonatomic,retain)UIImageView *imageView;
//@property(nonatomic,retain) MPMoviePlayerController *moviePlayer; 
-(void)CheckFullByth;
-(void)GetNumber;
-(void)waitForStartBit;
-(void)CheckData;

- (void)levelTimerCallback:(NSTimer *)timer ;
@end

