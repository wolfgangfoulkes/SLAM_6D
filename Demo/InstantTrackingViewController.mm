// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/calib3d.hpp>
#import <QuartzCore/QuartzCore.h>

#import "InstantTrackingViewController.h"
#import "EAGLView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MapTransitionHelper.h"

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

@interface InstantTrackingViewController ()
{
    // Instance of a class that helps moving from one map to the next one, without the user noticing it
    metaio::MapTransitionHelper mapTransitionHelper;
}

@end


@implementation InstantTrackingViewController

@synthesize webView;
@synthesize debugViewToggle;
@synthesize debugPrintButton;
@synthesize XppButton;
@synthesize XmmButton;
@synthesize YppButton;
@synthesize YmmButton;
@synthesize ZppButton;
@synthesize ZmmButton;

#pragma mark - UIViewController lifecycle

/***** INITIALIZE VARIABLES, LOAD MODEL *****/
- (void) viewDidLoad
{
	[super viewDidLoad];
    printf("view did load! version: %s", m_metaioSDK->getVersion().c_str());
    
    // Set the rendering clipping plane
    m_metaioSDK->setRendererClippingPlaneLimits(10, 30000);
    
    // Initial scaling for the models
    m_scale = 1;
    
    cam = Pose(metaio::Vector3d(0,0,0), metaio::Rotation(0,0,0));
    obj = Pose(metaio::Vector3d(-100,0,-100), metaio::Rotation(0,0,0));
    //from front-left of room
    
    //Initialize frame count
    m_frames = 0;
    
    // Load content //FLAG CHANGED RENDER ORDER TO SAME
    
    m_obj           = [self createModel:@"head" ofType:@"obj" inDirectory:@"Assets/obj" renderOrder:0  modelTranslation:obj.t modelScaling:m_scale modelCos:0];
//    m_obj1           = [self createModel:@"head" ofType:@"obj" inDirectory:@"Assets/obj" renderOrder:0  modelTranslation:m_obj1_t modelScaling:m_scale modelCos:0];
    
    activeCOS = -1;
    isTracking = false;
    
    debugView = true;
    printToScreen = false;
    
    [self loadDebugView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setTrackingConfiguration];
}


- (void)viewDidUnload
{
	[super viewDidUnload];
}



