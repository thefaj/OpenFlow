/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AFOpenFlowViewController.h"
#import "UIImageExtras.h"
#import "AFGetImageOperation.h"


@implementation AFOpenFlowViewController

#error Change theses values to your Flickr API key & secret
#define flickrAPIKey @"MYAPIKEY"
#define flickrAPISecret @"MYAPISECRET"

- (void)dealloc {
	[loadImagesOperationQueue release];
	[interestingPhotosDictionary release];
	[flickrContext release];
	[interestingnessRequest release];
	
    [super dealloc];
}

- (void)awakeFromNib {
	loadImagesOperationQueue = [[NSOperationQueue alloc] init];
	UIAlertView *openFlowImageSourceAlertView = [[UIAlertView alloc] initWithTitle:@"OpenFlow Demo Data Source" 
																		   message:@"Would you like to download images from Flickr or use 30 sample images included with this project?" 
																		  delegate:self 
																 cancelButtonTitle:@"Flickr" 
																 otherButtonTitles:@"Samples (all at once)", @"Samples (NSThread)", nil];
	[openFlowImageSourceAlertView show];
	[openFlowImageSourceAlertView release];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	// Hold onto the response dictionary.
	interestingPhotosDictionary = [inResponseDictionary retain];
	int numberOfImages = [[inResponseDictionary valueForKeyPath:@"photos.photo"] count];
	[(AFOpenFlowView *)self.view setNumberOfImages:numberOfImages];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	NSLog(@"Flickr API request failed with error: %@", [inError description]);
	UIAlertView *flickrErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Flickr API Error" 
																   message:[inError description] 
																  delegate:self 
														 cancelButtonTitle:@"Quit" 
														 otherButtonTitles:@"Retry", nil];
	[flickrErrorAlertView show];
	[flickrErrorAlertView release];
}

- (IBAction)infoButtonPressed:(id)sender {
	NSString *alertString;
	if (interestingnessRequest)
		alertString = @"Many thanks to Lukhnos D. Liu's ObjectiveFlickr library for making it easy to access Flickr's 'Interestingness' photo stream.";
	else
		alertString = @"Sample images included in this project are all in the public domain, courtesy of NASA.";
	UIAlertView *infoAlertPanel = [[UIAlertView alloc] initWithTitle:@"OpenFlow Demo App" 
															 message:[NSString stringWithFormat:@"%@\n\nFor more info about the OpenFlow API, visit apparentlogic.com.", alertString]
															delegate:nil 
												   cancelButtonTitle:nil 
												   otherButtonTitles:@"Dismiss", nil];
	[infoAlertPanel show];
	[infoAlertPanel release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:@"Flickr API Error"]) {
		if (buttonIndex == 0) {
			// Exit
			exit(-1);
		} else if (buttonIndex == 1) {
			// Retry
			[interestingnessRequest callAPIMethodWithGET:@"flickr.interestingness.getList" arguments:nil];
		}
	} else {
		// Assume we're in the initial alert view.
		if (buttonIndex == 0) {
			// Ask flickr for images.
			flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrAPIKey 
														  sharedSecret:flickrAPISecret];
			interestingnessRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickrContext];
			interestingnessRequest.delegate = self;
			[interestingnessRequest callAPIMethodWithGET:@"flickr.interestingness.getList" arguments:nil];
		} else if (buttonIndex == 1) {
			// Use sample images, but load them all at once.
			NSString *imageName;
			for (int i=0; i < 30; i++) {
				imageName = [[NSString alloc] initWithFormat:@"%d.jpg", i];
				[(AFOpenFlowView *)self.view setImage:[UIImage imageNamed:imageName] forIndex:i];
				[imageName release];
			}
			[(AFOpenFlowView *)self.view setNumberOfImages:30]; 
		} else if (buttonIndex == 2) {
			// Use sample images.
			[(AFOpenFlowView *)self.view setNumberOfImages:30]; 
		} 
		
	}
}

- (void)imageDidLoad:(NSArray *)arguments {
	UIImage *loadedImage = (UIImage *)[arguments objectAtIndex:0];
	NSNumber *imageIndex = (NSNumber *)[arguments objectAtIndex:1];
	
	// Only resize our images if they are coming from Flickr (samples are already scaled).
	// Resize the image on the main thread (UIKit is not thread safe).
	if (interestingnessRequest)
		loadedImage = [loadedImage cropCenterAndScaleImageToSize:CGSizeMake(225, 225)];

	[(AFOpenFlowView *)self.view setImage:loadedImage forIndex:[imageIndex intValue]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (UIImage *)defaultImage {
	return [UIImage imageNamed:@"default.png"];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
	AFGetImageOperation *getImageOperation = [[AFGetImageOperation alloc] initWithIndex:index viewController:self];

	if (interestingnessRequest) {
		// We're getting our images from the Flickr API.
		NSDictionary *photoDictionary = [[interestingPhotosDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:index];
		NSURL *photoURL = [flickrContext photoSourceURLFromDictionary:photoDictionary size:OFFlickrMediumSize];
		getImageOperation.imageURL = photoURL;
	}
	
	[loadImagesOperationQueue addOperation:getImageOperation];
	[getImageOperation release];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
	NSLog(@"Cover Flow selection did change to %d", index);
}

@end