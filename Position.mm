//
//  Position.cpp
//  Demo
//
//  Created by Wolfgag on 2/1/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#include "Position.h"

Position::Position(metaio::Vector3d t_, metaio::Rotation r_, double scale_)
{
    t = t_;
    r = r_;
    scale = scale_;
}

bool operator== (const Position& left_, const Position& right_)
{
    return ((left_.t == right_.t) && (left_.r == right_.r) && (left_.scale == right_.scale));
}