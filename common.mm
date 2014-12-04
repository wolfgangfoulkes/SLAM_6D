//
//  common.cpp
//  Demo
//
//  Created by wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//
#import <stdlib.h>
#import <stdio.h>
#import <iostream>
#import <opencv2/core.hpp>
#import <opencv2/core/core.hpp>
#import <opencv2/calib3d.hpp>
#import "common.h"

using namespace std;

void matToArray(cv::Mat m_, float * _m) //works with vectors too, if you pass in &vec[0]
{
    cv::Mat m(m_.rows, m_.cols, CV_32F, _m);
    m_.copyTo(m);
}

void rToMat(metaio::Rotation r_, cv::Mat& _r) //works
{
    float r_f[16];
    r_.getRotationMatrix4x4(r_f);
    cv::Mat r_mat(4, 4, CV_32F, r_f);
    r_mat.copyTo(_r);
}

void matToR(cv::Mat r_, metaio::Rotation& _r) //seems to work
{
    float r_f[16];
    matToArray(r_, r_f);
    metaio::Rotation r;
    _r.setFromModelviewMatrix(r_f);
}

void matFromTandR(cv::Mat t_, cv::Mat r_, cv::Mat& _mat) //works I think (only if rotation is around own axis)
{
    cv::Mat mat = (cv::Mat_<float>(4, 4) <<
    r_.at<float>(0, 0), r_.at<float>(1, 0), r_.at<float>(2, 0), t_.at<float>(0, 0),
    r_.at<float>(0, 1), r_.at<float>(1, 1), r_.at<float>(2, 1), t_.at<float>(1, 0),
    r_.at<float>(0, 2), r_.at<float>(1, 2), r_.at<float>(2, 2), t_.at<float>(2, 0),
    0.,                 0.,                 0.,                 1.);
    
    mat.copyTo(_mat);
}

void matFromTandR(metaio::Vector4d t_, metaio::Rotation r_, cv::Mat& _mat) //works I think (only if rotation is around own axis)
{
    
    cv::Mat t = cv::Mat::eye(4, 1, CV_32F);
    cv::Mat r = cv::Mat::eye(4, 4, CV_32F);
    pToMat(t_, t);
    rToMat(r_, r);
    matFromTandR(t, r, _mat);
}

void tAndRFromMat(cv::Mat mat_, cv::Mat& _t, cv::Mat& _r)
{
    _r = mat_(cv::Rect(0, 0, 4, 4));
    _r.row(3).setTo(cv::Scalar::zeros());
    _r.col(3).setTo(cv::Scalar::zeros());
    _t = mat_.col(3).rowRange(0, 4);
}

void tAndRFromMat(cv::Mat mat_, metaio::Vector4d& _t, metaio::Rotation& _r)
{
    cv::Mat t = cv::Mat::eye(4, 1, CV_32F);
    cv::Mat r = cv::Mat::eye(4, 4, CV_32F);
    tAndRFromMat(mat_, t, r);
    matToP(t, _t);
    matToR(r, _r);
}

void transformPoint(cv::Mat& p, cv::Mat mat_)
{
    cv::Mat _p = cv::Mat::eye(4, 4, CV_32F);
    if (p.cols == 4)
    {
        _p.setTo(p * mat_);
    }
    else if (p.rows == 4)
    {
        _p.setTo(mat_ * p);
    }
    
    _p.copyTo(p);
}

void transformPoint(metaio::Vector4d& p, cv::Mat mat_)
{
    cv::Mat _p = cv::Mat::eye(4, 1, CV_32F);
    pToMat(p, _p);
    transformPoint(_p, mat_);
    matToP(_p, p);
}

void pToMat(cv::Vec4f p_, cv::Mat& _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 1) << p_(0), p_(1), p_(2), p_(3));
    if (_mat.cols == 4)
    {
        mat = mat.t(); //opencv t() returns: http://docs.opencv.org/modules/core/doc/basic_structures.html
    }
    mat.copyTo(_mat);
}

void pToMat(metaio::Vector4d p_, cv::Mat& _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 1) << p_.x, p_.y, p_.z, 1);
    mat.copyTo(_mat);
}
void pToMat(metaio::Vector3d p_, cv::Mat& _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 1) << p_.x, p_.y, p_.z, 1);
    mat.copyTo(_mat);
}

//change this to index array values so we can populate both row and column vectors
//I think .data
//see http://stackoverflow.com/questions/17569097/opencv-c-how-access-pixel-value-cv-32f-through-uchar-data-pointer

void matToP(cv::Mat mat_, cv::Vec4f& _p)
{
//    if (mat_.cols == 4)
//    {
//        mat_.t(); //see above
//    }
    _p(0) = mat_.at<float>(0, 0);
    _p(1) = mat_.at<float>(1, 0);
    _p(2) = mat_.at<float>(2, 0);
    _p(3) = 1;
}
//change this to index array values so we can populate both row and column vectors

void matToP(cv::Mat mat_, metaio::Vector4d& _p)
{
    _p.x = mat_.at<float>(0, 0);
    _p.y = mat_.at<float>(1, 0);
    _p.z = mat_.at<float>(2, 0);
    _p.w = 1;
}

void matToP(cv::Mat mat_, metaio::Vector3d& _p)
{
    _p.x = mat_.at<float>(0, 0);
    _p.y = mat_.at<float>(1, 0);
    _p.z = mat_.at<float>(2, 0);
}

metaio::TrackingValues toTrackingValues(metaio::Rotation r_, metaio::Vector3d t_)
{
    metaio::TrackingValues _tv;
    _tv.rotation = r_;
    _tv.translation = t_;
    return _tv;
}

metaio::TrackingValues toTrackingValues(cv::Mat r_, cv::Mat t_)
{
    metaio::Rotation r(0, 0, 0);
    metaio::Vector3d t(0, 0, 0);
    matToR(r_, r);
    matToP(t_, t);
    metaio::TrackingValues _tv = metaio::TrackingValues(toTrackingValues(r, t));
    return _tv;
}

metaio::Vector3d mult(metaio::Vector3d v_, float f_)
{
    metaio::Vector3d _v(v_.x * f_, v_.y * f_, v_.z * f_);
    return _v;
}

void logMA(NSString * s_, NSMutableArray * ma_)
{
    [ma_ addObject: s_];
}

metaio::Vector3d loPassXYZ(metaio::Vector3d v0_, metaio::Vector3d v1_)
{
    //original time constant was 0.3, original dt was 1/20. did 0.3 / (1/20), got 6. multiplied by 1/30 to get 0.199...

    metaio::Vector3d _v(0, 0, 0);
    double dt = (1.0/30); //metaio time interval
    double RC = 0.2; //time constant, "decay time", usually time constant is what's here represented by RC + dt, so it's an offset
    double alpha = dt / (RC + dt); //alpha is the smoothing factor (cutoff)
    _v.x = (alpha * v1_.x) + (1.0 - alpha) * v0_.x;
    _v.y = (alpha * v1_.y) + (1.0 - alpha) * v0_.y;
    _v.z = (alpha * v1_.z) + (1.0 - alpha) * v0_.z;
    
    return _v;
}
