// Copyright 2007-2014 metaio GmbH. All rights reserved.
// This file is part of Metaio SDK 6.0 beta
#ifndef _AS_IARELINTERPRETERIOS_
#define _AS_IARELINTERPRETERIOS_

#include "IARELInterpreter.h"
#include <Foundation/Foundation.h>

namespace metaio {
    class IARELObject;  // fwd decl.
}

// forward declaration
@class UIWebView;
@class UIViewController;
@class UIImage;
@class NSURL;

/** Delegate to handle AREL callbacks
 */
@protocol IARELInterpreterIOSDelegate <NSObject>

@optional
/** The implementation should play a video from a given URL
 * \param videoAsset the url to the video
 * \return true, if successful
 */
-(bool) playVideo:(NSURL*)videoAsset;

/**
 * \param url the url to the website
 * \param openInExternalApp true to open in external app, false otherwise
 * \return true, if successful
 */
-(bool) openWebsiteWithUrl:(NSString*) url inExternalApp:(bool) openInExternalApp;

/**
 * This is triggered as soon as the SDK is ready, e.g. splash screen is finished.
 */
-(void) onSDKReady;

/**
 * Called after scene options were loaded from AREL XML file (always called even if there are no
 * scene options)
 * \param sceneOptions vector of sceneoptions
 */
-(void) onSceneOptionsParsed:(metaio::stlcompat::Vector<metaio::ARELSceneOption>&) sceneOptions;

/**
* This is triggered as soon as the AREL is ready, including the loading of XML geometries. 
*/
-(void) onSceneReady;


/**
 * This method is called when an AREL developer wants to open the sharing screen
 * \param	image						JPEG image
 * \param	saveToGalleryWithoutDialog	If true, the application will only save it to the
 *										gallery without displaying the sharing dialog
 * \return True if handled by the callback, false to use the default implementation
 */
- (bool) shareScreenshot:(UIImage*) image options:(bool) saveToGalleryWithoutDialog;


/** Open the detail screen for a POi
 * \param poi the poi
 */
- (void) openPOIDetail:  (const metaio::IARELObject*) poi;


/** Tell the app to display or hide the progressbar and provide progress updates
 * \param displayProgressBar true if the progressbar should be shown
 * \param progress the progress for the progress bar from 0.0 to 1.0
 */
- (void) showProgressBar:(bool) displayProgressBar
                progress:(float) progress;

@end

namespace metaio
{
    /** Specialized class for iOS to register delegates
     */
    class IARELInterpreterIOS : public virtual IARELInterpreter
    {
    public:
        
        /** \brief Destructor
         */
        virtual ~IARELInterpreterIOS() {};
        
        /** \brief Register the delegate object that will receive callbacks
         * \param delegate the object
         * \return void
         */
        virtual void registerDelegate( NSObject<IARELInterpreterIOSDelegate>* delegate ) = 0;
    };
    
/**
* Create a IARELInterpreter for IOS.
*
*	This functions should be only called on iOS platforms
*
* \param webView provide a UIWebView whre AREL is attached to
* \return IARELInterpreter an pointer to the created IARELInterpreter
*/
IARELInterpreterIOS* CreateARELInterpreterIOS(UIWebView* webView, UIViewController* viewController);
}

#endif
