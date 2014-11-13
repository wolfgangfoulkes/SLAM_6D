// Copyright 2007-2013 metaio GmbH. All rights reserved.
#ifndef ___AS_IMETAIOSDKIOS_H_INCLUDED___
#define ___AS_IMETAIOSDKIOS_H_INCLUDED___


#include "IMetaioSDK.h"
#include "DeviceInfoIOS.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


@class AVCaptureVideoPreviewLayer;
@class IGeometry;
@class NSString;
@class NSObject;

/** Set to of functions to handle metaio SDK callbacks
*/
@protocol MetaioSDKDelegate

@optional

/**
 * This is triggered as soon as the SDK is ready, e.g. splash screen is finished.
 */
- (void) onSDKReady;

/**
 * This is called everytime SDK encounters an error.
 * See ErrorCodes.h for a list of error codes.
 *
 * @param errorCode A code representing type of the error (see ErrorCodes.h)
 * @param errorDescription Description of the error
 */
- (void) onError: (const int) errorCode description:(const NSString*) errorDescription;

/**
 * This is called everytime SDK encounters a warning.
 * See WarningCodes.h for a list of warning codes.
 *
 * @param warningCode Code A code representing type of the warning (see WarningCodes.h)
 * @param warningDescription Description of the warning
 */
- (void) onWarning: (const int) warningCode description:(const NSString*) warningDescription;

/** This function will be triggered, when an animation has ended
 * \param geometry the geometry which has finished animating
 * \param animationName the name of the just finished animation
 * \return void
 */
- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName;


/**
 * \brief This function will be triggered, if a movietexture-playback has ended
 * \param geometry the geometry which has finished animating/movie-playback
 * \param movieName the filename of the movie
 * \return void
 */
- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName;

/**
 * \brief Request a callback that delivers the next camera image.
 *
 * The image will have the  dimensions of the current capture resolution.
 * To request this callback, call requestCameraFrame()
 *
 * \param cameraFrame the latest camera image
 * 
 * \note you must copy the ImageStuct::buffer, if you need it for later. 
 */
- (void) onNewCameraFrame: ( metaio::ImageStruct*)  cameraFrame;

/**
 * \brief Callback that notifies that camera image has been saved
 *
 * To request this callback, call requestCameraFrame(filepath, width, height)
 *
 * \param filepath File path in which image is written, or empty string in case of a failure
 * 
 */
- (void) onCameraImageSaved: (NSString*) filepath; 

/**
 * Callback for changes in rendering, e.g. if geometry became visible
 *
 * \param renderEvent Describes the render event (i.e. geometry became visible)
 */
- (void) onRenderEvent:(const metaio::RenderEvent&)renderEvent;

/**
 * Callback that delivers screenshot as new ImageStruct.
 * The image struct buffer will be released after this call returns.
 * Note: This callback is called on the render thread.
 *
 * \param image Screenshot image
 */
-(void) onScreenshotImage:(metaio::ImageStruct*) image;

/**
 * Callback that delivers screenshot as new UIImage.
 * Note: This callback is called on the render thread.
 *
 * \param image Screenshot image
 */
-(void) onScreenshotImageIOS:(UIImage*) image;

/**
 * Callback that notifies that screenshot has been saved to a file.
 * If the screenshot is not written to a file, the filepath will be
 * an empty string.
 * Note: This callback is called on the render thread.
 *
 * \param filepath File path where screenshot image has been written
 */
-(void) onScreenshotSaved:(NSString*) filepath;

/**
 * \brief Callback that informs new pose states (tracked, detected or lost)
 *
 * This is called automatically as soon as poses have been updated. The vector
 * contains all the valid poses. 
 * The invalid pose is only returned for first frame as soon as target is lost 
 * to inform this event.
 * Note that this function is called in rendering thread, thus it would block
 * rendering. It should be returned as soon as possible wihout any expensive 
 * processing.
 * 
 * \param poses current valid poses
 * 
 */
- (void) onTrackingEvent: (const metaio::stlcompat::Vector<metaio::TrackingValues>&) poses;

/**
 * \brief Callback that informs about instant 3D tracking event
 *
 * \param success result of the instant tracking event
 * \param file saved tracking configuration path
 *
 */
- (void) onInstantTrackingEvent:(bool)success file:(NSString*) file;

/**
 * \brief This method is always called after you successfully started a new visual search
 * (with IUnifeyeMobile::performVisualSearch()) and received the result from the server.
 *
 * \param response All found results. If response.size() > 0 the search has found something.
 * \param errorCode if > 0, then an error has occured.
 *
 */
- (void) onVisualSearchResult:(const metaio::stlcompat::Vector<metaio::VisualSearchResponse>&) response
					errorCode:(int) errorCode;

/**
 * This method is called whenever the state of the visual search engine changes
 * \param state the new state
 */
- (void) onVisualSearchStatusChanged: (metaio::EVISUAL_SEARCH_STATE) state;

@end


namespace metaio
{

