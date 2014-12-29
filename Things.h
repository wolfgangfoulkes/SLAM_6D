//
//  Things.h
//  Demo
//
//  Created by Wolfgag on 12/29/14.
//  Copyright (c) 2014 metaio GmbH. All rights reserved.
//

#ifndef __Demo__Things__
#define __Demo__Things__
#import "Thing.h"

class Object3D : public Thing
{
    public:
    metaio::IMetaioSDKIOS*	sdk;
    metaio::IGeometry * object;
    NSString * path;
    int render_order;
    float scale;
    
    Object3D();
    Object3D(metaio::Vector3d t_, metaio::Rotation r_); //because base class has this, prolly need to do more stuff
    
    void init();
    void init(metaio::IMetaioSDKIOS* sdk_, NSString * path_, int render_order_, float scale_, metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0));
    void update();
    void render();
};


#endif /* defined(__Demo__Things__) */
