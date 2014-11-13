// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface InstantTrackingViewController : MetaioSDKViewController
{
    int                 m_frames;
    NSInteger           m_scale;             // model scale
    
    metaio::IGeometry*  m_obj;            // pointer to the model
    
    //camera r and t relative to init.
    metaio::Rotation    m_rn;
    metaio::Vector3d    m_tn;
    
    //object pose in real-world coordinates, static.
    metaio::Vector3d m_obj_p;
    metaio::Rotation m_obj_r; //will need to convert for rotating geometry, which rotates relative to camera COS.
    
}


@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *decreseBtn; // Hidden button - bottom left
@property (weak, nonatomic) IBOutlet UIButton *inceaseBtn; // Hidden button - bottom right
@property (weak, nonatomic) IBOutlet UIButton *resetTrackingBtn; // Hidden button - bottom middle
@property (weak, nonatomic) IBOutlet UIButton *changeModelVisibilityBtn;

- (IBAction)onDecreseBtnPress:(id)sender;
- (IBAction)onIncreaseBtnPress:(id)sender;
- (IBAction)onResetTrackingBtnPress:(id)sender;
- (IBAction)onChangeModelVisibilityBtnPress:(id)sender;

@end
