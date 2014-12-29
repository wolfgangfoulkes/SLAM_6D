//
//  Thing.h
//  Demo
//
//  Created by Wolfgag on 12/29/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#ifndef __Demo__Thing__
#define __Demo__Thing__

#import "Pose.h"

class Thing
{
    public:
    Pose pose;
    //int COS;
    metaio::Vector3d t;
    metaio::Rotation r;
    bool is_init;
    
    Thing();
    Thing(metaio::Vector3d t_, metaio::Rotation r_);
    
    virtual void init(); //load content
    virtual void update();
    virtual void render();
};

#endif /* defined(__Demo__Thing__) */
