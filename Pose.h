//
//  Object.h
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

/*
t_init: from metaio
t: difference from t_init
t_world: t + world coordinates
t_offs: new init for changing COS's
*/

/* for camera, this needs:
a boolean value to tell whether tracking is lost or not
offset, set to 0, each time we lose tracking, then updated (+= t_ - t) until we regain tracking
it wouldn't be the actual COSoffset, but you could extrapolate that using camera distance-to-object for each COS
better done in a global function.
*/


/* when you create a child-class for camera, object
object should have a projection t/r and a world t/r, with projection computed using input and world, but world updated separately
camera should have what we have here, but with distinction in naming if something varies strongly in use
perhaps both should have a "getProjection" and overload that functionally
add only what you need
*/


#ifndef __Demo__Pose__
#define __Demo__Pose__

#import <opencv2/opencv.hpp>
#import <metaioSDK/IMetaioSDKIOS.h>

using namespace std;
using namespace cv;

/** Degrees to Radian **/
#define dToR( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define rToD( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

class Pose
{
    public:
    
    metaio::Vector3d t, t_init, t_world;
    metaio::Rotation r, r_init, r_world;
    
    bool hasInitPose;
    bool isTracking;
    bool COS;
    
    Pose();
    Pose(metaio::Vector3d t_, metaio::Rotation r_);
    
    void initP(metaio::Vector3d t_, metaio::Rotation r_);
    void initP(metaio::TrackingValues tv_);
    void updateP(metaio::Vector3d t_, metaio::Rotation r_);
    void updateP(metaio::TrackingValues tv_);
    //void updateP(metaio::TrackingValues tv_, metaio::SensorValues sv_);
};

//class camPose : public Pose
//{
//    
//};

#endif /* defined(__Demo__Pose__) */
