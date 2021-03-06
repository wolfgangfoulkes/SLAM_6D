//
//  common.h
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//


#ifndef __Demo__common__
#define __Demo__common__

#import <opencv2/opencv.hpp>
#import <metaioSDK/IMetaioSDKIOS.h>

/** Degrees to Radian **/
#define dToR( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define rToD( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

/*untested unless mentioned*/
void matToArray(cv::Mat m_, float * _m);
void rToMat(metaio::Rotation r_, cv::Mat& _r);
void matToR(cv::Mat r_, metaio::Rotation& _r);
void matFromTandR(cv::Mat t_, cv::Mat r_, cv::Mat& _mat);
void matFromTandR(cv::Vec4f t_, cv::Vec4f r_, cv::Mat& _mat);
void matFromTandR(metaio::Vector4d t_, metaio::Rotation r_, cv::Mat& _mat);
void tAndRFromMat(cv::Mat mat_, cv::Mat& _t, cv::Mat& _r);
void tAndRFromMat(cv::Mat mat_, metaio::Vector4d& _t, metaio::Rotation& _r);
void transformPoint(cv::Mat p_, cv::Mat mat_, cv::Mat& _p);
void transformPoint(metaio::Vector4d& p, cv::Mat mat_);
void pToMat(cv::Vec4f p_, cv::Mat& _mat);
void pToMat(metaio::Vector4d p_, cv::Mat& _mat);
void pToMat(metaio::Vector3d p_, cv::Mat& _mat);
void matToP(cv::Mat mat_, cv::Vec4f& _p);
void matToP(cv::Mat mat_, metaio::Vector4d& _p);
void matToP(cv::Mat mat_, metaio::Vector3d& _p);

bool operator== (const metaio::Rotation& left_, const metaio::Rotation& right_);

NSMutableDictionary * toDict(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0), metaio::Vector3d scale_ = metaio::Vector3d(0, 0, 0));
NSMutableDictionary * toDict(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Vector4d qu_ = metaio::Vector4d(0, 0, 0, 0), metaio::Vector3d scale_ = metaio::Vector3d(0, 0, 0));
//NSMutableDictionary * toDict(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Vector3d eu_ = metaio::Vector3d(0, 0, 0), metaio::Vector3d scale_ = metaio::Vector3d(0, 0, 0));

metaio::TrackingValues toTrackingValues(metaio::Rotation r_, metaio::Vector3d t_);
metaio::TrackingValues toTrackingValues(cv::Mat r_, cv::Mat t_);

void logMA(NSString * s_, NSMutableArray * ma_);
void logMA(std::string s_, NSMutableArray * ma_);
void logMA(NSMutableArray * ma_, NSString* fmt_, ...);
metaio::Vector3d loPassXYZ(metaio::Vector3d v0_, metaio::Vector3d v1_);
std::string tRToS(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0));
void logTR(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0));
void logTR(metaio::Rotation r_ = metaio::Rotation(0, 0, 0), metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0));

metaio::Vector3d mult(metaio::Vector3d v_, float f_);
metaio::Vector3d round(metaio::Vector3d v_, float f_);
metaio::Vector3d scale(metaio::Vector3d v_, metaio::Vector3d scale_);
float distance(metaio::Vector3d v_);

metaio::Vector3d calcCOSTOffset(metaio::Vector3d t_, metaio::Vector3d t_last_, metaio::Rotation r_);
metaio::Rotation calcCOSROffset(metaio::Rotation r_, metaio::Rotation r_last_);
void calcCOSOffset(metaio::Vector3d t_, metaio::Rotation r_, metaio::Vector3d t_last_, metaio::Rotation r_last_, metaio::Vector3d& _t, metaio::Rotation& _r);

void cartesianToSpherical(metaio::Vector3d t_, metaio::Rotation r_, double& _azimuth, double& _elevation, double& _distance);
//void sphericalToCartesian(double azimuth_, double elevation_, double distance_, metaio::Vector3d& _t, metaio::Rotation& _r);


#endif /* defined(__Demo__common__) */
