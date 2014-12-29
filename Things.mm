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
    object = nullptr;
    path = nullptr;
    render_order = 0;
    scale = 0.0;
}

Object3D::Object3D(metaio::Vector3d t_, metaio::Rotation r_) : Object3D()
{
    this->t = t_;
    this->r = r_;
}

void Object3D::init(metaio::IMetaioSDKIOS* sdk_, NSString * path_, int render_order_, float scale_, metaio::Vector3d t_, metaio::Rotation r_)
{
    this->t = t_;
    this->r = r_;
    
    this->sdk = sdk_;
    
    this->path = path_;
    this->render_order = render_order_;
    this->scale = scale_;
    
    if (this->path)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
		this->object =  this->sdk->createGeometry([this->path UTF8String]);
		if (this->object)
		{
            metaio::Vector3d obj_t_init(0, 0, 0);
            metaio::Rotation obj_r_init(0, 0, 0);
            this->object->setScale(scale);
            this->object->setRenderOrder(this->render_order);
            this->object->setTranslation(obj_t_init);
            this->object->setRotation(obj_r_init);
            this->object->setCoordinateSystemID(0);
		}
		else
		{
			NSLog(@"error, could not load %@", this->path);
		}
	}
}

void Object3D::update()
{
}

void Object3D::render()
{
}