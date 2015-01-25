// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import <math.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/calib3d.hpp>
#import <QuartzCore/QuartzCore.h>

#import <AudioToolbox/AudioToolbox.h>

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <CoreMotion/CoreMotion.h>
#import <TheAmazingAudioEngine.h>
#import "InstantTrackingViewController.h"
#import "EAGLView.h"


#import "common.h"
#import "Pose.h"

int printf(const char * __restrict format, ...) //printf don't print to console
//from http://stackoverflow.com/questions/8924831/iphone-debugging-real-device
{ 
    va_list args;
    va_start(args,format);
    NSLogv([NSString stringWithUTF8String:format], args) ;
    va_end(args);
    return 1;
}

#define MM_INTERVAL (1.0f/30.0f)

@interface InstantTrackingViewController ()
{
}

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEAudioFilePlayer *loop1;
@property (nonatomic, strong) AEAudioUnitFilter *au_filter;
@property (nonatomic, strong) AEAudioUnitFilter *au_3DMixer;


@end


@implementation InstantTrackingViewController

@synthesize webView;
@synthesize debugViewToggle;

/*****UNUSED*****/
@synthesize debugPrintButton;

- (void) initAudio
{
    NSLog(@"-----Audio---!");
    
    //create audio controller
    self.audioController = [[AEAudioController alloc]
                           initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                               inputEnabled:NO];
    //setup file player
    NSURL* sound_url = [[NSBundle mainBundle] URLForResource:@"Assets/sound/pain" withExtension:@"mp3"];
    if (!sound_url)
    {
        NSLog(@"error bad path");
    }
    self.loop1 = [AEAudioFilePlayer
        audioFilePlayerWithURL:sound_url
        audioController:_audioController
        error:NULL];
    if (!self.loop1)
    {
        NSLog(@"error creating loop");
    }
    _loop1.volume = 0.5;
    _loop1.channelIsMuted = NO;
    _loop1.loop = YES;

    
    //add player to controller
    [_audioController addChannels:@[_loop1]];
    
    //create filter
    AudioComponentDescription filter = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                     kAudioUnitType_Effect,
                                     kAudioUnitSubType_Reverb2);
    NSError *error = NULL;
    self.au_filter = [[AEAudioUnitFilter alloc]
                      initWithComponentDescription:filter
                                   audioController:_audioController
                                             error:&error];
    if ( ! _au_filter ) {
        NSLog(@"failed to create filter");
    }

    
    //add filter to controller's master output
    //[self.audioController addFilter:_au_filter];
    
    //create mixer https://developer.apple.com/library/mac/technotes/tn2112/_index.html
    error = NULL;
    AudioComponentDescription mixerCD;

    mixerCD.componentFlags = 0; 
    mixerCD.componentFlagsMask = 0; 
    mixerCD.componentType = kAudioUnitType_Mixer; 
    mixerCD.componentSubType = kAudioUnitSubType_AU3DMixerEmbedded;
    mixerCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    self.au_3DMixer = [[AEAudioUnitFilter alloc]
                        initWithComponentDescription:mixerCD
                        audioController:_audioController
                        useDefaultInputFormat: YES
                        error:&error];
    
    if ( ! _au_3DMixer ) {
        NSLog(@"failed to create mixer");
    }
    
    //add mixer to controller's master output
    [self.audioController addFilter:_au_3DMixer];
    
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
    AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                    k3DMixerParam_Distance,
                    kAudioUnitScope_Input,
                    0,
                    1.0f,
                    0);
    AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                    k3DMixerParam_Elevation,
                    kAudioUnitScope_Input,
                    0,
                    0.0f,
                    0);
    AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                    k3DMixerParam_Azimuth,
                    kAudioUnitScope_Input,
                    0,
                    0.0f,
                    0);

    
    
    //start controller
    error = NULL;
    BOOL result = [_audioController start:&error];
    if ( !result ) {
        NSLog(@"error starting audio");
    }
    
    NSLog(@"-----");
}


# pragma mark - LOOP

- (void) update
{
    if (!debugViewIsInit)
    {
        return;
    }
    
    if (!debugHandler.jsIsInit)
    {
        return;
    }
    

    [self updateTrackingState];
    if (updateMetaio && activeCOS)
    {
        metaio::TrackingValues tv = m_metaioSDK->getTrackingValues(activeCOS);
        [self offsetTrackingValues:tv];

        //http://www.evl.uic.edu/ralph/508S98/coordinates.html
        //right-handed right:x+, up:y+, screen:z-, rotation is counterclockwise around axis
        //left-handed right:x+, up:y+, screen:z+, rotation is clockwise around axis
        
        if (!cam.hasInitOffs)
        {
            cam.setInitOffs(tv);
        }
        
        if (cam.COS && (activeCOS != cam.COS)) //if the pose has tracked a COS, and the COS has changed
        {
            cam.setOffs(tv);
            logMA([NSString stringWithFormat:@"lastCOS: %d, activeCOS: %d, cam.COS: %d", lastCOS, activeCOS, cam.COS], ma_log);
        }
        
        cam.updateP(tv);
        
        //position objects
        metaio::Vector3d t;
        metaio::Vector3d eu;
        metaio::Rotation r;
        
        if (!hasTracking)
        {
            hasTracking = true;
        }
        
        double azimuth = 0;
        double elevation = 0;
        double distance = 0;
        
        calcPanPosition(cam.t_last, cam.r_last, azimuth, elevation, distance);
        
        AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                        k3DMixerParam_Azimuth,
                        kAudioUnitScope_Input, //kAudioUnitScope_Input
                        0,
                        azimuth,
                        0);
        AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                        k3DMixerParam_Elevation,
                        kAudioUnitScope_Input, //kAudioUnitScope_Input
                        0,
                        elevation,
                        0);
        AudioUnitSetParameter(  _au_3DMixer.audioUnit,
                        k3DMixerParam_Distance,
                        kAudioUnitScope_Input, //kAudioUnitScope_Input
                        0,
                        distance * 0.01,
                        0);
    }
    debugHandler.update();
}

