// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "Pose.h"
#import "MetaioSDKViewController.h"

@interface InstantTrackingViewController : MetaioSDKViewController
{
    NSMutableArray * ma_log;
    JSContext * ctx;
    bool debugViewIsInit;

    int                 m_frames;
    NSInteger           m_scale;             // model scale
    
    metaio::IGeometry*  m_obj;            // pointer to the model
    metaio::IGeometry*  m_obj1;           // pointer to the model
    
    Pose obj, cam, obj_test, cam_test;
    
    int activeCOS;
    bool isTracking;
    metaio::TrackingValues COS_offs; //can replace with pose
    
    metaio::IRadar * m_radar;
    
    bool debugView;
    bool printToScreen;
    bool updateMetaio;
    
    IBOutlet UIWebView* webView;
    IBOutlet UIButton* debugViewToggle;
    IBOutlet UIButton* debugPrintButton;
    IBOutlet UIButton* XppButton;
    IBOutlet UIButton* XmmButton;
    IBOutlet UIButton* YppButton;
    IBOutlet UIButton* YmmButton;
    IBOutlet UIButton* ZppButton;
    IBOutlet UIButton* ZmmButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *debugViewToggle;
@property (nonatomic, retain) IBOutlet UIButton *debugPrintButton;

@property (nonatomic, retain) IBOutlet UIButton* XppButton;
@property (nonatomic, retain) IBOutlet UIButton* XmmButton;
@property (nonatomic, retain) IBOutlet UIButton* YppButton;
@property (nonatomic, retain) IBOutlet UIButton* YmmButton;
@property (nonatomic, retain) IBOutlet UIButton* ZppButton;
@property (nonatomic, retain) IBOutlet UIButton* ZmmButton;

- (IBAction)onDebugDown:(id)sender;
- (IBAction)onPrintDown:(id)sender;
- (IBAction)poseButtonDown:(id)sender;

- (void)initPoseWithT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;

- (void) updateTrackingState;

- (void) updateObjectsWithCameraT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;


- (void)loadDebugView;


- (void)updateDebugViewWithCameraT: (metaio::Vector3d)c_t andR: (metaio::Rotation)c_r
    andObjectT: (metaio::Vector3d)o_t andR: (metaio::Rotation)o_r;

- (void) initDebugView;

- (void)updateDebugViewWithActiveCos: (int)cos_ AndStatus:(string)state_;

- (void)updateDebugViewForPose: (NSString*)pose_ WithT: (metaio::Vector3d)t_ andR: (metaio::Rotation)r_;

- (void)printDebugToConsole;

- (void)printLogToConsole;

- (void)getTFromDebugView;

//- (void)addPose: (int)name ToDebugContextT: (metaio::Vector4d)obj_t andR:(metaio::Rotation)obj_r;

- (void)printETSState:(metaio::ETRACKING_STATE)state_;

@end