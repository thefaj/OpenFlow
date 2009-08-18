//
//  SiteReachabilityViewController.m
//  SiteReachability
//
//  Created by Lukhnos D. Liu on 6/30/09.
//  Copyright Lithoglyph Inc. 2009. All rights reserved.
//

#import "SiteReachabilityViewController.h"

@implementation SiteReachabilityViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (!reachability) {
		reachability = [[LFSiteReachability alloc] init];
		reachability.delegate = self;
	}
}


- (void)viewDidUnload
{
	self.startButton = nil;
	self.statusLabel = nil;
}

- (void)updateNotCheckingStatusLabel
{
	statusLabel.text = [NSString stringWithFormat:@"Not checking, connectivity: %@", ([reachability networkConnectivityExists] ? @"exists" : @"not exists")];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[startButton setTitle:([reachability isChecking] ? @"Stop Checking" : @"Start Checking") forState:UIControlStateNormal];	
	[self updateNotCheckingStatusLabel];
}

- (void)dealloc
{
	self.startButton = nil;
	self.statusLabel = nil;
    [super dealloc];
}

- (IBAction)startCheckingAction:(id)sender
{
	if ([reachability isChecking]) {
		[reachability stopChecking];
		[startButton setTitle:@"Start Checking" forState:UIControlStateNormal];
		[self updateNotCheckingStatusLabel];
	}
	else {
		statusLabel.text = @"Checking";
		[reachability startChecking];
		[startButton setTitle:@"Stop Checking" forState:UIControlStateNormal];
	}
}

- (void)reachability:(LFSiteReachability *)inReachability site:(NSURL *)inURL isAvailableOverConnectionType:(NSString *)inConnectionType
{
	NSLog(@"%s, connection type: ", __PRETTY_FUNCTION__, inConnectionType);
	statusLabel.text = [NSString stringWithFormat:@"Reachable, type: %@", ((inConnectionType == LFSiteReachabilityConnectionTypeWiFi) ? @"WiFi" : @"WWAN")];
}

- (void)reachability:(LFSiteReachability *)inReachability siteIsNotAvailable:(NSURL *)inURL
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	statusLabel.text = @"Not reachable";
}

@synthesize statusLabel;
@synthesize startButton;
@end
