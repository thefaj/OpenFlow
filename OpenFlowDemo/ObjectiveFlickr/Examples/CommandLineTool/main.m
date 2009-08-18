//
// main.m
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

#import "ObjectiveFlickr.h"
#import "SampleAPIKey.h"

BOOL RunLoopShouldContinue = YES;

@interface SimpleDelegate : NSObject <OFFlickrAPIRequestDelegate>
@end

@implementation SimpleDelegate
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, inResponseDictionary);

	NSArray *photos = [inResponseDictionary valueForKeyPath:@"photos.photo"];
	for (NSDictionary *photo in photos) {
		NSLog(@"%@", [inRequest.context photoSourceURLFromDictionary:photo size:OFFlickrMediumSize]);
	}
	
	RunLoopShouldContinue = NO;
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)error
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
		
	RunLoopShouldContinue = NO;
}
@end


int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (argc < 2) {
		fprintf(stderr, "usage: flickr-list-public-photos <Flickr user NSID>\n");
		return 1;
	}
	
	NSString *userID = [NSString stringWithUTF8String:argv[1]];
	
	SimpleDelegate *delegate = [[SimpleDelegate alloc] init];
	OFFlickrAPIContext *context = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
	OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];

	[request setDelegate:delegate];
	BOOL callResult = [request callAPIMethodWithGET:@"flickr.people.getPublicPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:userID, @"user_id", @"50", @"per_page", nil]];
					
	while (RunLoopShouldContinue) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	
	[request release];
	[context release];
	[delegate release];
								   	
	[pool drain];
	return 0;
}
