//
//  AppDelegate.h
//  Demo
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@class InstantTrackingViewController;
@class AEAudioController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CMMotionManager *motionManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) InstantTrackingViewController *viewController;
@property (readonly) CMMotionManager *motionManager;
@property (strong, nonatomic) AEAudioController *audioController;


@end
