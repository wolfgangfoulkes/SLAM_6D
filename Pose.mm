//
//  Object.mm
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "common.h"
#import "Pose.h"


Pose::Pose()
{
    t = metaio::Vector3d(0, 0, 0);
    t_init = metaio::Vector3d(0, 0, 0);
    t_world = metaio::Vector3d(0, 0, 0);
    
    r = metaio::Rotation(0, 0, 0);
    r_init = metaio::Rotation(0, 0, 0);
    r_world = metaio::Rotation(0, 0, 0);
    
    isTracking = false;
    hasInitPose = false;
    COS = 0;
}

Pose::Pose(metaio::Vector3d t_, metaio::Rotation r_) : Pose()
{
    t_world = metaio::Vector3d(t_);
    r_world = metaio::Rotation(r_);
}

void Pose::initP(metaio::Vector3d t_, metaio::Rotation r_, int cos_)
{
    t_init = r_.inverse().rotatePoint(mult(t_, -1.0f)); //same as getInverseTranslation
    r_init = r_.inverse();
    
    t_init += t;
    r_init = r_init * r;
    COS = cos_;

    hasInitPose = true;
    isTracking = true;
}

void Pose::initP(metaio::TrackingValues tv_)
{
    metaio::Vector3d t_ = tv_.translation;
    metaio::Rotation r_ = tv_.rotation;
    int cos_ = tv_.coordinateSystemID;
    initP(t_, r_, cos_);
}

void Pose::updateP(metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector3d _t(0, 0, 0);
    metaio::Rotation _r(0, 0, 0);
    _t = r_.inverse().rotatePoint(mult(t_, -1.0f)) - t_init;
    
    t = _t;
    
    _r = r_.inverse() * r_init.inverse();
    r = _r;
}


void Pose::updateP(metaio::TrackingValues tv_)
{
    
    if (tv_.quality > 0.) //not lost, could be extrapolated
    {
        if (!hasInitPose || tv_.coordinateSystemID != COS)
        {
            initP(tv_);
            logMA([NSString stringWithFormat:@"init: %i => %i",tv_.coordinateSystemID, COS], ma_log);
        }
        metaio::Vector3d t_ = tv_.translation;
        metaio::Rotation r_ = tv_.rotation;

        updateP(t_, r_);
    }
    else
    {
        hasInitPose = false;
        isTracking = false;
    }
    
}