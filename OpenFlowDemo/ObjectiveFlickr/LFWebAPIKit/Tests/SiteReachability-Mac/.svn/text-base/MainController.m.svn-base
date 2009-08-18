//
//  MainController.m
//  SiteReachability
//
//  Created by Lukhnos D. Liu on 7/1/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "MainController.h"


@implementation MainController
- (void)dealloc
{
	self.startButton = nil;
	self.statusLabel = nil;
    [super dealloc];
}

- (void)updateNotCheckingStatusLabel
{
	[statusLabel setStringValue:[NSString stringWithFormat:@"Not checking, connectivity: %@", ([reachability networkConnectivityExists] ? @"exists" : @"not exists")]];
}

- (void)awakeFromNib
{
	if (!reachability) {
		reachability = [[LFSiteReachability alloc] init];
		reachability.delegate = self;
	}

	[startButton setTitle:([reachability isChecking] ? @"Stop Checking" : @"Start Checking")];
	[self updateNotCheckingStatusLabel];
}

- (IBAction)startCheckingAction:(id)sender
{
	if ([reachability isChecking]) {
		[reachability stopChecking];
		[startButton setTitle:@"Start Checking"];
		[self updateNotCheckingStatusLabel];
	}
	else {
		[statusLabel setStringValue:@"Checking"];
		[reachability startChecking];
		[startButton setTitle:@"Stop Checking"];
	}
}

- (void)reachability:(LFSiteReachability *)inReachability site:(NSURL *)inURL isAvailableOverConnectionType:(NSString *)inConnectionType
{
	[statusLabel setStringValue:[NSString stringWithFormat:@"Reachable, type: %@", ((inConnectionType == LFSiteReachabilityConnectionTypeWiFi) ? @"WiFi" : @"WWAN")]];
}

- (void)reachability:(LFSiteReachability *)inReachability siteIsNotAvailable:(NSURL *)inURL
{
	[statusLabel setStringValue:@"Not reachable"];
}

@synthesize statusLabel;
@synthesize startButton;
@end
