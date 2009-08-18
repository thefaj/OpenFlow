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
#import "AFGetImageOperation.h"
#import "UIImageExtras.h"


@implementation AFGetImageOperation
@synthesize imageURL;

- (id)initWithIndex:(int)imageIndex viewController:(AFOpenFlowViewController *)viewController {
    if (self = [super init]) {
		imageURL = nil;
		photoIndex = imageIndex;
		mainViewController = [viewController retain];
    }
    return self;
}

- (void)dealloc {
	[imageURL release];
	[mainViewController release];
	
    [super dealloc];
}

- (void)main {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	if (imageURL) {
		// Create a UIImage from the imageURL.
		NSData *photoData = [NSData dataWithContentsOfURL:imageURL];
		UIImage *photo = [UIImage imageWithData:photoData];
		
		if (photo) {
			[mainViewController performSelectorOnMainThread:@selector(imageDidLoad:) 
												 withObject:[NSArray arrayWithObjects:photo, [NSNumber numberWithInt:photoIndex], nil] 
											  waitUntilDone:YES];
		}
	} else {
		// Load an image named photoIndex.jpg from our Resources.
		NSString *imageName = [[NSString alloc] initWithFormat:@"%d.jpg", photoIndex];
		UIImage *theImage = [UIImage imageNamed:imageName];
		if (theImage) {
			[mainViewController performSelectorOnMainThread:@selector(imageDidLoad:) 
												 withObject:[NSArray arrayWithObjects:theImage, [NSNumber numberWithInt:photoIndex], nil] 
											  waitUntilDone:YES];
		} else
			NSLog(@"Unable to find sample image: %@", imageName);
		[imageName release];
	}
	
	[pool release];
}

@end