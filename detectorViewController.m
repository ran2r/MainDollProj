//
//  detectorViewController.m
//  detector
//
//  Created by ran turgeman on 5/31/11.
//  Copyright 2011 seebo. All rights reserved.



#import "detectorViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#define kAccelUpdate 30.0 //gyro


@implementation detectorViewController
@synthesize imageView;

NSTimer *levelTimer;
NSTimer *samplerTimer;
NSTimer *callerTimer;
Float32 tmp ;
SoundSensor *theInstance;
NSDate *start;
NSTimeInterval duration;
int flag=1;
int firstTime=1;
double LowPass;
int DontInterruptAnimation=0;
int  BitIndex=1; 
BOOL bit=1;
BOOL bit1=0;
BOOL bit2=0;
BOOL bit3=0;
BOOL bit4=0;
BOOL process=NO;
BOOL openBit=1; 
BOOL changed=0;
BOOL noChange=0;
NSMutableArray *DollPart;
int previousSample=100;

BOOL weOnHundred=0;
BOOL TimerIsOn=0;
BOOL weGotWord=0;
BOOL lowToHigh=0;
int countChanges=0;

float deltaX;
float deltaY;
float deltaZ;
float gyroX;
float gyroY;
float gyroZ;
float PregyroX;
float PregyroY;
float PregyroZ;
NSMutableArray *gyro;
BOOL gyroTimer=0;;
int nx=0;
int nx_N=0;
int n_right=0;
int n_left=0;
int ny=0;
int nz=0;
int backTime=0;
int faceTime=0;
BOOL waitForGyroDbounce=0;
BOOL faceUp=0;
BOOL firstLay=0;
CMRotationRate rotate ;


//-----------------------------------------------wait for start bit,check changes,determine sample rate and change it--------------------------


-(void)waitForStartBit
{
    
	tmp = [theInstance averagePower ];
    
	//NSLog(@"%f",tmp);
	//  NSLog(@"%d",countChanges);
	
	
	
	//---------checek if there is a changed on bits--------
	
	if(tmp==100 && weOnHundred==0 )//change from 0 to 1	
	{
		weOnHundred=1;
	    changed=1;
		lowToHigh=1;
	}
	else 
		changed=0; 	
	
	
	
	if(tmp<100 && weOnHundred==1) //change from 1 to 0
	{
		changed=1;
	    weOnHundred=0;
		lowToHigh=0;
	}
	
	
	//---------when signal is ended with 1 ,mcu is take it down after a while(in order to start next signal from 0) and we DONT count that fall.
	if(weGotWord==1 && lowToHigh==0)
	{
		weGotWord=0;
		changed=0;
	}
    
	
    
	if(changed==1)
	{
		countChanges++;
		
		if(TimerIsOn==1)
		{
            [samplerTimer invalidate];
            TimerIsOn=0;
		}
		
		samplerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.050f target: self selector: @selector(CheckData) userInfo: nil repeats: NO];
		TimerIsOn=1;
	}
	
    
    
    
	
	
	
	/*
	 
	 
     //-----------------------------------------------
     
     
     if(process==NO && changed==1)
     process=YES;
     
     
     
     
     
     //--------synchronizer on a change - 10ms after a change we sample and when no change we turn on the regular sampler-----------
     
     if(changed==1)
     {
     
     if(TimerIsOn==1)
     {
     [callerTimer invalidate];
     TimerIsOn=0;
     }
     
     samplerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.010f target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: NO];
     //[self levelTimerCallback];
     
     }
     
     
     //---------------------------------------------------------------------------------
     
     
	 
	 */
	
	
	
}







