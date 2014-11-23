//
//  common.h
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//


#ifndef __Demo__common__
#define __Demo__common__

#import  <opencv2/opencv.hpp>
#import <metaioSDK/IMetaioSDKIOS.h>

/*untested unless mentioned*/
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
void matToP(cv::Mat mat_, cv::Vec4f& _p);
void matToP(cv::Mat mat_, metaio::Vector4d& _p);

#endif /* defined(__Demo__common__) */
