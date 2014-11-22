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
    metaio::Vector3d m_obj_ti;
    metaio::Rotation m_obj_ri; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj_t;
    metaio::Rotation m_obj_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj1_ti;
    metaio::Rotation m_obj1_ri; //will need to convert for rotating geometry, which rotates relative to camera COS.
    metaio::Vector3d m_obj1_t;
    metaio::Rotation m_obj1_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    
    //wf_Object obj;
    
    bool hasInitPose;
    
    int activeCOS;
}


@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)initPoseWithT: (metaio::Vector3d)t AndR:(metaio::Rotation)r;
- (void) updateObjectsWithCameraR: (metaio::Rotation)r AndT:(metaio::Vector3d)t;
- (void)loadDebugView;
- (void)updateDebugView: (metaio::Vector3d)tc  object: (metaio::Vector3d)to;
- (void)printDebugToConsole;

@end
