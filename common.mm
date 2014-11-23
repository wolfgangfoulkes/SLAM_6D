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

void rToMat(metaio::Rotation r_, cv::Mat& _r)
{
    float r_f[16];
    r_.getRotationMatrix4x4(r_f);
    cv::Mat r_mat = cv::Mat(4, 4, CV_32F, r_f);
    r_mat.copyTo(_r);
}

void matToR(cv::Mat r_, metaio::Rotation& _r)
{
    cv::Vec4f r;
    Rodrigues(r_, r);
    _r = metaio::Rotation(r(0), r(1), r(2));
}

void matFromTandR(cv::Mat t_, cv::Mat r_, cv::Mat& _mat)
{
    cv::Mat mat = (cv::Mat_<float>(4, 4) <<
    r_.at<float>(0, 0), r_.at<float>(1, 0), r_.at<float>(2, 0), t_.at<float>(0, 0),
    r_.at<float>(0, 1), r_.at<float>(1, 1), r_.at<float>(2, 1), t_.at<float>(1, 0),
    r_.at<float>(0, 2), r_.at<float>(1, 2), r_.at<float>(2, 2), t_.at<float>(2, 0),
    0.,                 0.,                 0.,                 1.);
    
    mat.copyTo(_mat);
}

void matFromTandR(cv::Vec4f t_, cv::Vec4f r_, cv::Mat& _mat)
{
    cv::Mat t = cv::Mat::eye(4, 1, CV_32F);
    cv::Mat r = cv::Mat::eye(4, 4, CV_32F);
    cv::Rodrigues(r_, r);
    pToMat(t_, t);
    
    matFromTandR(t, r, _mat);
}

void matFromTandR(metaio::Vector4d t_, metaio::Rotation r_, cv::Mat& _mat)
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
        mat.t();
    }
    mat.copyTo(_mat);
}

void pToMat(metaio::Vector4d p_, cv::Mat& _mat)
{
    cv::Vec4f p;
    p(0) = p_.x;
    p(1) = p_.y;
    p(2) = p_.z;
    p(3) = p_.w;
    pToMat(p, _mat);
}
//change this to index array values so we can populate both row and column vectors
//I think .data
//see http://stackoverflow.com/questions/17569097/opencv-c-how-access-pixel-value-cv-32f-through-uchar-data-pointer

void matToP(cv::Mat mat_, cv::Vec4f& _p)
{
    if (mat_.cols == 4)
    {
        mat_.t();
    }
    _p(0) = mat_.at<float>(0, 0);
    _p(1) = mat_.at<float>(1, 0);
    _p(2) = mat_.at<float>(2, 0);
    _p(3) = 1;
}
//change this to index array values so we can populate both row and column vectors

void matToP(cv::Mat mat_, metaio::Vector4d& _p)
{
    cv::Vec4f p;
    matToP(mat_, p);
    _p.x = p(0);
    _p.y = p(1);
    _p.z = p(2);
    _p.w = p(3);
}
