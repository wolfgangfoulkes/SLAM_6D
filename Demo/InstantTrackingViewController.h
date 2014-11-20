// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import "MetaioSDKViewController.h"
//#import "Object.h"

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
    metaio::Vector3d m_obj_p;
    metaio::Rotation m_obj_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    
    //wf_Object obj;
    
    bool hasInitPose;
}


@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *resetTrackingBtn; // Hidden button - bottom middle
@property (weak, nonatomic) IBOutlet UIButton *changeModelVisibilityBtn;

- (IBAction)onResetTrackingBtnPress:(id)sender;
- (IBAction)onChangeModelVisibilityBtnPress:(id)sender;

- (void)initPoseWithT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;

- (void)loadDebugView;
- (void)updateDebugView: (metaio::Vector3d)tc  object: (metaio::Vector3d)to;

@end
