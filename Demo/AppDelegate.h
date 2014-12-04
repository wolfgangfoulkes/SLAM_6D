//
//  AppDelegate.h
//  Demo
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@class InstantTrackingViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CMMotionManager *motionManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) InstantTrackingViewController *viewController;
@property (readonly) CMMotionManager *motionManager;


@end
