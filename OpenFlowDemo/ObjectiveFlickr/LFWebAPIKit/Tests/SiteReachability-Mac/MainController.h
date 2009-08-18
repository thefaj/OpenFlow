//
//  MainController.h
//  SiteReachability
//
//  Created by Lukhnos D. Liu on 7/1/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LFWebAPIKit.h"

@interface MainController : NSWindowController <LFSiteReachabilityDelegate>
{
	LFSiteReachability *reachability;

	NSButton *startButton;
	NSTextField *statusLabel;
}
- (IBAction)startCheckingAction:(id)sender;

@property (retain, nonatomic) IBOutlet NSButton *startButton;
@property (retain, nonatomic) IBOutlet NSTextField *statusLabel;

@end
