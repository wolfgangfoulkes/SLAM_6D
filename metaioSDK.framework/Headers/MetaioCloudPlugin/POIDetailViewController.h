//
//  POIDetailViewController.h
//  Junaio
//
//  Created by Stefan Misslinger
//  Copyright 2013 metaio. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace metaio {
 class IARELObject;   // fwd decl.
}

@protocol POIDetailViewControllerDelegate
- (void) contextViewButtonClosePushed;
- (void) onHandleURL:(NSString*) url;
@end

@class RatingView;

@interface POIDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic, assign ) IBOutlet NSObject<POIDetailViewControllerDelegate>* delegate;

@property( nonatomic, retain)  IBOutlet	UILabel*           lblTitle;
@property( nonatomic, retain)  IBOutlet	UILabel*           lblSubitle;

@property( nonatomic, retain)  IBOutlet	UIView*            contentView;

@property (nonatomic, retain) IBOutlet UIButton*           btnClose;
@property (retain, nonatomic) IBOutlet UITableView *       tableView;


@property( nonatomic, retain) IBOutlet UIImageView*		imageView;
@property (retain, nonatomic) IBOutlet RatingView *     imgRating;
@property (retain, nonatomic) IBOutlet UIImageView *     imgAttribution;


- (IBAction) buttonClosePressed;

- (void) setPOI:(const metaio::IARELObject*) poi;
- (void) closeIfContainsPOI: (const metaio::IARELObject*) poi;
+ (UIColor*)defaultSystemTintColor;


@end
