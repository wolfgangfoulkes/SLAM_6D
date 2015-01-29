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
}

SoundObject::SoundObject(std::string name_) : SoundObject()
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
    this->volume = 0.5;
    
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
    
    //NSLog(@"%s -----", this->name.c_str());
    //printProperty();
    
    UInt32 algorithm = kSpatializationAlgorithm_SphericalHead;
    UInt32 size = sizeof(algorithm);
    AudioUnitSetProperty(this->au_3DMixer.audioUnit,
        kAudioUnitProperty_SpatializationAlgorithm,
        kAudioUnitScope_Input,
        0,
        &algorithm,
        size);
    
    //printProperty();
    //NSLog(@"----------");
    
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

void SoundObject::printProperty()
{
    UInt32 property_size[1];
    property_size[0] = 11111111;
    AudioUnitGetPropertyInfo( this->au_3DMixer.audioUnit,
    kAudioUnitProperty_SpatializationAlgorithm,
    kAudioUnitScope_Input,
    0,
    &property_size[0],
    NULL);
    NSLog(@"property size? %zu", property_size[0]);
    
    
    UInt32 algorithm[1];
    algorithm[0] = 11111111;
    UInt32 size = sizeof(algorithm);
    AudioUnitGetProperty( this->au_3DMixer.audioUnit,
    kAudioUnitProperty_SpatializationAlgorithm,
    kAudioUnitScope_Input,
    0,
    &algorithm[0],
    &size);
    switch(algorithm[0])
    {
        case 0:
            NSLog(@"EqualPowerPanning");
            break;
        case 1:
            NSLog(@"SphericalHead");
            break;
        case 2:
            NSLog(@"HRTF");
            break;
        case 3:
            NSLog(@"SoundField");
            break;
        case 4:
            NSLog(@"VectorBasedPanning");
            break;
        case 5:
            NSLog(@"StereoPassThrough");
            break;
        default:
            NSLog(@"unknown algorithm");
            break;
    }
}

void SoundObject::printProperties()
{
    //  Get number of parameters in this unit (size in bytes really):
    UInt32 parameterListSize = 0;
    AudioUnitGetPropertyInfo(this->au_3DMixer.audioUnit,
        kAudioUnitProperty_ParameterList,
        kAudioUnitScope_Input,
        0,
        &parameterListSize,
        NULL);

    //  Get ids for the parameters:
    AudioUnitParameterID parameterIDs[parameterListSize];
    AudioUnitGetProperty(this->au_3DMixer.audioUnit,
        kAudioUnitProperty_ParameterList,
        kAudioUnitScope_Input,
        0,
        &parameterIDs[0],
        &parameterListSize);

    AudioUnitParameterInfo parameterInfo_t;
    UInt32 parameterInfoSize = sizeof(AudioUnitParameterInfo);
    UInt32 parametersCount = parameterListSize / sizeof(AudioUnitParameterID);
    NSLog(@"# of parameters: %zu", parametersCount);
    
    for(UInt32 pIndex = 0; pIndex < parametersCount; pIndex++)
    {
        AudioUnitGetProperty(this->au_3DMixer.audioUnit,
            kAudioUnitProperty_ParameterInfo,
            kAudioUnitScope_Input,
            parameterIDs[pIndex],
            &parameterInfo_t,
            &parameterInfoSize);
            NSLog(@"param %s: min value = %f, max value = %f", parameterInfo_t.name, parameterInfo_t.minValue, parameterInfo_t.maxValue);
    }
}