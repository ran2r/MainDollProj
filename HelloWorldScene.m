//
//  HelloWorldLayer.m
//  BetaDoll
//
//  Created by ran turgeman on 6/29/11.
//  Copyright seebo 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "SimpleAudioEngine.h" //audio engine
#import "CDAudioManager.h"    //audio engine
#import "CocosDenshion.h"    //audio engine
#include <stdlib.h>

#define kAccelUpdate 30.0


dataBase *data;
CCSprite *b_pic;
CCSprite *background;
NSString *TouchEvent;  // for the touch
NSString *HardwareEvent; // the detector returns the hardware event name
NSMutableArray *rowInDataBase;
NSString *animation;
NSString *sound;
CGFloat x;
CGFloat y;
CGFloat xs;
CGFloat ys;
BOOL WeInAction=0;
NSMutableArray *triger;
CCTexture2D *texture;
SoundSensor *theInstance;
NSTimer *seven_sec;
NSTimer *two_sec;
NSString *event;
int count=0;
NSMutableArray *listOfEvents ;
BOOL moved=0;
CCSprite *sprite;
CCAnimate *Action ;
NSString *play;
ALuint soundEffectID;
NSString *parentMode;
NSMutableArray *memoryFile;
NSString *memory;
BOOL noOtherTouch=0;
NSString *previousAnimation;

// HelloWorld implementation
@implementation HelloWorld

@synthesize basic_pic;



+(id) scene
{
	//NSLog(@"scene");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	layer.tag=42;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	
	// return the scene
	return scene;
}









// on "init" you need to initialize your instance
-(id) init
{
    
	
	if( (self=[super init] ))  
	{
        self.isTouchEnabled = YES;	  
        
        [self engine];
		
            
		
	}
	
	return self;
    
    
}







-(void)engine
{
    
    
	
	
	//add the hairy brown background
	background=[CCSprite spriteWithFile:@"fur.png"];
	background.anchorPoint=CGPointMake(0, 0);
	[self addChild:background z:-1];
    
	
	
	
	//awake the data base
	data=[[dataBase alloc] init];
	[data setupDataBase];
	
    
	
    //blinking and random behavior
    seven_sec = [NSTimer scheduledTimerWithTimeInterval: 7.0 target: self selector: @selector(sevenSec) userInfo: nil repeats:YES]; //wait for start bit
	two_sec = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(twoSec) userInfo: nil repeats:YES]; //wait for start bit
	
	
	
	//read from db the current mode basic picture
	rowInDataBase=[data readMediaFromDatabase:@"check"]; //check in DB is event that every mode has to get the basic picture from it
	basic_pic=[rowInDataBase objectAtIndex:1] ;
	[data release];
	
    
	
	//show pic
	
	texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%@.png", basic_pic]];	
	b_pic = [CCSprite spriteWithTexture:texture ];
	b_pic.position=ccp(240,160); //160 175
	[self addChild:b_pic];
	[texture release];
	
	
	
	
	
	//array event needs to be alloc only once
	listOfEvents=[[NSMutableArray alloc] initWithCapacity:10];
	memoryFile=[[NSMutableArray alloc] init];
    //NSLog(@"%@",listOfEvents);
	
	
	
	//memory log to go to file-the headlines
	memory=@",Log-event,part,animation,sound,coordinates,date-time";
	[self WriteToFile:memory];
	
	
	
	//preload sound effects
	/* 
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"Angry.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"HiNaimLehakir.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"Smol2.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"Afraid.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"Enjoying5.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"ouch.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"DaiKvar.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"LaughingDana1.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"LaughingDana4.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"yawningpeleg2.wav"];
     [[SimpleAudioEngine sharedEngine] preloadEffect:@"Tongue1.wav"];
     */
	
}




