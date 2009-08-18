//
//  SiteReachabilityViewController.h
//  SiteReachability
//
//  Created by Lukhnos D. Liu on 6/30/09.
//  Copyright Lithoglyph Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFWebAPIKit.h"

@interface SiteReachabilityViewController : UIViewController <LFSiteReachabilityDelegate>
{
	LFSiteReachability *reachability;
	
	UIButton *startButton;
	UILabel *statusLabel;
}
- (IBAction)startCheckingAction:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@end

