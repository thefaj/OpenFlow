//
//  TestSuite.m
//  SynchronousRequestTest
//
//  Created by Lukhnos D. Liu on 6/12/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "TestSuite.h"


@implementation TestSuite
- (void)setUp
{
	HTTPRequest = [[LFHTTPRequest alloc] init];
	HTTPRequest.delegate = self;
	HTTPRequest.shouldWaitUntilDone = YES;
}

- (void)tearDown
{
	[HTTPRequest release];
	HTTPRequest = nil;
}

- (void)testFetchData
{
	[HTTPRequest performMethod:LFHTTPRequestGETMethod onURL:[NSURL URLWithString:@"http://google.com"] withData:nil];
	NSLog(@"received data: %s", [[HTTPRequest receivedData] bytes]);
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, [request receivedData]);
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
	NSLog(@"%@ %@", __PRETTY_FUNCTION__, error);
}

@end
