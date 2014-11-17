// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import <metaioSDK/IMetaioSDKIOS.h>

namespace metaio
{
class IMetaioSDKIOS;
class IGeometry;
class ISensorsComponent;
}

@interface MetaioSDKViewController : GLKViewController<MetaioSDKDelegate>
{
	metaio::IMetaioSDKIOS*			m_pMetaioSDK;
	BOOL							m_didResize;

	metaio::ISensorsComponent*		m_pSensorsComponent;
	bool							m_mustUpdateFrameAndRenderBufferIDs;
}

@property (strong, nonatomic) IBOutlet GLKView* glkView;

- (void)drawFrame;

- (BOOL)shouldEnableMultisampleAntialiasing;

@end

