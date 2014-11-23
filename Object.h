//
//  Object.h
//  Demo
//
//  Created by Wolfgag on 11/19/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//



#ifndef __Demo__Object__
#define __Demo__Object__

#import <opencv2/opencv.hpp>
#import <metaioSDK/IMetaioSDKIOS.h>

using namespace std;
using namespace cv;

class wf_Object
{
    public:
    
    //Point3f t; //be easier if you changed this to column vector
    //Point3f r; //be easier if you changed this to matrix
    
    cv::Mat t_init;
    cv::Mat r_init;
    
    cv::Mat t;
    cv::Mat r;
    
    wf_Object();
    wf_Object(cv::Mat t_, cv::Mat r_);
    wf_Object(metaio::Vector4d t, metaio::Rotation r);
    
    metaio::Vector4d getT_m();
    metaio::Rotation getR_m();
    
    void transform(metaio::Vector4d t_, metaio::Rotation r_);
};

#endif /* defined(__Demo__Object__) */
