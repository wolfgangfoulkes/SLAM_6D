// metaio SDK
//
// Copyright 2007-2014 metaio GmbH. All rights reserved.
//

#import "InstantTrackingViewController.h"
#import "EAGLView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "MapTransitionHelper.h"

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
    
    //Initialize camera r and t
    m_tn = metaio::Vector3d(metaio::Vector3d(0,0,0));
    m_rn = metaio::Rotation(metaio::Vector3d(0,0,0));
    
    //relative to camera-init. 304.8 is 6', assumes I've got it just-under-head
    m_obj_p = metaio::Vector3d(0, 0, 0); //-300);
    //will need to convert r for rotating geometry, which rotates relative to camera COS
    m_obj_r = metaio::Rotation(metaio::Vector3d(0, 0, 0));
    
    
    //Initialize frame count
    m_frames = 0;
    
    // Load content
    m_obj           = [self createModel:@"head" ofType:@"obj" inDirectory:@"Assets/obj" renderOrder:0  modelTranslation:m_obj_p modelScaling:m_scale];
    
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
		return;
    
    // If tracking initialization failed or tracking is lost
	if (poses[0].state == metaio::ETS_INITIALIZATION_FAILED || poses[0].state == metaio::ETS_LOST)
	{
		// Force immediate reset of tracking
		NSLog(@"SLAM initialization cannot continue, resetting tracking...");
		mapTransitionHelper.prepareForTransitionToNewMap();
		[self setTrackingConfiguration];
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
    NSString* config = [NSString stringWithFormat:@"Tracking"];
	NSString* dir = [NSString stringWithFormat:@"Assets"];
    NSString* ext = [NSString stringWithFormat:@"xml"];
	NSString* tr = [[NSBundle mainBundle] pathForResource:config ofType:ext inDirectory:dir];
    NSLog(@"full path: %s", [tr UTF8String]);
	
    bool success = m_metaioSDK->setTrackingConfiguration([tr UTF8String]);
    if(!success)
    {
        NSLog(@"No success loading the tracking configuration");
    }
    else
    {
        NSLog(@"Success loading the tracking configuration");
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
- (metaio::IGeometry*) createModel:(NSString*)resource ofType:(NSString*)type inDirectory:(NSString*)directory renderOrder:(NSInteger)renderOrder modelTranslation:(metaio::Vector3d)translation modelScaling:(NSInteger)scale
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
            geometry->setCoordinateSystemID(1);
            
		}
		else
		{
			NSLog(@"error, could not load %@", modelPath);
		}
	}
    
    return geometry;
}

/**
 * Update the scale, rotation and translation of the models
 */