-(void)twoSec
{
	//get the parent mode which is the next basic picture .
	NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDirectory = [arrayPaths objectAtIndex:0];
	NSString *filePath = [docDirectory stringByAppendingString:@"/File.txt"];
	parentMode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	
	
	
	animation=@"Raindeer_Eye_blinking" ;  //array count from index 0 and DB col starts from index1
	if( WeInAction==0 && ![parentMode isEqualToString:@"Sleep"])
	{
        //NSLog(@"2sec");	
        //NSLog(@"%s",[parentMode UTF8String]);	
        [self animation];	
	}
}



-(void)sevenSec
{
    
	
	//get the parent mode which is the next basic picture .
	NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *docDirectory = [arrayPaths objectAtIndex:0];
	NSString *filePath = [docDirectory stringByAppendingString:@"/File.txt"];
	parentMode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	
	
	
	
	if( WeInAction==0 && ![parentMode isEqualToString:@"Sleep"])
	{
		
		triger = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 8] , [NSString stringWithFormat: @"%d", 0] , nil];
		
		
		memory=[NSString stringWithFormat:@",Idle Event,"];   
		TouchEvent=[self checkDataBase1:triger];
		NSLog(@"%@",TouchEvent);
		[data release];
		if(TouchEvent != NULL )
            [self checkDataBase2:TouchEvent];
        
		
	}
	
}


 



//handle touch event on screen

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	
	
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView: [touch view]]; 
	x = fabsf(currentPosition.x) ; 
	y = fabsf(currentPosition.y) ; 
	NSLog(@"%f",x);	
	NSLog(@"%f",y);	
	xs=x;
	ys=y;
	
	//we convert coordinates to strings in the array.
	triger = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%f", x] , [NSString stringWithFormat: @"%f", y] , nil];
	
	
    
    TouchEvent=[self checkDataBase1:triger];
    [data release];
	
    if(TouchEvent != NULL )
    {
        //memory string log to go to file
        memory=[NSString stringWithFormat:@",Touch Event,%@",TouchEvent];   
        [self checkDataBase2:TouchEvent];
        noOtherTouch=1;
    }
	
    else
    {	
        memory=[NSString stringWithFormat:@",Touch Event,%@otherHead"];   
        [self checkDataBase2:@"petHead"];
        
        //memory log to go to file-other coordinates touches-we are writing to file no -no db2 function pass.
        memory=[NSString stringWithFormat:@",Touch Event,screen,,,X:%i Y:%i",(int)x,(int)y];   
        [self WriteToFile:memory]; 
        
       
      
        
    }
}








//when swap finger doll feels it
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView: [touch view]]; 
	x = fabsf(currentPosition.x) ; 
	y = fabsf(currentPosition.y) ; 
	
   	if( (  fabsf(x-xs)>30 || fabsf(y-ys)>30   ) && noOtherTouch==0  ) //swap finger have animation
	{
		moved=1;		
	}
    
}




- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if(moved==1 && y>60 && x<270)
    {
        moved=0;
        triger = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 2] , [NSString stringWithFormat: @"%d", 0] , nil];
        TouchEvent=[self checkDataBase1:triger];
        [data release];
        NSLog(@"%@",TouchEvent);
        memory=[NSString stringWithFormat:@",Touch Event,%@",TouchEvent]; 
        if(TouchEvent != NULL )
            [self checkDataBase2:TouchEvent];
      
    }
	
    
	else if(moved==1 && y<60 && x>270)
	{
		
		//send email log-------------------------
		NSLog(@"mail");
		[[CCDirector sharedDirector] pause];
		
		picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		//Fill in the email as you see fit
		NSArray *toRecipients = [NSArray arrayWithObject:@"yarden.h@seebo.com"]; 
		[picker setToRecipients:toRecipients];
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BetaTest.txt"];
		NSData *data = [NSData dataWithContentsOfFile:dataPath];
		[picker addAttachmentData:data mimeType:@"text/txt" fileName:@"BetaTest.txt"];
		
		NSString *emailBody = @"Doll test:) ";
		[picker setMessageBody:emailBody isHTML:NO];
		[picker setSubject:@"Doll test##"];
        
		//display the view
		[[[CCDirector sharedDirector] openGLView] addSubview:picker.view];
		[[CCDirector sharedDirector] stopAnimation]; 		
		moved=0;
		
    
		
		
	}
    
    
    
    /*
    else if(moved==0 && noOtherTouch==0 ) //touched somewhere else
    {
        triger = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 2] , [NSString stringWithFormat: @"%d", 0] , nil];
        TouchEvent=[self checkDataBase1:triger];
        [data release];
        NSLog(@"%@",TouchEvent);
        if(TouchEvent != NULL )
            [self checkDataBase2:TouchEvent];
            
    }
    */
    
    noOtherTouch=0;
	
}







