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
    this->type = "Thing";
    this->name = "undefined";
    this->is_loaded = false;
    this->is_init = false;
}

void Thing::init()
{
    //you don't want to initialize is_init for inheriting classes
}

void Thing::load()
{
}

void Thing::update()
{
}

void Thing::render()
{
}

bool operator== (const Thing& left_, const Thing& right_)
{
    return ((left_.type == right_.type) && (left_.name == right_.name));
}

