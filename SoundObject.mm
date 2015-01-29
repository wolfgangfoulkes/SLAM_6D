//
//  SoundObject.cpp
//  Demo
//
//  Created by Wolfgag on 1/25/15.
//  Copyright (c) 2015 metaio GmbH. All rights reserved.
//

//for future simplicity, it would be possible to have this guy's internals initalized in the handler, and have him store just the mixer and the group ref
//not necessary though, and not preferable if shit works

#import "SoundObject.h"
#import "common.h"

SoundObject::SoundObject() : Thing()
{
    this->type = "SoundObject";
    this->name = "undefined";
}

SoundObject::SoundObject(std::string name_)
{
    this->name = name_;
}

void SoundObject::init()
{
}

void SoundObject::init(std::string name_)
{
    this->name = name_;
}

void SoundObject::init(std::string name_, NSString * path_, AEAudioController * ac_)
{
    this->name = name_;
    this->path = [NSString stringWithString: path_];
    NSURL * url = [NSURL fileURLWithPath:this->path];
    if (!url)
    {
        NSLog([NSString stringWithFormat:@"%@ : %@", @"error, bad path", [url path]]);
        return;
    }
    
    if (!ac_)
    {
        NSLog(@"error : no audio controller");
        return;
    }
    
    this->loop = [AEAudioFilePlayer
                audioFilePlayerWithURL:url
                audioController:ac_
                error:NULL];
    
    if (!this->loop)
    {
        NSLog(@"error : creating loop");
        return;
    }
    
    this->loop.volume = 0.5;
    this->loop.channelIsMuted = NO;
    this->loop.loop = YES;
    
    this->channel_group = [ac_ createChannelGroup];
    [ac_ addChannels:@[this->loop] toChannelGroup:this->channel_group];
    
    NSError *error = NULL;
    AudioComponentDescription mixerCD;
    
    mixerCD.componentFlags = 0; 
    mixerCD.componentFlagsMask = 0; 
    mixerCD.componentType = kAudioUnitType_Mixer;
    mixerCD.componentSubType = kAudioUnitSubType_AU3DMixerEmbedded;
    mixerCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    this->au_3DMixer = [[AEAudioUnitFilter alloc]
                        initWithComponentDescription:mixerCD
                        audioController:ac_
                        useDefaultInputFormat: YES
                        error:&error];
    
    if ( ! this->au_3DMixer ) {
        NSLog(@"failed to create mixer");
        return;
    }
    
    [ac_ addFilter:this->au_3DMixer toChannelGroup:this->channel_group];
//    NSArray * channels = [ac_ channels];
//    NSArray * channel_groups = [ac_ topLevelChannelGroups];
//    NSArray * filters = [ac_ filters];
//    NSArray * filters_for_group = [ac_ filtersForChannelGroup: this->channel_group];
//    NSString * channels_s = [channels componentsJoinedByString:@", "];
//    NSString * groups_s = [channel_groups componentsJoinedByString:@", "];
//    NSString * filters_s = [filters componentsJoinedByString:@", "];
//    NSString * filters_for_group_s = [filters_for_group componentsJoinedByString:@", "];
//    NSLog([NSString stringWithFormat:@"channels: %@, groups: %@, filters: %@, filters_for_group: %@", channels_s, groups_s, filters_s, filters_for_group_s]);
    
    
    //initialize mixer params (THIS IS NECESSARY)
    /*****
    (
    AudioUnit inUnit,
    AudioUnitParameterID inID, 
    AudioUnitScope inScope,
    AudioUnitElement inElement,
    AudioUnitParameterValue inValue, 
    UInt32 inBufferOffsetInFrames 
    );
    *****/
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Distance,
                    kAudioUnitScope_Input,
                    0,
                    1.0f,
                    0);
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Elevation,
                    kAudioUnitScope_Input,
                    0,
                    0.0f,
                    0);
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Azimuth,
                    kAudioUnitScope_Input,
                    0,
                    0.0f,
                    0);
    
    this->is_init = true;
}

void SoundObject::load()
{
}

void SoundObject::update()
{
}

void SoundObject::render()
{
}

bool operator== (const SoundObject& left_, const SoundObject& right_)
{
    return ((left_.type == right_.type) && (left_.name == right_.name));
}

void SoundObject::setPan(metaio::Vector3d t_, metaio::Rotation r_)
{
    metaio::Vector3d t_adj = r_.rotatePoint(this->t) + t_; //this or r.inverse, dunno which
    //rotation is correct, translation seems mostly correct, but maybe buggy
    
    double azimuth = 0;
    double elevation = 0;
    double distance = 0;
    
    cartesianToSpherical(t_adj, r_, azimuth, elevation, distance);
    
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Azimuth,
                    kAudioUnitScope_Input, //kAudioUnitScope_Input
                    0,
                    azimuth,
                    0);
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Elevation,
                    kAudioUnitScope_Input, //kAudioUnitScope_Input
                    0,
                    elevation,
                    0);
    AudioUnitSetParameter(  this->au_3DMixer.audioUnit,
                    k3DMixerParam_Distance,
                    kAudioUnitScope_Input, //kAudioUnitScope_Input
                    0,
                    distance * 0.01,
                    0);
}