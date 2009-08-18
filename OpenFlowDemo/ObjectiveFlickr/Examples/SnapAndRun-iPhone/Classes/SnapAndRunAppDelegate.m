//
// SnapAndRunAppDelegate.m
//
// Copyright (c) 2009 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "SnapAndRunAppDelegate.h"
#import "SnapAndRunViewController.h"
#import "SampleAPIKey.h"

NSString *SnapAndRunShouldUpdateAuthInfoNotification = @"SnapAndRunShouldUpdateAuthInfoNotification";

// preferably, the auth token is stored in the keychain, but since working with keychain is a pain, we use the simpler default system
NSString *kStoredAuthTokenKeyName = @"FlickrAuthToken";
NSString *kGetAuthTokenStep = @"kGetAuthTokenStep";
NSString *kCheckTokenStep = @"kCheckTokenStep";

@implementation SnapAndRunAppDelegate
- (void)dealloc
{
    [viewController release];
    [window release];
    [flickrContext release];
	[flickrRequest release];
	[flickrUserName release];
    [super dealloc];
}

- (OFFlickrAPIRequest *)flickrRequest
{
	if (!flickrRequest) {
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
		flickrRequest.delegate = self;		
	}
	
	return flickrRequest;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// query has the form of "&frob=", the rest is the frob
	NSString *frob = [[url query] substringFromIndex:6];

	[self flickrRequest].sessionInfo = kGetAuthTokenStep;
	[flickrRequest callAPIMethodWithGET:@"flickr.auth.getToken" arguments:[NSDictionary dictionaryWithObjectsAndKeys:frob, @"frob", nil]];
	
	[activityIndicator startAnimating];
	[viewController.view addSubview:progressView];
	
    return YES;
}

- (void)_applicationDidFinishLaunchingContinued
{
	if ([self flickrRequest].sessionInfo) {
		// is getting auth token
		return;
	}
	
	if ([self.flickrContext.authToken length]) {
		[self flickrRequest].sessionInfo = kCheckTokenStep;
		[flickrRequest callAPIMethodWithGET:@"flickr.auth.checkToken" arguments:nil];

		[activityIndicator startAnimating];
		[viewController.view addSubview:progressView];
	}
}
        
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	// Apple trick: Do this so after we got a chance to let application:handleOpenURL: run before our next stage of init...
	[self performSelector:@selector(_applicationDidFinishLaunchingContinued) withObject:nil afterDelay:0.0];
}

+ (SnapAndRunAppDelegate *)sharedDelegate
{
    return (SnapAndRunAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)cancelAction
{
	[flickrRequest cancel];	
	[activityIndicator stopAnimating];
	[progressView removeFromSuperview];
	[self setAndStoreFlickrAuthToken:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
}

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken
{
	if (![inAuthToken length]) {
		self.flickrContext.authToken = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenKeyName];
	}
	else {
		self.flickrContext.authToken = inAuthToken;
		[[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kStoredAuthTokenKeyName];
	}
}

- (OFFlickrAPIContext *)flickrContext
{
    if (!flickrContext) {
        flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
        
        NSString *authToken;
        if (authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName]) {
            flickrContext.authToken = authToken;
        }
    }
    
    return flickrContext;
}

#pragma mark OFFlickrAPIRequest delegate methods
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	if (inRequest.sessionInfo == kGetAuthTokenStep) {
		[self setAndStoreFlickrAuthToken:[[inResponseDictionary valueForKeyPath:@"auth.token"] textContent]];
		self.flickrUserName = [inResponseDictionary valueForKeyPath:@"auth.user.username"];
	}
	else if (inRequest.sessionInfo == kCheckTokenStep) {
		self.flickrUserName = [inResponseDictionary valueForKeyPath:@"auth.user.username"];
	}
	
	[activityIndicator stopAnimating];
	[progressView removeFromSuperview];
	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	if (inRequest.sessionInfo == kGetAuthTokenStep) {
	}
	else if (inRequest.sessionInfo == kCheckTokenStep) {
		[self setAndStoreFlickrAuthToken:nil];
	}
	
	[activityIndicator stopAnimating];
	[progressView removeFromSuperview];

	[[[[UIAlertView alloc] initWithTitle:@"API Failed" message:[inError description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
	[[NSNotificationCenter defaultCenter] postNotificationName:SnapAndRunShouldUpdateAuthInfoNotification object:self];
}

@synthesize viewController;
@synthesize window;
@synthesize flickrContext;
@synthesize flickrUserName;

@synthesize activityIndicator;
@synthesize progressView;
@synthesize cancelButton;
@synthesize progressDescription;
@end