//handle hardware events - physical
-(void)HardwareEvent:(NSMutableArray *)HardwareEvent
{
	
    /*
	if(WeInAction==1)
	{
		[sprite stopAllActions];
	    [[SimpleAudioEngine sharedEngine] stopEffect:soundEffectID];
		[sprite runAction:[CCHide action]];
		[self finishAnimation];
        
	}
	*/
	
	
	
	TouchEvent=[self checkDataBase1:HardwareEvent];
	[data release];
	
	
	
	if(TouchEvent != NULL )
	{
		
        //memory log to go to file
        memory=[NSString stringWithFormat:@",Sensor Event,%@",TouchEvent];		
        [self checkDataBase2:TouchEvent];	
        
	}
	
}










// get the event (hardware/touch/timers/gyro) and check for DB to get media and then call it .
-(NSString*)checkDataBase1:(NSMutableArray *)coordinates
{
	
	//awake the data base
	data=[[dataBase alloc] init]; //beacuse we release it in deloac
	[data setupDataBase];
	event=[data readEventFromDatabase:coordinates];
	
	//write the event array
	if(event!=NULL)
        [self EventList];
	
	
	
	return event;
	
}







// get the media according to event from table1 .
-(void)checkDataBase2:(NSString *)WhatEvent
{
    
	
	//awake the data base
	data=[[dataBase alloc] init]; //beacuse we release it in deloac
	[data setupDataBase];
	rowInDataBase=[data readMediaFromDatabase:WhatEvent];
	
	
	
	//isEqualToString
	//get animation and sound
	animation=[rowInDataBase objectAtIndex:2] ;  //array count from index 0 and DB col start  from index1
	sound=[rowInDataBase objectAtIndex:3] ; 
	NSLog(@"animation:%@",animation);
    NSLog(@"previous-animation:%@",previousAnimation);
	NSLog(@"sound:%@",sound);
    NSLog(@"%d",WeInAction);
	
	if(WeInAction==1 && ![previousAnimation isEqualToString: animation] ) // if we press on same hand twice-DO NOT stop that animation in the middle.
	{
        NSLog(@"running1");
		[sprite stopAllActions];
		[[SimpleAudioEngine sharedEngine] stopEffect:soundEffectID];
		[sprite runAction:[CCHide action]];
		[self finishAnimation];
        
        if(animation!=NULL)
        {
            
            [self animation];
            [self sound];
            [data release]; 
        }
        
	}
	 
     
	
    else if( WeInAction==0 && animation!=NULL)  //regular operation-not in the middle of somthing
	{
        NSLog(@"running2");
        [self animation];
        [self sound];
        [data release]; 
	}
    
    
    previousAnimation=[animation copy]; //hard copy-so if somewhere animation changes-here will not
    
	//write to log file the app decision
	memory=[memory stringByAppendingString:[NSString stringWithFormat:@",%@,%@,",animation,sound]]; 
	[self WriteToFile:memory];
   
}



