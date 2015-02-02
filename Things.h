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
    std::string path;
    bool is_render;
    
    Object3D();
    Object3D(std::string name_); //probably ought remove this.
    void init(std::string name_, std::string path_ = "undefined", metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0), float scale_ = 1.0);
    void load();
    void update();
    void render();
};


#endif /* defined(__Demo__Things__) */
