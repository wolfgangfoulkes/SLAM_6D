//
//  AudioHandler.cpp
//  Demo
//
//  Created by Wolfgag on 1/23/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

#import "AudioHandler.h"

AudioHandler::AudioHandler()
{
}

void AudioHandler::init(AEAudioController* ac_)
{
    if (!ac_)
    {
        NSLog(@"error bad audio controller");
        return;
    }
    this->audio_controller = ac_;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Assets/sound/pain" ofType:@"mp3"];
    this->so.t = metaio::Vector3d(-800, 0, 0);
    so.init("one", path, this->audio_controller);
    
    NSString * path1 = [[NSBundle mainBundle] pathForResource:@"Assets/sound/success" ofType:@"mp3"];
    this->so1.t = metaio::Vector3d(800, 0, 0);
    so1.init("two", path1, this->audio_controller);
    
    is_init = true;
}

void AudioHandler::start()
{
    NSError* error = NULL;
    BOOL result = [this->audio_controller start:&error];
    if ( !result ) {
        NSLog(@"error starting audio");
    }
}

void AudioHandler::update()
{
    
}

void AudioHandler::setPan(metaio::Vector3d t_, metaio::Rotation r_)
{
        so.setPan(t_, r_);
        so1.setPan(t_, r_);
}