-(void)animation
{
    
  
	//to show nothing befor animation start, because otherwise we will have the background and on it the animation .
    WeInAction=1;
	CCTexture2D *texmex = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"nil.png"]];
	[b_pic setTexture: texmex];		
	[texmex release];
	//
    
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",animation]];
	sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_00000.png",animation]]; //take the corrdinates of this picture from the plist
	
	sprite.position=ccp(240,160);
	//sprite.position=ccp(160,175);
    
	CCSpriteBatchNode *spriteSheet = [ CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",animation]];
	[spriteSheet addChild:sprite]; //add this coordinates from the spritesheet to the screen
	[self addChild:spriteSheet];
	
	
	NSString *Path = [[NSBundle mainBundle] bundlePath];
	NSString *animPath = [Path stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.plist", animation]];
	NSDictionary *animSpriteCoords = [[NSDictionary alloc] initWithContentsOfFile: animPath];
	NSDictionary *animFramesData = [animSpriteCoords objectForKey:@"frames"];
    int b=0;
	int a=0;
	NSMutableArray *animFrames = [NSMutableArray array];
	for(int i = 1; i < [animFramesData count]; i++) 
        
	{
		a=a+1;
		if(a==10)
		{
			b=b+1;
		    a=0;
		}
		
        
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_000%0i%1i.png",animation,b,a]];   //[NSString stringWithFormat:@"eye_blinking_0000%1d.png",i]
		[animFrames addObject:frame];
	}
	
    
	//CCAnimation *dollAnimation = [CCAnimation animation];
	CCAnimation* dollAnimation = [CCAnimation animationWithFrames:animFrames delay:0.1f];
	//CCAnimation *dollAnimation = [CCAnimation animationWithName:@"dance" animationWithFrames:animFrames];
	//[dollAnimation setDelay:0.1f];
	Action = [CCAnimate actionWithAnimation:dollAnimation];
	id call=[CCCallFunc actionWithTarget:self selector:@selector(finishAnimation)];
	id sequence=[CCSequence actions:Action,[CCHide action],call,nil];
	[sprite runAction:sequence];
    
	
	
	
	
}





//basic picture is sleep in db2 method,and here its becomes regular. its being changed somewhere because its not null
//problem : mitzmuz !! is take basic pic to be regular !!
//look all over for basic pic that changing in parrallel


-(void)finishAnimation
{ 
    NSLog(@"FINISHANIMATION");
    WeInAction=0;
	//get the parent mode which is the next basic picture .
	NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docDirectory = [arrayPaths objectAtIndex:0];
	NSString *filePath = [docDirectory stringByAppendingString:@"/File.txt"];
	parentMode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	
	
    
	//NSLog(@"%s",[basic_pic UTF8String]); 
	CCTexture2D *texmex = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:parentMode]];
	[b_pic setTexture: texmex];
	[texmex release];
	
	
	//initialize the timer
	//[seven_sec invalidate];
	//seven_sec = [NSTimer scheduledTimerWithTimeInterval: 4.0 target: self selector: @selector(sevenSec) userInfo: nil repeats:YES]; //wait for start bit
	
	
	
}


//






-(void)sound
{
	//UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	//AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);    
	//UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	//AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);	
	
	//to let the audio input be avaluable !
	[CDAudioManager initAsynchronously: kAMM_PlayAndRecord];
	
    
	play=[NSString stringWithFormat:@"%@.wav",sound];
	soundEffectID=[[SimpleAudioEngine sharedEngine] playEffect:play];
    
}







//write to file function
-(void)WriteToFile:(NSString *)event
{
    
	//event gets the value of the string memory,which is like that: if hardware event happened it gets hardware event value,if touched event happened it gets touched value.
	NSString *memoryString = event ;
	
	NSString *WhatsTheTimeNow ;
	NSDate *myDate = [NSDate date]; 
	NSDateFormatter *df = [NSDateFormatter new]; 
	[df setDateFormat:@",hh:mm:ss:yyyy:MMMM:dd"]; 
	WhatsTheTimeNow = [df stringFromDate:myDate];
	[df release];
	memoryString=[memoryString stringByAppendingString:WhatsTheTimeNow]; 
	if(memoryString!=NULL )
        [memoryFile addObject:memoryString];
	
	//NSLog(@"memoryFile:%@",memoryFile);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];	
	NSString *fullFileName = [NSString stringWithFormat:@"%@/BetaTest.txt", documentsDirectory];
	[memoryFile writeToFile:fullFileName atomically:NO];
    
}







