// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "Pose.h"
#import "MetaioSDKViewController.h"

#import "DebugHandler.h"
#import "CompSixAxis.h"

@interface InstantTrackingViewController : MetaioSDKViewController <UIWebViewDelegate>
{
    DebugHandler debugHandler;
    
    NSMutableArray * ma_log;
    JSContext * ctx;

    int                 m_frames;
    NSDate              *elapsed;
    
    Pose cam;
    
    metaio::TrackingValues COS_offs; //can replace with pose
    
    int lastCOS;
    int activeCOS;
    
    bool hasTracking;
    bool isTracking;
    bool debugViewIsInit;
    bool showDebugView;
    bool updateMetaio;
    
    IBOutlet UIWebView* webView;
    IBOutlet UIButton* debugViewToggle;
    IBOutlet UIButton* debugPrintButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *debugViewToggle;
@property (nonatomic, retain) IBOutlet UIButton *debugPrintButton;


- (IBAction)onDebugDown:(id)sender;

/*****UNUSED*****/
- (IBAction)onPrintDown:(id)sender;
/*****/

- (CMMotionManager *)motionManager;

- (void) updateTrackingState;
- (void) updateObjectsWithCameraT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;

- (void) offsetTrackingValues: (metaio::TrackingValues&)tv_;

- (void) loadDebugView;
- (void) initDebugView;

//- (void)addPose: (int)name ToDebugContextT: (metaio::Vector4d)obj_t andR:(metaio::Rotation)obj_r;

@end