- (void) updateTrackingState
{
    int activeCOS_ = 0;
    int COSs = m_metaioSDK->getNumberOfValidCoordinateSystems();
    int allCOSs = m_metaioSDK->getNumberOfDefinedCoordinateSystems();
    string state = "not tracking";
    if (COSs)
    {
        metaio::TrackingValues cos1 = m_metaioSDK->getTrackingValues(1);
        metaio::TrackingValues cos2 = m_metaioSDK->getTrackingValues(2);
        if (cos1.isTrackingState()) {activeCOS_ = 1;}
        else if (cos2.isTrackingState()) {activeCOS_ = 2;}
        else {
            //logMA(@"unknownCOS", ma_log);
        }
        metaio::TrackingValues tv = m_metaioSDK->getTrackingValues(activeCOS);
        state = tv.trackingStateToString(tv.state);
        isTracking = true;
    }
    else {
        isTracking = false;
    }
    
    if (activeCOS_ != activeCOS)
    {
        NSString * _fmt = @"changing COS: %d=>%d";
        NSString * _s = [NSString stringWithFormat:_fmt, activeCOS, activeCOS_];
        logMA(_s, ma_log);
    }
    
    lastCOS = activeCOS;
    activeCOS = activeCOS_;
    
    debugHandler.COS = activeCOS;
    debugHandler.tracking_state = state;
}



- (void) offsetTrackingValues: (metaio::TrackingValues&)tv_
{
    metaio::Vector3d offs_t;
    metaio::Rotation offs_r;
    metaio::Vector3d offs_eu;
    offs_t.x = 0;
    offs_t.y = 0;
    offs_t.z = 0;
    offs_eu.x = 90; //metaio's object COS faces up.
    offs_eu.y = 0;
    offs_eu.z = 0;
    offs_r.setFromEulerAngleDegrees(offs_eu);
    tv_.translation = tv_.translation + offs_t;
    tv_.rotation = tv_.rotation * offs_r;
}

#pragma mark - UIView(s)Controller lifecycle

/***** INITIALIZE VARIABLES, LOAD MODEL *****/
- (void) viewDidLoad
{
	[super viewDidLoad];
    printf("view did load! version: %s", m_metaioSDK->getVersion().c_str());
    
    // Set the rendering clipping plane
    m_metaioSDK->setRendererClippingPlaneLimits(10, 30000);
    
    /***** Load content *****/
//    m_scale = 1; // Initial scaling for the models
//    m_obj_t = metaio::Vector3d(0, 0, 0);
//    m_obj_r = metaio::Rotation();
//    m_obj           = [self createModel:@"head" ofType:@"obj" inDirectory:@"Assets/obj" renderOrder:0  modelTranslation:m_obj_t modelScaling:m_scale modelCos:0];
//    
//    m_scale1 = 1; // Initial scaling for the models
//    m_obj1_t = metaio::Vector3d(50, 0, -50);
//    m_obj1_r = metaio::Rotation();
//    m_obj1           = [self createModel:@"head" ofType:@"obj" inDirectory:@"Assets/obj" renderOrder:1  modelTranslation:m_obj1_t modelScaling:m_scale modelCos:0];
    /*****/
    
    //init tracking vars
    lastCOS = activeCOS = 0;
    isTracking = hasTracking = false;
    
    //shared debug log
    ma_log = [[NSMutableArray alloc] init];
    cam.ma_log = ma_log; //be careful, you gotta initialize this with every instance!
    debugHandler.log = ma_log;
    debugHandler.pose = &cam;
    debugViewIsInit = false; //initialized when web view loads
    
    showDebugView = true; //debug view shows on launch
    debugHandler.print = showDebugView;
    
    //should the loop update metaio?
    updateMetaio = true;
    
    //Web View
    webView.scrollView.scrollEnabled = NO;
    self.webView.delegate = self;
    [self loadDebugView];
    
    //CMMotionManager
    if(self.motionManager.isDeviceMotionAvailable)
    {
//        [self.motionManager startDeviceMotionUpdates];
//        self.motionManager.deviceMotionUpdateInterval = MM_INTERVAL;
    }
    
    //init time
    elapsed = [[NSDate alloc] init];
    
    [self initAudio];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setTrackingConfiguration];
}


