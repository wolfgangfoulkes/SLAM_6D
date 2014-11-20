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

//
//void QtoMat(cv::Vec4f q_, cv::Mat4f _mat);

void matFromTandR(cv::Mat t_, cv::Mat r_, cv::Mat _mat);
void tAndRFromMat(cv::Mat mat_, cv::Mat _t, cv::Mat _r);
void matFromTandRVecs(cv::Vec3f t_, cv::Vec3f r_, cv::Mat _mat);
cv::Point3f transformPoint(cv::Point3f p_, cv::Mat mat_);
void pToMat(cv::Point3f p_, cv::Mat _mat);

#endif /* defined(__Demo__common__) */
