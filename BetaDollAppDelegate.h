//
//  BetaDollAppDelegate.h
//  BetaDoll
//
//  Created by ran turgeman on 6/29/11.
//  Copyright seebo 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController;

@interface BetaDollAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	NSString *global;
}

@property (nonatomic, retain) UIWindow *window;
//- (void)acceleratedInX:(float)xx Y:(float)yy Z:(float)zz;
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration ;
@end
