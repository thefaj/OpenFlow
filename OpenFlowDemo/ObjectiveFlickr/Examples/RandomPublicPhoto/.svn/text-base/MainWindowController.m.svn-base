//
// MainWindowController.m
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

#import "MainWindowController.h"
#import "SampleAPIKey.h"

@implementation MainWindowController
- (void)dealloc
{
	[flickrContext release];
	[flickrRequest release];
	[super dealloc];
}

- (void)awakeFromNib
{
	flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
	flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickrContext];
	[flickrRequest setDelegate:self];
	[self nextRandomPhotoAction:self];
	
	[[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(nextRandomPhotoAction:) userInfo:nil repeats:YES] fire];
	
	[webView setDrawsBackground:NO];
	
	[[self window] center];
}

- (IBAction)nextRandomPhotoAction:(id)sender
{
	if (![flickrRequest isRunning]) {
		[flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0];
	
	NSString *title = [photoDict objectForKey:@"title"];
	if (![title length]) {
		title = @"No title";
	}
	
	NSURL *photoSourcePage = [flickrContext photoWebPageURLFromDictionary:photoDict];
	NSDictionary *linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:photoSourcePage, NSLinkAttributeName, nil];
	NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:title attributes:linkAttr] autorelease];	
	[[textView textStorage] setAttributedString:attrString];

	NSURL *photoURL = [flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrSmallSize];
	NSString *htmlSource = [NSString stringWithFormat:
							@"<html>"
							@"<head>"
							@"  <style>body { margin: 0; padding: 0; } </style>"
							@"</head>"
							@"<body>"
							@"  <table border=\"0\" align=\"center\" valign=\"center\" cellspacing=\"0\" cellpadding=\"0\" height=\"240\">"
							@"    <tr><td><img src=\"%@\" /></td></tr>"
							@"  </table>"
							@"</body>"
							@"</html>"
							, photoURL];
	
	[[webView mainFrame] loadHTMLString:htmlSource baseURL:nil];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
}
@end
