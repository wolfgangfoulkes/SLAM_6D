//
//  SoundObject.h
//  Demo
//
//  Created by Wolfgag on 1/25/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#ifndef __Demo__SoundObject__
#define __Demo__SoundObject__

#import <AudioToolbox/AudioToolbox.h>
#import "TheAmazingAudioEngine.h"
#import "Position.h"
#import "Thing.h"

class SoundObject : public Thing
{
    public:
    NSMutableArray * log; //be careful, you gotta initialize this with every instance!
    
    NSString * path;
    AEChannelGroupRef channel_group;
    AEAudioUnitFilter *au_3DMixer;
    double volume;
    
    AEAudioFilePlayer *loop; //temporary
    
    SoundObject();
    SoundObject(std::string name);
    void init(); //should get rid of specialized "init" and instead have init check for correct vars set?
    void init(std::string name_);
    void init(std::string name_, NSString * path_, AEAudioController * ac_/*, int channelIndex*/);
    void load();
    void update();
    void render();
    
    void setListener(metaio::Vector3d t_, metaio::Rotation r_);
    void setListener(Position p_);
    
    void printProperty();
    void printProperties();
};

#endif /* defined(__Demo__SoundObject__) */
