//
//  AppDelegate.h
//  BetaDoll
//
//  Created by ran turgeman on 11/3/11.
//  Copyright seebo 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
