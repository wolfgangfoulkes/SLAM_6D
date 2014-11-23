//
//  Object.h
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//



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
    
    //Point3f t; //be easier if you changed this to column vector
    //Point3f r; //be easier if you changed this to matrix
    
    cv::Mat t_init;
    cv::Mat r_init;
    
    cv::Mat t;
    cv::Mat r;
    
    Pose();
    Pose(cv::Mat t_, cv::Mat r_);
    Pose(metaio::Vector4d t, metaio::Rotation r);
    Pose(metaio::Vector3d t, metaio::Rotation r);
    
    void setT(metaio::Vector3d t_);
    void setR(metaio::Rotation r_);
    metaio::Vector3d getT_m();
    metaio::Rotation getR_m();
    metaio::Vector3d getT_world();
    metaio::Rotation getR_world();
    
    void translate(metaio::Vector3d t_);
    void transform(metaio::Vector4d t_, metaio::Rotation r_);
    void transform(metaio::Rotation r_, metaio::Vector3d t_, metaio::Rotation r1_= metaio::Rotation(0, 0, 0));
    void rotate(metaio::Rotation r_);
};

#endif /* defined(__Demo__Pose__) */
