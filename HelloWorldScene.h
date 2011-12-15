//
//  HelloWorldLayer.h
//  BetaDoll
//
//  Created by ran ; on 6/29/11.
//  Copyright seebo 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "dataBase.h"
#import "SoundSensor.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

// HelloWorld Layer
@interface HelloWorld : CCLayer < MFMailComposeViewControllerDelegate>
{
	MFMailComposeViewController *picker;
	NSString *basic_pic;	
    
}

@property (nonatomic, copy) NSString *basic_pic;
 
// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void)animation;
-(void)HardwareEvent:(NSMutableArray *)HardwareEvent;
-(void)sound;
-(NSString*)checkDataBase1:(NSMutableArray *)coordinates;
-(void)checkDataBase2:(NSString *)WhatEvent;
-(void)engine;
-(void)finishAnimation;
-(void)sevenSec;
-(void)EventList;
-(void)WriteToFile:(NSString *)event;

@end