- (void)viewDidUnload
{
	[super viewDidUnload];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Web View did load!");
    [self initDebugView];
    debugViewIsInit = true;
}

#pragma mark - CMMotionManager


- (CMMotionManager *)motionManager
{
   CMMotionManager *motionManager = nil;
   id appDelegate = [UIApplication sharedApplication].delegate;
   if ([appDelegate respondsToSelector:@selector(motionManager)]) {
     motionManager = [appDelegate motionManager];
   }
   return motionManager;
}


#pragma mark - metaio SDK

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)poses
{
    if (poses.empty())
    {
        logMA(@"poses is empty", ma_log);
		return;
    }
    
    string _state = poses[0].trackingStateToString(poses[0].state);
    logMA([NSString stringWithFormat:@"tracking event: %s", _state.c_str()], ma_log);
    [self updateTrackingState];
    
    if (poses[0].state == metaio::ETS_LOST)
    {
//        if (useInstantTracking)
//        {
//            cam.COS = 0;
//        }
    }
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
	// Load the tacking configuration
	if (success)
	{
		m_metaioSDK->setTrackingConfiguration([file UTF8String]);
        m_metaioSDK->sensorCommand("drawFeatures", "false");
    }
	else
	{
		NSLog(@"SLAM has timed out!");
	}
    logMA(@"\ninstant tracking!1!?\n", ma_log);
	
}

- (void)onSDKReady
{
	[super onSDKReady];
    
}

- (void)drawFrame
{
	[super drawFrame];
	
	// tell sdk to render
	if (m_metaioSDK)
	{
        [self update];
	}
}

/**
 * Set the tracking configuration file
 */
- (void) setTrackingConfiguration {
    NSString* config = [NSString stringWithFormat:@"Tracking_SLAM"];
	NSString* dir = [NSString stringWithFormat:@"Assets"];
    NSString* ext = [NSString stringWithFormat:@"xml"];
	NSString* tr = [[NSBundle mainBundle] pathForResource:config ofType:ext inDirectory:dir];
	
    bool success = m_metaioSDK->setTrackingConfiguration([tr UTF8String]);
    if(success)
    {
        //offset metaio's COS's
//        int COSs = m_metaioSDK->getNumberOfDefinedCoordinateSystems();
//        metaio::TrackingValues offs;
//        metaio::Vector3d offs_euler(90.0, 0.0, 0.0);
//        offs.rotation.setFromEulerAngleDegrees(offs_euler);
//        logMA([NSString stringWithFormat:@"defined: %d", COSs], ma_log);
//        for (int i = 0; i < COSs; i++)
//        {
//            m_metaioSDK->setCosOffset(i+1, offs);
//        }
    }
    else
    {
        NSLog(@"No success loading the tracking configuration");
        logMA(@"No success loading the tracking configuration", ma_log);
    }
    
}

/**
 * Create a model
 * @param resource - model resource
 * @param type - model type (obj, md2 ...)
 * @param directory - directory where the resource is located
 * @param renderOrder - render order
 * @param translation - model tranlation
 * @param scale - model scale
 */
- (metaio::IGeometry*) createModel:(NSString*)resource ofType:(NSString*)type inDirectory:(NSString*)directory renderOrder:(NSInteger)renderOrder modelTranslation:(metaio::Vector3d)translation modelScaling:(NSInteger)scale modelCos:(NSInteger)cos
{
    metaio::IGeometry* geometry = nullptr;
    
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:resource
                                                          ofType:type
                                                     inDirectory:directory];
	
	if (modelPath)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
		geometry =  m_metaioSDK->createGeometry([modelPath UTF8String]);
		if (geometry)
		{
            geometry->setScale(scale);
            geometry->setTranslation(translation);
            geometry->setRenderOrder(renderOrder);
            geometry->setCoordinateSystemID(cos);
		}
		else
		{
			NSLog(@"error, could not load %@", modelPath);
		}
	}
    
    return geometry;
}




- (void) updateObjectsWithCameraT: (metaio::Vector3d)t AndR:(metaio::Rotation)r
{
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// allow rotation in all directions
	return NO;
}

#pragma mark - Button handlers

- (IBAction)onDebugDown:(id)sender {
    [self.webView setHidden:![self.webView isHidden] ];
    showDebugView = !showDebugView;
    debugHandler.print = showDebugView;
}

- (IBAction)onPrintDown:(id)sender {
    logMA(
    [NSString stringWithFormat:@"last: %s\npose: %s\ninit%s",
    tRToS(cam.t_last, cam.r_last).c_str(),
    tRToS(cam.t_p, cam.r_p).c_str(),
    tRToS(cam.t_offs, cam.r_offs).c_str()],
    ma_log);
}

# pragma mark - JS Debug

- (void)loadDebugView {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Assets/web/slam" ofType:@"html"] isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void) initDebugView {
    ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSAssert([ctx isKindOfClass:[JSContextclass]], @"could not find context in web view");
    
    debugHandler.initJS(ctx);
}


@end
