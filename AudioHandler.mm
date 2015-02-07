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
    
    this->listener.scale = SCALE_COEFF;
    
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

bool AudioHandler::add(std::string name_, NSString * path_, metaio::Vector3d t_, metaio::Rotation r_, float scale_)
{
    if ( (sound_objects.count(name_)) )
    {
        NSLog(@"---AH--error: adding duplicate object %s", name_.c_str());
        return false;
    }
    SoundObject so;
    so.init(name_, path_, this->audio_controller);
    if (!so.is_init)
    {
        NSLog(@"---AH--error: failed to initialize object %s", name_.c_str());
        return false;
    }
    so.log = this->log;
    so.t = t_;
    so.r = r_;
    so.scale = this->listener.scale;
    std::pair<std::string,SoundObject> to_add (name_,so);
    this->sound_objects.insert(to_add);
    
    return true;
}

bool AudioHandler::has(std::string name_)
{
    if (!this->sound_objects.count(name_))
    {
        NSLog(@"---AH--error: no object for key %s", name_.c_str());
        return false;
    }
    return true;
}

SoundObject& AudioHandler::get(std::string name_)
//if you wanted to return by reference, you'd need a SoundObjectRef or ThingRef object, or an iterator return-type (safe, supposedly)
{
    return this->sound_objects.at(name_);
}

void AudioHandler::setListener(metaio::Vector3d t_, metaio::Rotation r_)
{
    this->listener.t = t_;
    this->listener.r = r_;
    for (auto& i : this->sound_objects) //i.first is key, i.second is object
    {
        i.second.setListener(t_, r_);
    }
}

//bool AudioHandler::setListener(std::string name_, metaio::Vector3d t_, metaio::Rotation r_)
//{
//    if (!this->sound_objects.count(name_))
//    {
//        NSLog(@"---AH--error: no object for key %s", name_.c_str());
//        return false;
//    }
//    SoundObject& so = this->sound_objects.at(name_);
//    so.setListener(t_, r_);
//    
//    return true;
//}

void AudioHandler::printInfo(AEChannelGroupRef group_)
{
    NSArray * channels = [this->audio_controller channels];
    NSArray * channel_groups = [this->audio_controller topLevelChannelGroups];
    NSArray * filters = [this->audio_controller filters];
    NSArray * filters_for_group = [this->audio_controller filtersForChannelGroup: group_];
    NSString * channels_s = [channels componentsJoinedByString:@", "];
    NSString * groups_s = [channel_groups componentsJoinedByString:@", "];
    NSString * filters_s = [filters componentsJoinedByString:@", "];
    NSString * filters_for_group_s = [filters_for_group componentsJoinedByString:@", "];
    NSLog([NSString stringWithFormat:@"channels: %@, groups: %@, filters: %@, filters_for_group: %@", channels_s, groups_s, filters_s, filters_for_group_s]);
}