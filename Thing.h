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
    std::string name;
    std::string type;
    Pose pose;
    //int COS;
    metaio::Vector3d t;
    metaio::Rotation r;
    bool is_loaded;
    bool is_init;
    
    Thing();
    
    virtual void load();
    virtual void init(); //load content
    virtual void update();
    virtual void render();
    
    friend bool operator== (const Thing& left_, const Thing& right_);
};

#endif /* defined(__Demo__Thing__) */