-(void)CheckData
{
	if(lowToHigh==1)
        weGotWord=1;
	else
        weGotWord=0;
	
	NSLog(@"%d",countChanges);
	
	//SENSORS
	if(countChanges==1)
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 6] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if (countChanges==2)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 3] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if(countChanges==3)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 2] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if(countChanges==4)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 4] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if(countChanges==5)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 5] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if (countChanges==6)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 1] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    else if (countChanges==7)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 2] , [NSString stringWithFormat: @"%d", 0] , nil];
    
    else if (countChanges==8)
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 3] , [NSString stringWithFormat: @"%d", 0] , nil];
    
    else       //ERROR IN DIGITAL
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 6] , [NSString stringWithFormat: @"%d", 0] , nil];
	
    
    
	//call cocos hardware
	[(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
    
    
    
	countChanges=0;
	TimerIsOn=0;
}
































//---------------------------------------------------------we start sampling routin every (50ms)---------------------------------------------

-(void)sampler

{		
    
    callerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.050f target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	TimerIsOn=1;
    
}
//-----------------------------------------------------------------------------------------------------------------------------------------------




//--------------------------------------------------------while sampling we check and save each data bit-------------------------------

- (void)levelTimerCallback:(NSTimer *)timer 



{  
    
	
	
    
	
	if((  changed==0) && (BitIndex!=4) && (TimerIsOn==0) )  // we turn on the regular sampler again 
		[self sampler];
    //samplerTimer = [NSTimer scheduledTimerWithTimeInterval: 0.00f target: self selector: @selector(sampler) userInfo: nil repeats: NO];	
    
	
	if(BitIndex==4 && TimerIsOn==1) // if we finish 4 bits word with zero ,we need to turn the data sampler off
    {
        [callerTimer invalidate];
        
        TimerIsOn=0;
    }
    
	
    
    tmp = [theInstance averagePower ];
    
    // NSLog(@"%f", tmp);
    firstTime=1; // to not go in the same call from 5 to 1 in the process!
    
	if (tmp ==100)	
        bit=1;
	else 
        bit=0;
    
    
	
	[self CheckFullByth];
	
    
}

//---------------------------------------------------------------------------------------------------------------------------------------




//---------------------------save bits,and check full byth(after Open bit) -------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------


-(void)CheckFullByth
{
    if(process==YES)
        
    {
        
        
        
        if( BitIndex==4)            //forth bit and 
        {
            weGotWord=1;
            bit4=bit;
            BitIndex=1;
            firstTime=0;
            process=NO;
            weOnHundred=0;
            [self GetNumber];
            
            
            
        }
        
        
        
        
        
        
        if( BitIndex==3)             //third bit 
        {
            bit3=bit;
            BitIndex=4;
			
        }
        
        
        
        
        
        
        if( BitIndex==2)            //second bit 
        {
            bit2=bit;
            BitIndex=3;
			
        }
        
        
        
        
        
        
        if (BitIndex==1 && firstTime==1) //first data bit, we get it after open bit
        {
            bit1=bit;
            BitIndex=2;
            openBit=0;
			
        }
        
    }
    
    
}                                  	// bit1 ,bit2, bit3, bit4---- 1011 -------



//---------------------------------------------------------------------------------------------------



//---------------------------------------get number and decide which word-----------------------------


-(void)GetNumber
{
	
    if(weGotWord==1) //we check that only when we got full word,for case when cocos sample this in the middle of a word and get wrong value
    {
        
        weGotWord=0; //after cocos read it ,he reset it,and it becomes high only the next word
        
        
        //give a sensor number to each event 
        if(bit1==1 && bit2==1 && bit3==0 && bit4==0)
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 1] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==0 && bit3==1 && bit4==0) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 2] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==0 && bit3==1 && bit4==1) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 3] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==0 && bit3==0 && bit4==1) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 4] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==0 && bit3==1 && bit4==1) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 5] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==1 && bit3==0 && bit4==1) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 6] , [NSString stringWithFormat: @"%d", 0] , nil];
        else if(bit1==1 && bit2==1 && bit3==1 && bit4==1) 
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 7] , [NSString stringWithFormat: @"%d", 0] , nil];
        
        else       //ERROR IN DIGITAL
            DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 6] , [NSString stringWithFormat: @"%d", 0] , nil];
        
        //NSLog(@"%@", DollPart);
        NSLog(@"%d",bit1);
        NSLog(@"%d",bit2);
        NSLog(@"%d",bit3);
        NSLog(@"%d",bit4);
    }
	
    else                    //not finish word yet
        DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 6] , [NSString stringWithFormat: @"%d", 0] , nil];
	
	
    
	//call cocos hardware
	[(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
    
    
	
}






//---------------------------------------------------------------------------------------------------


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration

{
    
    //NSLog(@"x:%g", acceleration.x);
    //NSLog(@"y:%g", (acceleration.y));
    //NSLog(@"z:%g", acceleration.z);
    
    
    
    
    //get accelerometer values
    gyroX=acceleration.x;
    gyroY=acceleration.y;
    gyroZ=acceleration.z;
    
    
    
    if(!gyroTimer)
    {
        gyroTimer=1;
        [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(gyroProcessing) userInfo: nil repeats: NO]; 	
    }
    
    
    
}





-(void)gyroProcessing
{
	
	
	gyroTimer=0;
	
	
	
    
	//GET EACH AXIS ACCELERATION GRADE
	
	if(fabs(gyroX)>1.35  )  
		nx++;
	else
		nx=0;
	
	
	
	
	if(fabs(gyroY)>1.35  )
		ny++;
	else
		ny=0;
	
	
	if(fabs(gyroZ)>1.35  )
		nz++;
	else
		nz=0;
	
	
	
    //------------------------------------------------------------------	
	
	
	//check for lay down and up // turn left and right
	
	//faceUP
	if(gyroZ< -0.98 && gyroZ> -1.05)
		backTime++;
	else
		backTime=0;
	
	
	
	
	
	//LAY DOWN
	if(gyroZ< 0.995 && gyroZ> 0.970)
		faceTime++;
	else
		faceTime=0;
	
	
	
	//turn left and right
	if(gyroX <-0.45 && gyroX>-0.87)
	{
		if(gyroY<-0.40 && gyroY>-0.75)
			n_right++;
		
		else if (gyroY>0.35 && gyroY<0.85)
			n_left++;
		else
		{
			n_right=0;
			n_left=0;
		}
		
	}
	else
	{
		n_left=0;
		n_right=0;
	}
	
	
	
	
	
	
    
    //--------------------------------------------------------------------	
	
	
	
	
	
    //--------------------------------------------------------------------	
	
	
	
    //NSLog(@"x%d",nx);
    // NSLog(@"y%d",ny);
    // NSLog(@"z%d",nz);
    
	
	
    
    
	//check for each position according to grades 
	
	
	//lift
	if( nx>3 && ny<2 && nz<2 && waitForGyroDbounce==0)
	{
		NSLog(@"lift");
		nx=0;
		ny=0;
		nz=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 7] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
	}
	
	
	//shake
	if(  ( ny>2 || nz>2) && nx<2  && waitForGyroDbounce==0)
	{
		NSLog(@"shake");
		nx=0;
		ny=0;
		nz=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 12] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
	}
	
	//LayDOWN
	if(backTime>50 && faceUp==0)
	{
        
		faceUp=1;
		backTime=0;
		nx=0;
		ny=0;
		nz=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 11] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
		
	}
	
	//FACEUP
	if(faceTime>100 && faceUp==0)
	{
		
		faceTime=0;
		nx=0;
		ny=0;
		nz=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 11] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
		
	}
	
	
	//awake after face down from any event
	if(gyroZ>-0.98 && faceUp==1 )
	{
		
		faceUp=0;
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 13] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
		
	}
	
	
	
	//turn left
	if(n_left>30 && waitForGyroDbounce==0)
	{
		n_left=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 3.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 15] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
		
	}
	
	
	//turn right
	if(n_right>30 && waitForGyroDbounce==0)
	{
		NSLog(@"gyro");
		n_right=0;
		waitForGyroDbounce=1;
		[NSTimer scheduledTimerWithTimeInterval: 3.0f target: self selector: @selector(initializeGyroDbounce) userInfo: nil repeats: NO];  			
		DollPart = [NSMutableArray arrayWithObjects: [NSString stringWithFormat: @"%d", 16] , [NSString stringWithFormat: @"%d", 0] , nil];
        [(HelloWorld*)[[[CCDirector sharedDirector] runningScene] getChildByTag:42] HardwareEvent:DollPart]; 
		
	}
    
	
	
    
}





