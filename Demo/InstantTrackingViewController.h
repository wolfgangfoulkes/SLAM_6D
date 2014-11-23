// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//


#import "Object.h"
#import "MetaioSDKViewController.h"

@interface InstantTrackingViewController : MetaioSDKViewController
{
    int                 m_frames;
    NSInteger           m_scale;             // model scale
    
    metaio::IGeometry*  m_obj;            // pointer to the model
    metaio::IGeometry*  m_obj1;           // pointer to the model
    
    metaio::Rotation    m_ri;
    metaio::Vector3d    m_ti;
    
    //camera r and t relative to init.
    metaio::Rotation    m_rn;
    metaio::Vector3d    m_tn;
    
    //object pose in real-world coordinates, static.
    metaio::Vector3d m_obj_ti;
    metaio::Rotation m_obj_ri; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj_t;
    metaio::Rotation m_obj_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj1_ti;
    metaio::Rotation m_obj1_ri; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj1_t;
    metaio::Rotation m_obj1_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    
    wf_Object obj;
    
    //wf_Object obj;
    
    bool hasInitPose;
    
    int activeCOS;
    
    bool debugView;
    bool printToScreen;
    
    IBOutlet UIWebView* webView;
    IBOutlet UIButton* debugViewToggle;
    IBOutlet UIButton* debugPrintButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *debugViewToggle;
@property (nonatomic, retain) IBOutlet UIButton *debugPrintButton;

- (IBAction)onDebugDown:(id)sender;
- (IBAction)onPrintDown:(id)sender;

- (void)initPoseWithT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;
- (void) updateObjectsWithCameraT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;
- (void)loadDebugView;
- (void)updateDebugViewWithCameraT: (metaio::Vector3d)c_t andR: (metaio::Rotation)c_r
    andObjectT: (metaio::Vector4d)o_t andR: (metaio::Rotation)o_r;
- (void)printDebugToConsole;
- (void)addPose: (int)name ToDebugContextT: (metaio::Vector4d)obj_t andR:(metaio::Rotation)obj_r;


@end