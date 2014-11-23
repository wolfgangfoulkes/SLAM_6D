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
    t  = cv::Mat::eye(4, 1, CV_32F);
    t_init = cv::Mat::eye(4, 1, CV_32F);
    r  = cv::Mat::eye(4, 4, CV_32F);
    r_init  = cv::Mat::eye(4, 4, CV_32F);
}

Pose::Pose(cv::Mat t_, cv::Mat r_) : Pose()
{
    t_.copyTo(t);
    r_.copyTo(r);
    t.copyTo(t_init);
    r.copyTo(r_init);
}

Pose::Pose(metaio::Vector4d t_, metaio::Rotation r_) : Pose()
{
    pToMat(t_, t);
    rToMat(r_, r);
    t.copyTo(t_init);
    r.copyTo(r_init);
}

Pose::Pose(metaio::Vector3d t_, metaio::Rotation r_) : Pose()
{
    pToMat(t_, t);
    rToMat(r_, r);
    t.copyTo(t_init);
    r.copyTo(r_init);
}

void Pose::setT(metaio::Vector3d t_)
{
    pToMat(t_, t);
}

void Pose::setR(metaio::Rotation r_)
{
    rToMat(r_, r);
}

metaio::Vector3d Pose::getT_m()
{
    return metaio::Vector3d(t.at<float>(0,0), t.at<float>(1,0), t.at<float>(2,0));
}

metaio::Rotation Pose::getR_m()
{
    metaio::Rotation r_m;
    matToR(r, r_m);
    return r_m;
}

metaio::Vector3d Pose::getT_world()
{
    metaio::Vector3d _t;
    cv::Mat t_world = t - t_init;
    matToP(t_world, _t);
    return _t;
}

metaio::Rotation Pose::getR_world()
{
    metaio::Rotation r0;
    metaio::Rotation r1;

    matToR(r_init, r0);
    matToR(r, r1);
    
    metaio::Rotation _r = r0.inverse() * r1;
    return _r;
}

void Pose::translate(metaio::Vector3d t_) //rotation is relative to self //seems to work
{
    metaio::Vector3d _t;
    matToP(t, _t);
    _t += t_;
    pToMat(_t, t);
}

void Pose::transform(metaio::Vector4d t_, metaio::Rotation r_) //rotation is relative to self //seems to work
{
    cv::Mat mat = cv::Mat::eye(4, 4, CV_32F);
    matFromTandR(t_, r_, mat);
    t = mat * t_init;
}

void Pose::transform(metaio::Rotation r_, metaio::Vector3d t_, metaio::Rotation r1_)
{
    metaio::Vector3d t_m;
    matToP(t, t_m);
    t_m = r_.rotatePoint(t_m);
    t_m += t_;
    pToMat(t_m, t);
    //rotate(r1_);
}



void Pose::rotate(metaio::Rotation r_) //rotation relative to self //seems to work
{
    cv::Mat mat = cv::Mat::eye(4, 4, CV_32F);
    rToMat(r_, mat);
    r = r * mat;
}