-(void)initializeGyroDbounce
{
	waitForGyroDbounce=0;
}









// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	
	
	
	
	//listen to audio codes
	theInstance = [[SoundSensor alloc] init];
	[theInstance listen]; 	
	levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0010 target: self selector: @selector(waitForStartBit) userInfo: nil repeats: YES]; //wait for start bit		
	[theInstance release];
	[super viewDidLoad];
	
	
	
	
	//accelerometer
	UIAccelerometer *theAccel = [UIAccelerometer sharedAccelerometer];
	[theAccel setUpdateInterval:1.0/kAccelUpdate];
	[theAccel setDelegate:self];
	
	
	
	
	//gyro
	motionManager = [[CMMotionManager alloc] init];
	referenceAttitude = nil; 
	
	CMDeviceMotion *deviceMotion = motionManager.deviceMotion;      
	CMAttitude *attitude = deviceMotion.attitude;
	referenceAttitude = [attitude retain];
	[motionManager startGyroUpdates];
	
	
	
}















- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	NSLog(@"warning!");
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}






- (void)viewDidUnload {
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}







- (void)dealloc
{
	
	[theInstance release];
	[callerTimer release];
	[samplerTimer release];
	[motionManager release];
    [super dealloc];
}






@end


















/*
 
 //---------------------------wait for signal and get the bit width ----------------------------------
 //---------------------------------------------------------------------------------------------------
 
 
 tmp = [theInstance averagePower ];
 
 if (tmp>99.9)
 {
 if(flag==1) // go in only at the first time we got '1' and start measure time.
 {
 start = [[NSDate date] retain]; 
 flag=0;
 firstTime=1; 
 }
 }
 else if(tmp<99.9)
 {
 if(firstTime==1) // go here only if we have started a session of measuring signal width
 {
 duration = [start timeIntervalSinceNow] * -1000.0;
 flag=1;
 firstTime=0;
 
 if(duration>15 && duration<40)
 {
 [self CheckFullByth];
 NSLog(@"%f", duration);	
 }
 
 }
 
 }
 
 //----------------------------------------------------------------------------------------------------
 //----------------------------------------------------------------------------------------------------
 
 */







/*
 - (void)Animation
 {
 imageView.animationImages = [NSArray arrayWithObjects:
 [UIImage imageNamed:@"walkcycle-01.png"],
 [UIImage imageNamed:@"walkcycle-02.png"],
 [UIImage imageNamed:@"walkcycle-03.png"],
 [UIImage imageNamed:@"walkcycle-04.png"],
 [UIImage imageNamed:@"walkcycle-05.png"],nil];
 imageView.animationDuration = 1.4;
 [imageView setAnimationRepeatCount: 0];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 [imageView startAnimating]; 	
 
 //play a movie
 moviePlayer.useApplicationAudioSession=NO;
 [moviePlayer prepareToPlay];
 moviePlayer.controlStyle = MPMovieControlStyleDefault; 
 [moviePlayer setMovieControlMode:MPMovieControlModeHidden];
 moviePlayer.view.frame = CGRectMake(0, 0, 320, 480);
 [self.view addSubview:moviePlayer.view];
 [moviePlayer play];
 
 
 
 }
 */