#pragma mark - metaio SDK

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)poses
{
    if (poses.empty())
    {
        printf("poses is empty");
		return;
    }
    
    //[self printETSState:poses[0].state];
    
    if (poses[0].state == metaio::ETS_LOST)
    {
        mapTransitionHelper.prepareForTransitionToNewMap();
    }
	else
	{
		if (poses[0].state == metaio::ETS_INITIALIZATION_FAILED) //this can mean we are transitioning to a new map
        {
            mapTransitionHelper.prepareForTransitionToNewMap();
            printf("init failed!");
        }
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
		//NSLog(@"SLAM has timed out!");
	}
    printf("\ninstant tracking!1!?\n");
	
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




#pragma mark - App Logic

/**
 * Set the tracking configuration file
 */
- (void) setTrackingConfiguration {
    NSString* config = [NSString stringWithFormat:@"Tracking_TBSLAM"];
	NSString* dir = [NSString stringWithFormat:@"Assets"];
    NSString* ext = [NSString stringWithFormat:@"xml"];
	NSString* tr = [[NSBundle mainBundle] pathForResource:config ofType:ext inDirectory:dir];
	
    bool success = m_metaioSDK->setTrackingConfiguration([tr UTF8String]);
    if(!success)
    {
        NSLog(@"No success loading the tracking configuration");
    }
    else
    {
        //NSLog(@"Success loading the tracking configuration");
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

- (void) updateTrackingState
{
    int COSs = m_metaioSDK->getNumberOfValidCoordinateSystems();
    if (COSs)
    {
        metaio::TrackingValues cos1 = m_metaioSDK->getTrackingValues(1);
        metaio::TrackingValues cos2 = m_metaioSDK->getTrackingValues(2);
        if (cos1.isTrackingState()) {activeCOS = 1;}
        else if (cos2.isTrackingState()) {activeCOS = 2;}
        
        metaio::TrackingValues tv = m_metaioSDK->getTrackingValues(activeCOS);
        string state = tv.trackingStateToString(tv.state);
        [self updateDebugViewWithActiveCos:activeCOS AndStatus:state];
        
        isTracking = true;
    }
    else {
        mapTransitionHelper.prepareForTransitionToNewMap();
        activeCOS = -1;
        isTracking = false;
    }
}

/**
 * Update the scale, rotation and translation of the models
 */
- (void) update
{
    //float tvm[16];
    metaio::TrackingValues tv = m_metaioSDK->getTrackingValues(activeCOS);
    
    //m_metaioSDK->getTrackingValues(activeCOS, tvm, true); //false if you want only modelMatrix. additional true to get a right-handed system
    //http://www.evl.uic.edu/ralph/508S98/coordinates.html
    //right-handed right:x+, up:y+, screen:z-, rotation is counterclockwise around axis
    //left-handed right:x+, up:y+, screen:z+, rotation is clockwise around axis
    
    //matrix maps object onto tracked object.
    //cv::Mat tv_mat = cv::Mat::Mat(4, 4, CV_32F, tvm);
    //metaio::stlcompat::String points = m_metaioSDK->sensorCommand((metaio::stlcompat::String)"getNewMapFeatures");

    // Update the internal state with the lastest tracking values from the SDK.
    mapTransitionHelper.update(m_metaioSDK->getTrackingValues(activeCOS), m_metaioSDK->getRegisteredSensorsComponent()->getLastSensorValues());
    
    if (tv.quality == 1.0)
    {
        cam.updateP(tv);
    }

    
    // If the last frame could be tracked successfully
    if(mapTransitionHelper.lastFrameWasTracked())
    {
        metaio::Rotation newRotation = mapTransitionHelper.getRotationCameraFromWorld();//tv.rotation;
        metaio::Vector3d newTranslation = mapTransitionHelper.getTranslationCameraFromWorld();//tv.translation;
        metaio::Vector3d newTranslation_r = metaio::Rotation(0, 0, dToR(180.)).rotatePoint(newTranslation);

        
        m_obj->setScale(m_scale);
        m_obj->setRotation(newRotation);
        metaio::Vector3d t = newTranslation_r + obj.t_world;
        
        m_obj->setTranslation(t);
    }
    if (debugView) //replace this with button press!
    {
        [self updateDebugViewWithCameraT:cam.t andR:cam.r andObjectT:obj.t andR:obj.r];
    }
    
    
    m_frames++; //update frame count.
}

- (void) updateObjectsWithCameraT: (metaio::Vector3d)t AndR:(metaio::Rotation)r
{
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// allow rotation in all directions
	return YES;
}

- (void)printDebugToConsole //call on button press
{
//        //prints defined vs. valid (active) COS's
//        printf("/nCOS's: %i of %i", m_metaioSDK->getNumberOfValidCoordinateSystems(), m_metaioSDK->getNumberOfDefinedCoordinateSystems());
//        metaio::TrackingValues cos0 = m_metaioSDK->getTrackingValues(0);
//        metaio::TrackingValues cos1 = m_metaioSDK->getTrackingValues(1);
//        metaio::TrackingValues cos2 = m_metaioSDK->getTrackingValues(2);
//        if (cos0.isTrackingState()) {printf("COS0: is tracking!");}
//        else {printf("COS0: is not tracking!");}
//        if (cos1.isTrackingState()) {printf("COS1: is tracking!");}
//        else {printf("COS1: is not tracking!");}
//        if (cos2.isTrackingState()) {printf("COS2: is tracking!");}
//        else {printf("COS2: is not tracking!");}
//
//        //prints COS's IDs from name
//        int right = m_metaioSDK->getCoordinateSystemID("map-mlab-front-right");
//        int left = m_metaioSDK->getCoordinateSystemID("map-mlab-front-left");
//        printf("\nmap-mlab-front-right: %d\n", right); //1
//        printf("\nmap-mlab-front-left: %d\n", left); //2
//    
//        //put this one in Object instance, prints rotation and translation
//        metaio::Vector3d r = m_rn.getEulerAngleDegrees();
//        metaio::Vector3d t = m_tn;
//        
//        metaio::Vector3d obj_t = m_obj->getTranslation();
//        metaio::Vector3d obj_r = m_obj->getRotation().getEulerAngleDegrees();
//
//        printf("\n---------------------|%d|---------------------\n", m_frames); //NSLOG prints date and time and some junk
//        printf("\n--|rotation: (%f, %f, %f) |---\n--|translation: (%f, %f, %f) |---\n",
//        r.x, r.y, r.z, t.x, t.y, t.z);
//        
//        printf("\n-----|OBJ|--------------------\n");
//        printf("\n--|rotation: (%f, %f, %f) |---\n--|translation: (%f, %f, %f) |---\n",
//        obj_r.x, obj_r.y, obj_r.z, obj_t.x, obj_t.y, obj_t.z);
//        printf("\n---------\n");
//        printf("\n-----\n");
}


- (void) printETSState: (metaio::ETRACKING_STATE)state_ //in the future: trackingValues.trackingStateToString
{
    switch (state_)
    {
        case metaio::ETS_EXTRAPOLATED:
        {
            printf("ETS_EXTRAPOLATED");
            break;
        }
        case metaio::ETS_FOUND:
        {
            printf("ETS_FOUND");
            break;
        }
        case metaio::ETS_INITIALIZATION_FAILED:
        {
            printf("ETS_INITIALIZATION_FAILED");
            break;
        }
        case metaio::ETS_INITIALIZED:
        {
            printf("ETS_INITIALIZZED");
            break;
        }
        case metaio::ETS_LOST:
        {
            printf("ETS_LOST");
            break;
        }
        case metaio::ETS_NOT_TRACKING:
        {
            printf("ETS_NOT_TRACKING");
            break;
        }
        case metaio::ETS_REGISTERED:
        {
            printf("ETS_REGISTERED");
            break;
        }
        case metaio::ETS_TRACKING:
        {
            printf("ETS_TRACKING");
            break;
        }
        case metaio::ETS_UNKNOWN:
        {
            printf("ETS_UNKNOWN");
            break;
        }
        default:
        {
            printf("ETS_???");
            break;
        }
    }

}

#pragma mark - Button handlers


- (void)loadDebugView {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Assets/web/slam" ofType:@"html"] isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)addPose: (int)name ToDebugContextT: (metaio::Vector4d)obj_t andR:(metaio::Rotation)obj_r
{
    JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    metaio::Vector3d obj_e = obj_r.getEulerAngleDegrees();
    /*http://www.bignerdranch.com/blog/objective-c-literals-part-1/*/
    /*simpler to do this by creating a new version of an existing object with params?*/
    ctx[@"poses"][[NSString stringWithFormat:@"%d", name]] =
    @{
        @"t" : @{ @"x" : @(obj_t.x), @"y" : @(obj_t.y), @"z" : @(obj_t.z) },
        @"r" : @{ @"x" : @(obj_e.x), @"y" : @(obj_e.y), @"z" : @(obj_e.z) }
        };
}

- (void)updateDebugViewWithCameraT: (metaio::Vector3d)c_t andR: (metaio::Rotation)c_r
    andObjectT: (metaio::Vector3d)o_t andR: (metaio::Rotation)o_r
{
    JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSAssert([ctx isKindOfClass:[JSContextclass]], @"could not find context in web view");
    JSValue *isReady = ctx[@"isReady"];
    if (!isReady.toBool)
    {
        return;
    }
//    if (!( [ctx[@"poses"] hasProperty:[NSString stringWithFormat:@"%d", 1] ]))
//    {
//        [self addPose:1 ToDebugContextT: o_t andR: o_r];
//    }
    metaio::Vector3d c_e = c_r.getEulerAngleDegrees();
    metaio::Vector3d o_e = o_r.getEulerAngleDegrees();
    
    ctx[@"printToScreen"] = @(printToScreen);
    ctx[@"c"][@"t"][@"x"] = @(((int) c_t.x/10) * 10);
    ctx[@"c"][@"t"][@"y"] = @(((int) c_t.y/10) * 10);
    ctx[@"c"][@"t"][@"z"] = @(((int) c_t.z/10) * 10);
    
    ctx[@"c"][@"r"][@"x"] = @(((int) c_e.x/10) * 10);
    ctx[@"c"][@"r"][@"y"] = @(((int) c_e.y/10) * 10);
    ctx[@"c"][@"r"][@"z"] = @(((int) c_e.z/10) * 10);
    
    ctx[@"o"][@"t"][@"x"] = @(((int) o_t.x/10) * 10);
    ctx[@"o"][@"t"][@"y"] = @(((int) o_t.y/10) * 10);
    ctx[@"o"][@"t"][@"z"] = @(((int) o_t.z/10) * 10);
    
    ctx[@"o"][@"r"][@"x"] = @(((int) o_e.x/10) * 10);
    ctx[@"o"][@"r"][@"y"] = @(((int) o_e.y/10) * 10);
    ctx[@"o"][@"r"][@"z"] = @(((int) o_e.z/10) * 10);
    
    ctx[@"console"][@"log"] = ^(JSValue *msg)
    {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    }; //works for all console.log messages
}

- (void)updateDebugViewWithActiveCos: (int)cos_ AndStatus:(string)state_
{
    JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSAssert([ctx isKindOfClass:[JSContextclass]], @"could not find context in web view");
    JSValue *isReady = ctx[@"isReady"];
    if (!isReady.toBool)
    {
        return;
    }
    ctx[@"COS"][@"idx"] = @(cos_);
    ctx[@"COS"][@"state"] = [NSString stringWithFormat:@"%s", state_.c_str()];
}

-(void)initPoseWithT:(metaio::Vector3d)t_ AndR:(metaio::Rotation)r_
{
}

-(void)initRadar {
//    m_radar = m_metaioSDK->createRadar();
//    m_radar->setBackgroundTexture([[[NSBundle mainBundle] pathForResource:@"radar"	ofType:@"jpg" inDirectory:@"Assets"] UTF8String]);
//    m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"elephant_skin"	ofType:@"jpg" inDirectory:@"Assets"] UTF8String]);
//    m_radar->setRelativeToScreen(metaio::IGeometry::ANCHOR_BR);
//    
//    m_radar->add(m_obj);
}

/***** IF CALLBACKS *****/

- (IBAction)onDebugDown:(id)sender {
    debugView = !debugView;
    [self.webView setHidden:![self.webView isHidden] ];
}

- (IBAction)onPrintDown:(id)sender {
    printToScreen = (!printToScreen) && debugView;
}

- (IBAction)poseButtonDown:(id)sender {
    if (! cam.hasInitPose ) return;
    metaio::Vector3d _t = obj.t;
    switch ([sender tag]) {
        case 1:
            _t.x = (int)(_t.x - 40) % 800;
            break;
        case 2:
            _t.x = (int)(_t.x + 40) % 800;
            break;
        case 3:
            _t.y = (int)(_t.y - 40) % 800;
            break;
        case 4:
            _t.y = (int)(_t.y + 40) % 800;
            break;
        case 5:
            _t.z = (int)(_t.z - 40) % 800;
            break;
        case 6:
            _t.z = (int)(_t.z + 40) % 800;
            break;
       default:
           NSLog(@"???");
            break;
        }
    obj.t = _t;
    
}


@end
