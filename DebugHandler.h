//
//  DebugHandler.h
//  Demo
//
//  Created by Wolfgag on 12/22/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#ifndef __Demo__DebugHandler__
#define __Demo__DebugHandler__
#import "common.h"
#import "Pose.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <metaioSDK/IMetaioSDKIOS.h>

class DebugHandler {
public:
    int called;
    const double SIG_FIGS = 100;

    const double TOUCH_X_COEFF = 100;
    const double TOUCH_Y_COEFF = -100;
    
    const double X_COEFF = 0.05; //to scale output, and put into the right COS.
    const double Y_COEFF = 0.05;
    const double Z_COEFF = 0.05;

    NSMutableArray * log;
    JSContext * ctx;
    
    Pose * pose; //should be a pointer, should be one for each out. should have separate shit in JS for directional configuration
    metaio::Vector2d t_touch;
    metaio::Rotation r_touch;
    metaio::Vector3d acc;
    metaio::Rotation gyr;
    
    metaio::Vector3d o_t;
    metaio::Rotation o_r;
    
    metaio::Vector3d cf_acc;
    metaio::Rotation cf_gyr;
    
    int COS;
    string tracking_state;
    
    bool jsIsInit;
    bool jsIsReady;
    bool print;
    bool printLog;
    
    DebugHandler();
    void update();

    void initJS(JSContext * ctx);
    void getJS();
    void updatePose(NSString * pose_, metaio::Vector3d t_, metaio::Rotation r_);
    
    void setPose();
};


#endif /* defined(__Demo__DebugHandler__) */
