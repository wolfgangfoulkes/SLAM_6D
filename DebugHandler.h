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
    const double ROUND = 10;
    const double X_COEFF = 1000;
    const double Y_COEFF = -1000;
    const double Z_COEFF = 1;

    NSMutableArray * log;
    JSContext * ctx;
    
    Pose cam, obj;
    metaio::Vector3d t0_out, t1_out;
    metaio::Rotation r0_out, r1_out;
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
};


#endif /* defined(__Demo__DebugHandler__) */
