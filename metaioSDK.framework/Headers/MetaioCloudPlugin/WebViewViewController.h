//
//  WebViewViewController.h
//  Junaio
//
//  Created by Stefan Misslinger on 10/5/09.
//  Copyright 2009 metaio, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaioViewControllerClosingCallback.h"

typedef void (^WebViewViewControllerCallbackBlock)(void);

@interface WebViewViewController : UIViewController<MetaioViewControllerClosingCallback,UIWebViewDelegate, UIPopoverControllerDelegate> {

    UIWebView*                          webView;
    UIActivityIndicatorView *           activityIndicator;
}
@property (nonatomic, copy) MetaioActionBlock                       viewDidDisappearAction;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *    activityIndicator;
@property (nonatomic, retain) IBOutlet UIWebView*                   webView;
@property (nonatomic, retain) NSURL*                                url;


- (IBAction) buttonClose;
- (IBAction) buttonSharePushed:(UIBarButtonItem*)sender;

-(id) initializeWithURL: (NSString*) url;

@end
