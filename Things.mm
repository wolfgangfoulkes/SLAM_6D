//
//  Things.cpp
//  Demo
//
//  Created by Wolfgag on 12/29/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#include "Things.h"

Object3D::Object3D() : Thing() //this happens by default anyway, just ta let ya nough
{
    this->type = "Object3D";
    this->path = "undefined";
    this->scale = 1.0;
    this->is_visible = true; //false l8er
}

Object3D::Object3D(std::string name_) : Object3D()
{
    this->name = name_;
}

void Object3D::init(std::string name_, std::string path_, metaio::Vector3d t_, metaio::Rotation r_, float scale_)
{
    this->name = name_;
    this->path = path_;
    
    this->t = t_;
    this->r = r_;
    this->scale = scale_;
    
    this->is_init = true;
}

void Object3D::load()
{
}

void Object3D::update()
{
}

void Object3D::render()
{
}