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

    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Assets/sound/pain" withExtension:@"mp3"];
    if (!url)
    {
        NSLog(@"error bad path");
        return;
    }
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Assets/sound/pain" ofType:@"mp3"];
    so.init("dave", path, this->audio_controller);
    
    this->loop1 = [AEAudioFilePlayer
        audioFilePlayerWithURL:url
        audioController:this->audio_controller
        error:NULL];
    
    if (!this->loop1)
    {
        NSLog(@"error creating loop");
        return;
    }
    this->loop1.volume = 0.0;
    this->loop1.channelIsMuted = NO;
    this->loop1.loop = YES;
    
    
    //add player to controller
    [this->audio_controller addChannels:@[this->loop1]];
    
    NSError *error = NULL;
    AudioComponentDescription mixerCD;

    mixerCD.componentFlags = 0; 
    mixerCD.componentFlagsMask = 0; 
    mixerCD.componentType = kAudioUnitType_Mixer; 
    mixerCD.componentSubType = kAudioUnitSubType_AU3DMixerEmbedded;
    mixerCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    this->au_3DMixer = [[AEAudioUnitFilter alloc]
                        initWithComponentDescription:mixerCD
                        audioController:this->audio_controller
                        useDefaultInputFormat: YES
                        error:&error];
    
    if ( ! this->au_3DMixer ) {
        NSLog(@"failed to create mixer");
        return;
    }
    
    //add mixer to controller's master output
    [this->audio_controller addFilter:this->au_3DMixer];
    
    //initialize mixer params (THIS IS NECESSARY)
    /*  (
        AudioUnit inUnit,
        AudioUnitParameterID inID, 
        AudioUnitScope inScope, 
        AudioUnitElement inElement, 
        AudioUnitParameterValue inValue, 
        UInt32 inBufferOffsetInFrames 
        );
    */
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
    this->so.t = metaio::Vector3d(500, 0, 250);
    
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
        double azimuth = 0;
        double elevation = 0;
        double distance = 0;
        
        calcPanPosition(t_, r_, azimuth, elevation, distance);
        
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
    
        so.setPan(t_, r_);
}