-(void)EventList
{
    
	if (count > 9) 
	{
		[listOfEvents removeObjectAtIndex: 0];
        [listOfEvents addObject: event];
	}
    
	else
		[listOfEvents addObject:event];
	
	count++;
	
	//NSLog(@"%@",listOfEvents);
	
	
	
	
	
	//rules of arrays:
	//you can add values only to the next index,so if we just fill index n , next will be n+1 only. not n+2
	//if you add value to a full index,it will push it up,so if index 9 has a value and i insert a new,the new will be at 9 and previous at 10(array will grow)
	//if i erased index 0  , all the array is auto shifting right by one .	
}








// on "dealloc" you need to release all your retained objects
- (void) dealloc
{	
	NSLog(@"dealloc");
	
	[memoryFile release];
	[listOfEvents release];
	[SimpleAudioEngine end];	
	[super dealloc];
}






@end






// right eye ------ left eye
//----------nose------------












/*
 -(void)animation
 {	
 
 WeInAction=1;	
 //[b_pic.parent removeChild:b_pic cleanup:YES];	
 //[[CCTextureCache sharedTextureCache] removeTexture:b_pic.texture];
 
 
 
 //animation
 CCSpriteBatchNode *spriteSheet = [ CCSpriteBatchNode batchNodeWithFile:animation];	
 [self addChild:spriteSheet];
 
 CCSprite *dollSprite = [CCSprite spriteWithTexture:spriteSheet.texture rect:CGRectMake(0, 0, 320, 350)];
 [spriteSheet addChild:dollSprite];
 spriteSheet.anchorPoint=CGPointMake(0, 30);
 
 CGSize s = [[CCDirector sharedDirector] winSize];
 dollSprite.position = ccp(s.width/2,s.height/2);
 
 CCAnimation *dollAnimation = [CCAnimation animation];
 [dollAnimation setDelay:0.1f];
 
 int frameCount = 0;
 for (int y = 0; y < 5; y++)      //cocos add all this frames to memery and then he starts down the action, 
 
 {
 
 for (int x = 0; x < 6; x++) 
 {
 
 CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:spriteSheet.texture rect:CGRectMake(x*320,y*350,320,350)];
 [dollAnimation addFrame:frame];
 frameCount++;
 
 if (frameCount == 25)
 break;
 
 }
 }
 
 
 
 
 CCAnimate *Action = [CCAnimate actionWithAnimation:dollAnimation];
 id call=[CCCallFunc actionWithTarget:self selector:@selector(finishAnimation)];
 id sequence=[CCSequence actions:Action,[CCHide action],call,nil];
 [dollSprite runAction:sequence];
 NSLog(@"%@",basic_pic); 
 
 }
 
 
 */






/*
 
 WeInAction=1;	
 [b_pic.parent removeChild:b_pic cleanup:YES];	
 
 //get plist
 [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"head.plist" ];
 
 //animation
 CCSpriteBatchNode *spriteSheet = [ CCSpriteBatchNode batchNodeWithFile:animation];	
 [self addChild:spriteSheet];
 
 NSMutableArray *frames=[NSMutableArray array];
 for(int i=1; i<=50; i++)
 {
 [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"head%d.png",i]]];
 }
 
 CCAnimation *dollAnimation = [CCAnimation animation];
 [dollAnimation setDelay:0.1f];
 
 CGSize s = [[CCDirector sharedDirector] winSize];
 
 
 
 CCSprite *dollSprite = [CCSprite spriteWithTexture:spriteSheet.texture rect:CGRectMake(0, 0, 320, 340)];
 dollSprite.position = ccp(s.width/2,s.height/2);
 [spriteSheet addChild:dollSprite];
 //danceSprite.anchorPoint=CGPointMake(0, 0);
 
 
 
 CCAnimate *Action = [CCAnimate actionWithAnimation:dollAnimation];
 //CCRepeatForever *repeat = [CCRepeatForever actionWithAction:danceAction];
 [dollSprite runAction:Action];
 
 */
