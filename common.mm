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
#import <sstream>
#import <math.h>
#import <opencv2/core.hpp>
#import <opencv2/core/core.hpp>
#import <opencv2/calib3d.hpp>
#import "common.h"

using namespace std;

#define PI                              3.1415926f
#define HALF_PI                         1.5707963f
#define TWO_PI                          6.2831853f

/***** OPENCV *****/

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

/***** C++ -> JS *****/

NSMutableDictionary * toDict(metaio::Vector3d t_, metaio::Rotation r_, metaio::Vector3d scale_)
{
    metaio::Vector4d qu_ = r_.getQuaternion();
    NSMutableDictionary * _dict = [[NSMutableDictionary alloc] initWithDictionary:
                @{  @"t" : @{           @"x" : @(t_.x),     @"y" : @(t_.y),     @"z" : @(t_.z)                          },
                    @"r" : @{           @"x" : @(qu_.x),    @"y" : @(qu_.y),    @"z" : @(qu_.z),    @"w" : @(qu_.w)     },
                    @"scale" : @{       @"x" : @(scale_.x), @"y" : @(scale_.y), @"z" : @(scale_.z)                      }   }
        ];
        return _dict;
}

NSMutableDictionary * toDict(metaio::Vector3d t_, metaio::Vector4d qu_, metaio::Vector3d scale_)
{
    NSMutableDictionary * _dict = [[NSMutableDictionary alloc] initWithDictionary:
                @{  @"t" : @{           @"x" : @(t_.x),     @"y" : @(t_.y),     @"z" : @(t_.z)                          },
                    @"r" : @{           @"x" : @(qu_.x),    @"y" : @(qu_.y),    @"z" : @(qu_.z),    @"w" : @(qu_.w)     },
                    @"scale" : @{       @"x" : @(scale_.x), @"y" : @(scale_.y), @"z" : @(scale_.z)                      }   }
        ];
        return _dict;
}

NSMutableDictionary * toDict(metaio::Vector3d t_, metaio::Vector3d eu_, metaio::Vector3d scale_)
{
    NSMutableDictionary * _dict = [[NSMutableDictionary alloc] initWithDictionary:
                @{  @"t" : @{           @"x" : @(t_.x),     @"y" : @(t_.y),     @"z" : @(t_.z)                          },
                    @"r" : @{           @"x" : @(eu_.x),    @"y" : @(eu_.y),    @"z" : @(eu_.z),    @"w" : @(0)         },
                    @"scale" : @{       @"x" : @(scale_.x), @"y" : @(scale_.y), @"z" : @(scale_.z)                      }   }
        ];
        return _dict;
}

/********/

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

/***** MATH ******/

metaio::Vector3d mult(metaio::Vector3d v_, float f_)
{
    metaio::Vector3d _v(v_.x * f_, v_.y * f_, v_.z * f_);
    return _v;
}

metaio::Vector3d round(metaio::Vector3d v_, float f_)
{
    metaio::Vector3d _v(0);
    _v.x = ((int)(v_.x * f_))/f_;
    _v.y = ((int)(v_.y * f_))/f_;
    _v.z = ((int)(v_.z * f_))/f_;
    
    return _v;
}

metaio::Vector3d scale(metaio::Vector3d v_, metaio::Vector3d scale_)
{
    metaio::Vector3d _v;
    _v.x = v_.x * scale_.x;
    _v.y = v_.y * scale_.y;
    _v.z = v_.z * scale_.z;
    return _v;
}

metaio::Vector3d calcCOSTOffset(metaio::Vector3d t_, metaio::Vector3d t_last_, metaio::Rotation r_)
{
    metaio::Vector3d _t;
    metaio::Vector3d t_p_ = r_.inverse().rotatePoint(mult(t_, -1.0f));
    _t = r_.inverse().rotatePoint(t_last_) + t_p_;
    return _t;
}

metaio::Rotation calcCOSROffset(metaio::Rotation r_, metaio::Rotation r_last_)
{
    metaio::Rotation _r;
    _r = r_.inverse() * r_last_;
    return _r;
}

float distance(metaio::Vector3d v_)
{
    return sqrt(v_.x * v_.x +
                v_.y * v_.y +
                v_.z * v_.z);
}

void calcCOSOffset(metaio::Vector3d t_, metaio::Rotation r_, metaio::Vector3d t_last_, metaio::Rotation r_last_, metaio::Vector3d& _t, metaio::Rotation& _r)
{
    _t = calcCOSTOffset(t_, t_last_, r_);
    _r = calcCOSROffset(r_, r_last_);
}

/***** DEBUG *****/

void logMA(NSString * s_, NSMutableArray * ma_)
{
    if (ma_.count >= 50)
    {
        [ma_ removeObjectAtIndex:0];
        //[ma_ removeObjectsInRange:{0, 10}]; //put this in debugHandler
    }
    [ma_ addObject: s_];
}

void logMA(std::string s_, NSMutableArray * ma_)
{
    if (ma_.count >= 50)
    {
        [ma_ removeObjectAtIndex:0];
        //[ma_ removeObjectsInRange:{0, 10}]; //put this in debugHandler
    }
    [ma_ addObject: [NSString stringWithUTF8String:s_.c_str()]];
}

void logMA(NSMutableArray * ma_, NSString* fmt_, ...)
{
//    va_list args;
//    va_start(args, fmt_);
//    NSString * _s = [NSString stringWithFormat:fmt_, args];
//    [ma_ addObject:_s];
//    va_end(args);
}

void logTR(metaio::Vector3d t_, metaio::Rotation r_)
{
    NSLog([NSString stringWithUTF8String:tRToS(t_, r_).c_str()]);
}

void logTR(metaio::Rotation r_, metaio::Vector3d t_)
{
    NSLog([NSString stringWithUTF8String:tRToS(t_, r_).c_str()]);
}

/***** MISC *****/

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

std::string tRToS(metaio::Vector3d t_, metaio::Rotation r_)
{
    double _t_x = t_.x;
    double _t_y = t_.y;
    double _t_z = t_.z;
    double _r_x = r_.getEulerAngleDegrees().x;
    double _r_y = r_.getEulerAngleDegrees().y;
    double _r_z = r_.getEulerAngleDegrees().z;
    
    std::stringstream _ss;
    _ss << "t: (" << _t_x << ", " << _t_y << ", " << _t_z << "); r: ("<< _r_x << ", " << _r_y << ", " << _r_z << ");";
    return _ss.str();
}

void cartesianToSpherical(metaio::Vector3d t_, metaio::Rotation r_, double& _azimuth, double& _elevation, double& _distance)
{
    _distance = distance(t_);
    _azimuth = rToD( atan2(t_.x, t_.z) ); //atan2(a, b) = atan( a/b ) with the correct quadrant
    _elevation = 90.0 - rToD(acos( t_.y / _distance )); //elevation is expressed -90 -> 0 -> 90
}

