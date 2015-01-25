//
//  AudioHandler.h
//  Demo
//
//  Created by Wolfgag on 1/23/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <TheAmazingAudioEngine.h>
#import "common.h"
#import "SoundObject.h"

class AudioHandler
{
    public:
    AEAudioController *audio_controller;
    SoundObject so;
    SoundObject so1;
    bool is_init;
    
    AudioHandler();
    void init(AEAudioController *ac_);
    void start();
    void update();
    void setPan(metaio::Vector3d t_, metaio::Rotation r_);
};