	/** 
	 * \brief Specialized interface for iPhone.
	 * 
	 */
	class IMetaioSDKIOS : public virtual IMetaioSDK
	{
	public:
		
        virtual ~IMetaioSDKIOS() {};
        
        /** \brief Register the delegate object that will receive callbacks
         * \param delegate the object
         * \return void
         */
        virtual void registerDelegate( NSObject<MetaioSDKDelegate>* delegate ) = 0;
        
        /**
		 * \brief Get a camera preview layer from the active camera session
		 *
		 * Use this to get a pointer to a AVCaptureVideoPreviewLayer that 
		 * is created based on the current camera session. You can use this 
		 * to draw the camera image in the background and add a transparent
		 * EAGLView on top of this. To prevent metaioSDK from drawing the
		 * background in OpenGL you can activate the see-through mode.
		 *
		 * \code 	
		 *			[glView setBackgroundColor:[UIColor clearColor]];
		 *			m_metaioSDK->setSeeThrough(true);
		 *
		 *			AVCaptureVideoPreviewLayer* previewLayer = 
		 *					glView.m_metaioSDK->getCameraPreviewLayer();
		 *			previewLayer.frame = myUIView.bounds;
		 *			[myUIView.layer addSublayer:previewLayer];
		 * \endcode
		 *
		 * \sa Set metaioSDK to see through mode using setSeeThrough ( 1 )
		 * \sa Start capturing using activateCamera ( index )
		 * \sa You can deactivate the capturing again with stopCamera()
		 *
		 * \note Only available on iOS >= 4.0. If you call this on 3.x nothing will happen.
		 * \note Not available on iPhone Simulator.
         * \return the pointer to the instance of the class AVCaptureVideoPreviewLayer
		 */
		virtual AVCaptureVideoPreviewLayer* getCameraPreviewLayer() = 0;    
        
        /**
         * @brief Specialized function for iPhone
         *
         * @param textureName name that should be assigned to the texture 
         *	(for reuse).
         * @param image CGImage reference to set
		 * @param displayAsBillboard true if the plane should be rendered as a billboard (always facing camera)
		 * @param autoScale true if the plane size should be assigned a height of 100, and width of
		 *        100*{image width}/{image height}. false if the size should be the image width and height
		 *        (e.g. 640 by 480 units for a 640x480 image)
         * @return pointer to geometry
         */
        virtual IGeometry* createGeometryFromCGImage(const stlcompat::String& textureName, CGImageRef image,
			const bool displayAsBillboard = false,
			const bool autoScale = true) = 0;
        
        /**
         * @brief Helper function to convert an ImageStruct image to UIImage
         *
         * @param imgStruct Source image to be converted
         * @param rotate Specify if the converted image should be rotated according to screen rotation
         * @return pointer to UIImage
         */
        virtual UIImage* ImageStruct2UIImage( metaio::ImageStruct* imgStruct, bool rotate ) = 0;
	
    };

    /** Provides access to raw image data of a CGImage.
     * This is e.g. needed when setting an MD2 texture from memory.
	 *
     * \code
     * ImageStruct imageContent;
     * CGContextRef context = nil;
	 * CGColorSpaceRef colorSpace = nil;
     * 
     * beginGetDataForCGImage(image, &imageContent, &context, &colorSpace);
     * 
     *  // use data
     *  // ....
     * endGetData(&context, &colorSpace);
     *
     * \endcode
     *
     * \param image the source image
     * \param[out] imageContent after the call this will point to a struct containing the image content
     * \param[out] context after the call this will point to the created CGContext. This has to be deleted again by calling endGetData
	 * \param[out] rgbColorSpace after the call this will point to the created ColorSpace. This has to be deleted again by calling endGetData
     * 
     * \sa endGetData to delegate the context again
     */
     void beginGetDataForCGImage(CGImage* image, ImageStruct* imageContent, CGContextRef* context, CGColorSpaceRef* rgbColorSpace);
    
    
    /** Frees the image context that was created with beginGetDataForCGImage
     * \param context the context to free
	 * \param rgbColorSpace the colorspace to free
     * 
     * \sa beginGetDataForCGImage to get data from a CGImage
     */
    void endGetData(CGContextRef* context, CGColorSpaceRef* rgbColorSpace);


	/**
	* \brief Create an ARMobileSystem instance
	*
	* \param signature The signature of the application identifier
	* \return a pointer to an ARMobileSystem instance
	*/
	IMetaioSDKIOS* CreateMetaioSDKIOS(const stlcompat::String& signature);
	
	
	/** Convert a UIInterface orientation to a ESCREEN_ROTATION to use with the SDK
	 * \param interfaceOrientation item
	 * \return the corresponding ESCREEN_ROTATION
	 */
	ESCREEN_ROTATION getScreenRotationForInterfaceOrientation(NSInteger interfaceOrientation);

	
} //namespace metaio


#endif //___AS_IMETAIOSDKIOS_H_INCLUDED___
