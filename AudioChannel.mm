#import "AudioChannel.h"


@implementation AudioChannel

-(id)init
{
    return self;
}

static OSStatus renderCallback(__unsafe_unretained AudioChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {

    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback{
    return (AEAudioControllerRenderCallback)renderCallback;
}


@end