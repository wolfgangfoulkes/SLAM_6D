//
//  Thing.cpp
//  Demo
//
//  Created by Wolfgag on 12/29/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#import "Thing.h"

Thing::Thing()
{
    is_init = false;
}

Thing::Thing(metaio::Vector3d t_, metaio::Rotation r_) : t(t_), r(r_)
{
    is_init = false;
}

void Thing::init()
{
    //you don't want to initialize is_init for inheriting classes
}

void Thing::update()
{
}

void Thing::render()
{
}