- (void) update
{
    // Update the internal state with the lastest tracking values from the SDK.
    mapTransitionHelper.update(m_metaioSDK->getTrackingValues(1), m_metaioSDK->getRegisteredSensorsComponent()->getLastSensorValues());

    
    // If the last frame could be tracked successfully
    if(mapTransitionHelper.lastFrameWasTracked())
    {
        // Get the rotation of the "fused" camera pose
        metaio::Rotation newRotation = mapTransitionHelper.getRotationCameraFromWorld();
        //camera COS
        
        // Get the translation of the "fused" camera pose
        metaio::Vector3d newTranslation = mapTransitionHelper.getTranslationCameraFromWorld();
        //camera COS
        
        if(!hasInitPose)
        {
            [self initPoseWithT:newTranslation AndR: newRotation];
            printf("init: t = (%f, %f, %f) r = (%f, %f, %f)", m_ti.x, m_ti.y, m_ti.z, m_ri.getEulerAngleDegrees().x, m_ri.getEulerAngleDegrees().y, m_ri.getEulerAngleDegrees().z);
            
            m_rn = metaio::Rotation(m_ri);
            m_tn = metaio::Vector3d(m_ti);
        }
        else
        {
            m_tn = newTranslation - m_ti;
            m_rn = metaio::Rotation(newRotation.getEulerAngleDegrees() - m_ri.getEulerAngleDegrees());
        }
        
        printf("/nCOS's: %i of %i", m_metaioSDK->getNumberOfValidCoordinateSystems(), m_metaioSDK->getNumberOfDefinedCoordinateSystems());
        metaio::TrackingValues cos0 = m_metaioSDK->getTrackingValues(0);
        metaio::TrackingValues cos1 = m_metaioSDK->getTrackingValues(1);
        metaio::TrackingValues cos2 = m_metaioSDK->getTrackingValues(2);
        if (cos0.isTrackingState()) {printf("COS0: is tracking!");}
        else {printf("COS0: is not tracking!");}
        if (cos1.isTrackingState()) {printf("COS1: is tracking!");}
        else {printf("COS1: is not tracking!");}
        if (cos2.isTrackingState()) {printf("COS2: is tracking!");}
        else {printf("COS2: is not tracking!");}
        

        
        //set global vars
        
        
        m_obj->setScale(m_scale);
        
        // Apply the new rotation
        //m_obj->setRotation(newRotation.inverse()); //* metaio::Rotation(metaio::Vector3d(0, M_PI, 0)));
        //rotation done relative to camera. dunno how we'd do it with rotating object, but that's what GL is for!
        
        // Apply the new translation
        //m_obj->setTranslation(metaio::Vector3d(-m_tn.x, -m_tn.y, newTranslation.z));
        
    }
    
    int frame_rate = m_metaioSDK->getTrackingFrameRate(); //returns float average of last many frames. not rendering fr
    
    if ((m_frames % frame_rate) == 0 && hasInitPose) //replace this with button press!
    {
        
        metaio::Vector3d r = m_rn.getEulerAngleDegrees();
        metaio::Vector3d t = m_tn;
        
        metaio::Vector3d obj_t = m_obj->getTranslation();
        metaio::Vector3d obj_r = m_obj->getRotation().getEulerAngleDegrees();
        
        
        printf("\n---------------------|%d|---------------------\n", m_frames); //NSLOG prints date and time and some junk
        printf("\n--|rotation: (%f, %f, %f) |---\n--|translation: (%f, %f, %f) |---\n",
        r.x, r.y, r.z, t.x, t.y, t.z);
        
        printf("\n-----|OBJ|--------------------\n");
        printf("\n--|rotation: (%f, %f, %f) |---\n--|translation: (%f, %f, %f) |---\n",
        obj_r.x, obj_r.y, obj_r.z, obj_t.x, obj_t.y, obj_t.z);
        printf("\n---------\n");
        printf("\n-----\n");
        
        [self updateDebugView:m_tn object:obj_t];
        
    }
    m_frames++; //update frame count.
}



#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// allow rotation in all directions
	return YES;
}



#pragma mark - Button handlers

/**
 * Reset the tracking
 */
- (IBAction)onResetTrackingBtnPress:(id)sender
{
    // Force immediate reset of tracking
    NSLog(@"Resetting tracking...");
    mapTransitionHelper.prepareForTransitionToNewMap();
    mapTransitionHelper.reset();
    [self setTrackingConfiguration];
}

/**
 * Hide or show the earth model
 */
- (IBAction)onChangeModelVisibilityBtnPress:(id)sender
{
    // Change the model transparency
    NSInteger transparency = (m_obj->getTransparency() == 1) ? 0 : 1;
    
    m_obj->setTransparency(transparency);
    
    // Change button name to show or hide the earth model
    if(m_obj->getTransparency() == 0)
        [_changeModelVisibilityBtn setTitle:@"Hide" forState:UIControlStateNormal];
    else
        [_changeModelVisibilityBtn setTitle:@"Show" forState:UIControlStateNormal];
}

- (void)loadDebugView {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Assets/web/slam" ofType:@"html"] isDirectory:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

-(void)updateDebugView: (metaio::Vector3d)tc  object: (metaio::Vector3d)to {
    JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSAssert([ctx isKindOfClass:[JSContextclass]], @"could not find context in web view");
    JSValue *isReady = ctx[@"isReady"];
    if (!isReady.toBool)
    {
        return;
    }
    ctx[@"cx"] = @(50. + tc.x/100.); //shorthand for NSNumber
    ctx[@"cy"] = @(50. + tc.y/100.);
    ctx[@"ox"] = @(50. + to.x/100.);
    ctx[@"oy"] = @(50. + to.y/100.);
    
    ctx[@"console"][@"log"] = ^(JSValue *msg)
    {
        //NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    }; //works for all console.log messages
    
    //[ctx evaluateScript:@"console.log('this is a log message that goes to my Xcode debug console :)')"];
    
}

-(void)initPoseWithT:(metaio::Vector3d)t_ AndR:(metaio::Rotation)r_
{
    m_ti = metaio::Vector3d(t_);
    m_ri = metaio::Rotation(r_);
    
    hasInitPose = true;
}

@end
