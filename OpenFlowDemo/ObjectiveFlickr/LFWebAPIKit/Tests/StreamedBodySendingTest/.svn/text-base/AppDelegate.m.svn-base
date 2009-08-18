//
// AppDelegate.m
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

#import "AppDelegate.h"

@implementation AppDelegate
- (void)dealloc
{
    [HTTPServer stop];
    [HTTPServer release];
    [HTTPRequest release];
    [randomData release];
    [super dealloc];
}

- (void)awakeFromNib
{
    HTTPServer = [[GTMHTTPServer alloc] initWithDelegate:self];
    HTTPRequest = [[LFHTTPRequest alloc] init];
    [HTTPRequest setDelegate:self];
    
    NSError *error;
    [HTTPServer setPort:25642];
    [HTTPServer start:&error];
    
    NSAssert(!error, @"Server must start");
    [messageText setStringValue:@"Server started at port 25642, press button to test"];
}
- (IBAction)testButtonAction:(id)sender
{
    if (randomData) {
        [randomData release];
    }
    
    randomData = [[NSMutableData dataWithLength:1024 * 1024] retain];
    uint8_t *bytes = [randomData mutableBytes];
    size_t i;
    for (i = 0 ; i < 1024 * 1024 ; i++) {
        bytes[i] = 0x80;
    }
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:randomData];                                
    [HTTPRequest performMethod:LFHTTPRequestPOSTMethod onURL:[NSURL URLWithString:@"http://localhost:25642"] withInputStream:inputStream knownContentSize:[randomData length]];
}

- (GTMHTTPResponseMessage *)httpServer:(GTMHTTPServer *)server handleRequest:(GTMHTTPRequestMessage *)request
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, [[request body] length]);
    return [GTMHTTPResponseMessage responseWithHTMLString:@"<b>Hello</b>, world!"];
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [request receivedData]);
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

@end
