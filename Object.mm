//
//  Object.mm
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "common.h"
#import "Object.h"


wf_Object::wf_Object()
{
    t = cv::Mat::eye(4, 1, CV_32F);
    r = cv::Mat::eye(4, 4, CV_32F);
}

wf_Object::wf_Object(cv::Mat t_, cv::Mat r_)
{
    t_.copyTo(t);
    r_.copyTo(r);
}


metaio::Vector3d wf_Object::getT_m()
{
    return metaio::Vector3d(t.at<float>(1,0), t.at<float>(2,0), t.at<float>(3,0));
}

metaio::Rotation wf_Object::getR_m()
{
    cv::Vec3f r_v;
    Rodrigues(r, r_v);
    return metaio::Rotation(r_v(0), r_v(1), r_v(2));
}

void wf_Object::transform(cv::Mat mat_)
{
    cv::Mat tr = cv::Mat::eye(4, 4, CV_32F);
    matFromTandR(t, r, tr);
    tr *= mat_;
    tAndRFromMat(tr, t, r);
}