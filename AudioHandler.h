//
//  AudioHandler.h
//  Demo
//
//  Created by Wolfgag on 1/23/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <TheAmazingAudioEngine.h>
#import <unordered_map>
#import "common.h"
#import "Position.h"
#import "SoundObject.h"

class AudioHandler
{
    public:
    const float SCALE_COEFF = 0.01;
    
    NSMutableArray * log; //be careful, you gotta initialize this with every instance!
    
    AEAudioController *audio_controller;
    std::unordered_map<std::string, SoundObject>sound_objects;
    Position listener;
    bool is_init;
    
    AudioHandler();
    void init(AEAudioController *ac_);
    void start();
    void update();
//    bool add(SoundObject& so_);
    
    bool add(std::string name_, NSString * path_, metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0), float scale_ = 1.0);
    bool has(std::string name_);
    SoundObject& get(std::string name_);
    void setListener(metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0));
//    bool setListener(std::string name_, metaio::Vector3d t_ = metaio::Vector3d(0, 0, 0), metaio::Rotation r_ = metaio::Rotation(0, 0, 0));
    
    void printInfo(AEChannelGroupRef group_);
};