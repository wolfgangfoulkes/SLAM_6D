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

//void QtoMat(cv::Vec4f q_, cv::Mat4f _mat)
//{
//    float x, y, z, w, xx, xy, xz, xw, yy, yz, yw, zz, zw;
//    cv::Mat4f mat;
//    x = q_(0);
//    y = q_(1);
//    z = q_(2);
//    w = q_(3);
//    
//    xx      = x * x;
//    xy      = x * y;
//    xz      = x * z;
//    xw      = x * w;
//
//    yy      = y * y;
//    yz      = y * z;
//    yw      = y * w;
//
//    zz      = z * z;
//    zw      = z * w;
//
//    mat(0)  = 1 - 2 * ( yy + zz );
//    mat(1)  =     2 * ( xy - zw );
//    mat(2)  =     2 * ( xz + yw );
//
//    mat(4)  =     2 * ( xy + zw );
//    mat(5)  = 1 - 2 * ( xx + zz );
//    mat(6)  =     2 * ( yz - xw );
//
//    mat(8)  =     2 * ( xz - yw );
//    mat(9)  =     2 * ( yz + xw );
//    mat(10) = 1 - 2 * ( xx + yy );
//
//    mat(3) = mat(7) = mat(11) = mat(12) = mat(13) = mat(14) = 0;
//    mat(15) = 1;
//    
//    mat.copyTo(_mat);
//}

void matFromTandR(cv::Mat t_, cv::Mat r_, cv::Mat _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 4) <<
    r_.at<float>(0, 0), r_.at<float>(1, 0), r_.at<float>(2, 0), t_.at<float>(0, 0),
    r_.at<float>(1, 1), r_.at<float>(2, 1), r_.at<float>(3, 1), t_.at<float>(1, 0),
    r_.at<float>(1, 2), r_.at<float>(2, 2), r_.at<float>(3, 2), t_.at<float>(2, 0),
    0.,                 0.,                 0.,                 1.);
    
    mat.copyTo(_mat);
}

void matFromTandRVecs(cv::Vec3f t_, cv::Vec3f r_, cv::Mat _mat)
{
    cv::Mat t = cv::Mat::eye(4, 1, CV_32F);
    cv::Mat r = cv::Mat::eye(4, 4, CV_32F);
    cv::Rodrigues(r_, r);
    pToMat(t_, t);
    
    matFromTandR(t, r, _mat);
}

void tAndRFromMat(cv::Mat mat_, cv::Mat _t, cv::Mat _r)
{
    _r = mat_(cv::Rect(0, 0, 4, 4));
    _t = mat_.col(3).rowRange(0, 4);
}

cv::Point3f transformPoint(cv::Point3f p_, cv::Mat mat_)
{
    cv::Point3f _p = cv::Point3f(
    p_.x * mat_.at<float>(0, 0) + p_.y * mat_.at<float>(1, 0) + p_.z * mat_.at<float>(2, 0) + 1 * mat_.at<float>(3, 0),
    p_.y * mat_.at<float>(0, 1) + p_.y * mat_.at<float>(1, 1) + p_.z * mat_.at<float>(2, 1) + 1 * mat_.at<float>(3, 1),
    p_.z * mat_.at<float>(0, 2) + p_.y * mat_.at<float>(1, 2) + p_.z * mat_.at<float>(2, 2) + 1 * mat_.at<float>(3, 2)
    );
    
    return _p;
}

void pToMat(cv::Point3f p_, cv::Mat _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 1) << p_.x, p_.y, p_.z);
    if (_mat.cols == 4)
    {
        mat.t();
    }
    mat.copyTo(_mat);
}
//change this to index array values so we can populate both row and column vectors
//I think .data
//see http://stackoverflow.com/questions/17569097/opencv-c-how-access-pixel-value-cv-32f-through-uchar-data-pointer

void matToP(cv::Mat mat_, cv::Point3f _p)
{
    if (mat_.cols == 4)
    {
        mat_.t();
    }
    _p.x = mat_.at<float>(0, 0);
    _p.y = mat_.at<float>(1, 0);
    _p.z = mat_.at<float>(2, 0);
}
//change this to index array values so we can populate both row and column vectors
