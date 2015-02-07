//
//  Position.h
//  Demo
//
//  Created by Wolfgag on 2/1/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#ifndef __Demo__Position__
#define __Demo__Position__

#import "common.h"

class Position
{
    public:
    metaio::Vector3d t;
    metaio::Rotation r;
    double scale;
    Position(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0), double scale_ = 0.0);
    //this is still a default constructor
    
    friend bool operator== (const Position& left_, const Position& right_);
};


#endif /* defined(__Demo__Position__) */
