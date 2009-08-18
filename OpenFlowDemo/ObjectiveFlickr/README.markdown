ObjectiveFlickr
===============

ObjectiveFlickr is a Flickr API framework designed for Mac and iPhone apps.


What's New in 2.0
=================

Version 2.0 is a complete rewrite, with design integrity and extensibility in
mind. Differences from 0.9.x include:

* The framework now builds with all major Apple SDKs: Mac OS X 10.4,
  10.5, iPhone OS 2.2.x, and other beta version platforms to which I have 
  access. It also builds on both 32-bit and 64-bit platforms.
* Ordinary request and upload request are now unified into one 
  OFFlickrAPIRequest class
* 2.0 no longer depends on NSXMLDocument, which is not available in iPhone 
  SDK. It now maps Flickr's XML response into an NSDictionary using only 
  NSXMLParser, which is available on all Apple platforms.
* Image uploading employs temp file. This allows ObjectiveFlickr to operate
  in memory-constrained settings.
* Error reporting now uses NSError to provide more comprehensive information,
  especially error code and message from Flickr.
  
If you already use ObjectiveFlickr 0.9.x, the bad news is that 2.0 is not
backward compatible. The good news, though, is that it uses a different set
of class names. Some migration tips is offered near the end of this document.


What's Not (Yet) There
======================

There are of course quite a few to-do's:

* In-source API documentation
* Unit testings
* Flickr API coverage tests (challenging though—how do you test a moving
  target?)
* ObjectiveFlickr 0.9.x has a few convenient methods and tricks to simplify 
  method calling; they are not ported here (yet, or will never be)


Quick Start: Example Apps You Can Use
=====================================

1. Check out the code from github:

        git clone git://github.com/lukhnos/objectiveflickr.git

2. Supply your own API key and shared secret. You need to copy
   `SimpleAPIKey.h.template` to `SimpleAPIKey.h`, and fill in the two
   macros there. If you don't have an API key, apply for yours at:
   <http://www.flickr.com/services/api/keys/apply/> .
   Make sure you have understood their terms and conditions.

3. Remember to make your API key a "web app", and set the *Callback URL*
   (not the *Application URL*!) to:

        snapnrun://auth?   

4. Build and run SnapAndRun for iPhone. The project is located at 
   `Examples/SnapAndRun-iPhone`

5. Build and run RandomPublicPhoto for Mac. The project is at 
   `Examples/RandomPublicPhoto`


Adding ObjectiveFlickr to Your Project
======================================

Unlike Microsoft Visual Studio, Xcode does not shine in cross-project 
development. Fortunately you don't need to do this often. If anything fails, 
refer to our example apps for the project file structuring.

Adding ObjectiveFlickr to Your Mac App Project
----------------------------------------------

1. `Add ObjectiveFlickr.xcodeproj` to your Mac project (from Xcode menu 
   **Project > Add to Project...**)
2. On your app target, open the info window (using **Get Info** on the 
   target), then in the **General** tab, add `ObjectiveFlickr (framework)`
   to **Direct Dependencies**
3. Add a new **Copy Files** phase, and choose **Framework** for the 
   **Destination** (in its own info window)
4. Drag `ObjecitveFlickr.framework` from the Groups & Files panel in Xcode 
   (under the added `ObjectiveFlickr.xcodeproj`) to the newly created **Copy 
   Files** phase
5. Drag `ObjecitveFlickr.framework` once again to the target's **Linked Binary 
   With Libraries** group
6. Open the Info window of your target again. Set **Configuration** to **All 
   Configurations**, then in the **Framework Search Paths** property, add 
   `$(TARGET_BUILD_DIR)/$(FRAMEWORKS_FOLDER_PATH)`
7. Use `#import <ObjectiveFlickr/ObjectiveFlickr.h>` in your project

Adding ObjectiveFlickr to Your iPhone App Project
-------------------------------------------------

Because iPhone SDK does not allow dynamically linked frameworks and bundles, we need to link against ObjectiveFlickr statically.

1. `Add ObjectiveFlickr.xcodeproj` to your Mac project (from Xcode menu 
   **Project > Add to Project...**)
2. On your app target, open the info window (using **Get Info** on the 
   target), then in the **General** tab, add `ObjectiveFlickr (library)` to 
   **Direct Dependencies**
3. Also, in the same window, add `CFNetwork.framework` to
   **Linked Libraries**
4. Drag `libObjecitveFlickr.a` to the target's **Linked Binary With Libraries
   group**
5. Open the Info window of your target again. Set **Configuration** to **All 
   Configurations**, then in the **Header Search Paths** property, add these 
   two paths, separately (`<OF root>` is where you checked out
   ObjectiveFlickr):

        <OF root>/Source
        <OF root>/LFWebAPIKit   
       
6. Use `#import "ObjectiveFlickr.h"` in your project


Key Ideas and Basic Usage
=========================

**ObjectiveFlickr is an asynchronous API.** Because of the nature of GUI 
app, all ObjectiveFlickr requests are asynchronous. You make a request, then 
ObjectiveFlickr calls back your delegate methods and tell you if a request 
succeeds or fails.

**ObjectiveFlickr is a minimalist framework.** The framework has essentially
only two classes you have to deal with: `OFFlickrAPIContext` and
`OFFlickrAPIRequest`. Unlike many other Flickr API libraries, ObjectiveFlickr 
does *not* have classes like FlickrPhoto, FlickrUser, FlickrGroup or 
whathaveyou. You call a Flickr method, like `flickr.photos.getInfo`, and get back a dictionary (hash or map in other languages) containing the key-value 
pairs of the result. The result is *directly mapped from Flickr's own 
XML-formatted response*. Because they are already *structured data*, 
ObjectiveFlickr does not  translate further into other object classes. 

Because of the minimalist design, you also need to have basic understanding of
**how Flickr API works**. Refer to <http://www.flickr.com/services/api/> for 
the details. But basically, all you need to know is the methods you want to
call, and which XML data (the key-values) Flickr will return.

Typically, to develop a Flickr app for Mac or iPhone, you need to follow the following steps:

1. Get you Flickr API key at <http://www.flickr.com/services/api/keys/apply/>
2. Create an OFFlickrAPIContext object

        OFFlickrAPIContext *context = [[OFFlickrAPIContext alloc] initWithAPIKey:YOUR_KEY sharedSecret:YOUR_SHARED_SECRET];

3. Create an OFFlickrAPIRequest object where appropriate, and set the delegate

        OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
        
        // set the delegate, here we assume it's the controller that's creating the request object
        [request setDelegate:self];
        
4. Implement the delegate methods.

        - (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary;
        - (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError;
        - (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes;

    All three methods are optional ("informal protocol" in old Objective-C 
    speak; optional protocol methods in newspeak). *Nota bene*: If you
    are using Mac OS X 10.4 SDK, or if you are using 10.5 SDK but targeting
    10.4, then the delegate methods are declared as informal protocols.
    In all other cases (OS X 10.5 and above or iPhone apps), you need to
    specify you are adopting the OFFlickrAPIRequestDelegate protocol. *E.g.*:
    
        @interface MyViewController : UIViewController <OFFlickrAPIRequestDelegate>


5. Call the Flickr API methods you want to use. Here are a few examples.

    Calling `flickr.photos.getRecent` with the argument `per_page` = `1`:
    
        [request callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]]
        
    Quite a few Flickr methods require that you call with HTTP POST
    (because those methods write or modify user data):

        [request callAPIMethodWithPOST:@"flickr.photos.setMeta" arguments:[NSDictionary dictionaryWithObjectsAndKeys:photoID, @"photo_id", newTitle, @"title", newDescription, @"description", nil]];

6. Handle the response or error in the delegate methods. If an error
   occurs, an NSError object is passed to the error-handling delegate 
   method. If the error object's domain is `OFFlickrAPIReturnedErrorDomain`,
   then it's a server-side error. You can refer to Flickr's API documentation
   for the meaning of the error. If the domain is
   `OFFlickrAPIRequestErrorDomain`, it's client-side error, usually caused
   by lost network connection or transfer timeout.
   
   We will now talk about the response.


How to Upload a Picture
=======================

To upload a picture, create an NSInputStream object from a file path
or the image data (NSData), then make the request. Here in the example
we assume we already have obtained the image data in JPEG, and we set
make private the uploaded picture:
   
        NSInputStream *imageStream = [NSInputStream inputStreamWithData:imageData];
        [request uploadImageStream:imageStream suggestedFilename:@"Foobar.jpg" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", nil]];
      
Upload progress will be reported to the delegate method
`flickrAPIRequest:imageUploadSentBytes:totalBytes:`

The reason why ObjectiveFlickr asks for an NSInputStream object as input
is that we don't want to read in the whole image into memory for the 
preparation of upload data. With NSInputStream you have the flexibility
of feeding ObjectiveFlickr an in-memory image data, a file, or even a
virtualized image byte stream that comes from different (e.g. partitioned)
sources.

Make sure you have read [Flickr's upload API documentation](
http://www.flickr.com/services/api/upload.api.html) so that you understand
how to pick up the upload result. Please note that between the completion
of uploading and the completion of the HTTP POST request itself (the moment
at which you receive the response), there can be a *long* wait. So make sure
you have a long timeout interval, especially when you upload a large image,
and also design your UI accordingly.


Auth Considerations
===================

If your app does not just read public photos, your app will need to get 
user permission for accessing their photos. You need to use Flickr's
authentication/authorization mechanism (hereafter "auth" to cover both
steps) to get the *authToken* for your later access.

This is, frankly, the most difficult part in using the whole Flickr API;
anything that comes after that is easy and (usually) smooth. That alone
is worth a whole tutorial, but I'll try to explain the essentials.

Before that, get to know Flickr's own doc here:
<http://www.flickr.com/services/api/misc.userauth.html>.

There are two types of app auth:

* [Desktop app](http://www.flickr.com/services/api/auth.howto.desktop.html)
* [Web app](http://www.flickr.com/services/api/auth.howto.web.html)

There is actually a "mobile app" auth, designed for feature phones or
smart phones that aren't, well, not really smart, if you buy what Apple
says. But since we are talking about *Mac* and *iPhone* apps, and they
aren't any ye olde mobile platform, we'll skip that one and go straight
into the two major types of app auth.


Desktop App Auth, the Old Way
-----------------------------

Before, Mac developers were only interested in Desktop app auth. If you 
have used any Mac Flickr app before (FlickrExport, HoudahGeo, Posterino, and
many others), you know how it works:

1. Open the app
2. The app presents a dialog box, telling you it's going to open the web
   browser. You log into Flickr, Flickr asks you if you grant permission
   to the app currently asking for your permission (read, write, or
   delete access).
3. After you grant the permission, you *switch back* to the app, 
   hit some "Continue" button on the app the dialog box.
4. The app fetches the auth token from Flickr, and completes the process.

To map that into your app's internal workings, you need to do these:

1. Call [flickr.auth.getFrob](
   http://www.flickr.com/services/api/flickr.auth.getFrob.html)
2. After you receive the frob, pass the whole `inResponseDictionary` to
   `-[OFFlickrAPIContext loginURLFromFrobDictionary:requestedPermission:]`
   and get the returned NSURL object.
3. Tell user that you're going to open the browser for them, prompt for
   action.
4. Open the browser with the URL you just got, then wait
5. After user completes the auth, she will click on the "Continue" button
   (or something like that).
6. Your app then calls [flickr.auth.getToken](
   http://www.flickr.com/services/api/flickr.auth.getToken.html) to get
   the auth token
7. Assign the auth token to your current Flickr API context with
   `-[OFFlickrAPIContext setAuthToken:]`
8. That's it. ObjectiveFlickr will add the `auth_token` argument to all 
   your subsequent API calls, and you know have the access to all the APIs
   to which the user has grant you permission.


iPhone App Auth and the New Way
-------------------------------

iPhone and iPod Touch posed a challenge to the auth model above: Opening
up Mobile Safari then ask the forgetful user to come back is a bad idea.

So many iPhone developers have come up with this brilliant idea: Use 
URL scheme to launch your app. It turns out that Flickr's web app auth
serves the idea well. Here is how it works:

1. The app prompts user that it's going to open up browser to ask for
   permission.
2. The user taps some "Open" button, and the app closes, Mobile Safari
   pops up with Flickr's login (and then app auth) page.
3. Then magically, Mobile Safari closes, and the app is launched again.
4. There's no Step 4.

What's behind the scene is that the iPhone app in question has registered
a URL scheme, for example `someapp://` in its `Info.plist` and the app
developer has configured their Flickr API key, so that when the user
grants the app permission, Flickr will redirect the web page to that *URL*
the app developer has previously designated. Mobile Safari opens that
URL, and then the app is launched.

In fact, Mac app can do that, too!

Here's what you need to do:

1. Register the URL scheme. Take a look at my own SnapAndRun-iPhone 
   example app's `SnapAndRun-Info.plist` and this [CocoaDev article](
   http://www.cocoadev.com/index.pl?HowToRegisterURLHandler) for details.
2. Configure your Flickr API key so that the *callback URL* is set to 
   that URL scheme.
3. Get a login URL by calling
   `-[OFFlickrAPIContext loginURLFromFrobDictionary:requestedPermission:]`,
   note that you don't need to have a frob dictionary for getting web app
   login (auth) URL, so just pass nil. You still need to pass the
   permission argument, of course.
4. Now, in your app launch URL handler (Mac and iPhone apps do it
   differently, see Apple doc for details), get the frob that Flickr
   has passed to you with the URL.
5. Your app then calls [flickr.auth.getToken](
  http://www.flickr.com/services/api/flickr.auth.getToken.html) to get
  the auth token
6. Assign the auth token to your current Flickr API context with
  `-[OFFlickrAPIContext setAuthToken:]`
7. That's it. ObjectiveFlickr will add the `auth_token` argument to all 
  your subsequent API calls, and you know have the access to all the APIs
  to which the user has grant you permission.

Now you have done the most difficult part of using the Flickr API.

   
How Flickr's XML Responses Are Mapped Back
==========================================

Flickr's default response format is XML. You can opt for JSON. Whichever
format you choose, the gist is that *they are already structured data*.
When I first started designing ObjectiveFlickr, I found it unnecessary to
create another layer of code that maps those data to and from "native"
objects. So we don't have things like `OFFlickrPhoto` or `OFFlickrGroup`.
In essence, when an request object receives a response, it maps the XML
into a data structure consisting of NSDictionary's, NSArray's and 
NSString's. In Apple speak, this is known as "property list". And we'll
use that term to describe the mapped result. You then read out in the property
list the key-value pairs you're interested in.

ObjectiveFlickr uses the XML format to minimize dependency. It parses the
XML with NSXMLParser, which is available on all Apple platforms. It maps
XML to property list following the three simple rules:

1. All XML tag properties are mapped to NSDictionary key-value pairs
2. Text node (e.g. `<photoid>12345</photoid>`) is mapped as a dictionary
   containing the key `OFXMLTextContentKey` (a string const) with its value
   being the text content.
3. ObjectiveFlickr knows when to translate arrays. We'll see how this is 
   done now.
   
So, for example, this is a sample response from flickr.auth.checkToken   

    <?xml version="1.0" encoding="utf-8" ?>
    <rsp stat="ok">
    <auth>
    	<token>aaaabbbb123456789-1234567812345678</token>
    	<perms>write</perms>
    	<user nsid="00000000@N00" username="foobar" fullname="blah" />
    </auth>
    </rsp>
 
Then in your `flickrAPIRequest:didCompleteWithResponse:` delegate method,
if you dump the received response (an NSDictionary object) with NSLog,
you'll see something like (extraneous parts omitted):

    {
        auth ={
            perms = { "_text" = write };
            token = { "_text" = "aaaabbbb123456789-1234567812345678"; };
            user = {
                fullname = "blah";
                nsid = "00000000@N00";
                username = foobar;
            };
        };
        stat = ok;
    }
 
So, say, if we are interested in the retrieved auth token, we can do this:

    NSString *authToken = [[inResponseDictionary valueForKeyPath:@"auth.token"] textContent];
    
Here, our own `-[NSDictionary textContent]` is simply a convenient method
that is equivalent to calling `[authToken objectForKey:OFXMLTextContentKey]`
in our example.

Here is another example returned by `flickr.photos.getRecent`:

    <?xml version="1.0" encoding="utf-8" ?>
    <rsp stat="ok">
    <photos page="1" pages="334" perpage="3" total="1000">
    	<photo id="3444583634" owner="37096380@N08" secret="7bbc902132" server="3306" farm="4" title="studio_53_1" ispublic="1" isfriend="0" isfamily="0" />
    	<photo id="3444583618" owner="27122598@N06" secret="cc76db8cf8" server="3327" farm="4" title="IMG_6830" ispublic="1" isfriend="0" isfamily="0" />
    	<photo id="3444583616" owner="26073312@N08" secret="e132988dc3" server="3376" farm="4" title="Cidade Baixa" ispublic="1" isfriend="0" isfamily="0" />
    </photos>
    </rsp>
    
And the mapped property list looks like:
    
    {
        photos = {
            page = 1;
            pages = 334;
            perpage = 3;
            photo = (
                {
                    farm = 4;
                    id = 3444583634;
                    isfamily = 0;
                    isfriend = 0;
                    ispublic = 1;
                    owner = "37096380@N08";
                    secret = 7bbc902132;
                    server = 3306;
                    title = "studio_53_1";
                },
                {
                    farm = 4;
                    id = 3444583618;
                    /* ... */
                },
                {
                    farm = 4;
                    id = 3444583616;
                    /* ... */
                }
            );
            total = 1000;
        };
        stat = ok;
    }

ObjectiveFlickr knows to translate the enclosed <photo> tags in the plural
<photos> tag into an NSArray. So if you want to retrieve the second photo
in the array, you can do this:

    NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:1];

Then, with two helper methods from `OFFlickrAPIContext`, you can get the
static photo source URL and the photo's original web page URL:

    NSURL *staticPhotoURL = [flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrSmallSize];
    NSURL *photoSourcePage = [flickrContext photoWebPageURLFromDictionary:photoDict];

Do remember that Flickr requires you present a link to the photo's web page
wherever you show the photo in your app. So design your UI accordingly.


Wacky XML Mappings
==================

Unfortunately, there are some Flickr responses that don't rigorously follow
the "plural tag == array" rule. Consider the following snippet (tag
attributes removed to highlight the issue at hand), from the API method
[flickr.activity.userPhotos](
http://www.flickr.com/services/api/flickr.activity.userPhotos.html):

    <rsp stat="ok">
    <items page="1" pages="1" perpage="50" total="3">
    	<item type="photo">
    		<title>Snap and Run Demo</title>
    		<activity>
    			<event type="comment">double comment 1</event>
    			<event type="comment">double comment 2</event>
    		</activity>
    	</item>
    	<item type="photo">
    		<title>Snap and Run Demo</title>
    		<activity>
    			<event type="comment">test comment 1</event>
    		</activity>
    	</item>
    </items>
    </rsp>
    
Note how the `<activity>` tag can enclose *either* one *or* more 
`<event>` tags. This is actually a gray area of Flickr API and I'm not 
entirely sure if I should write that exception into the book (*i.e.* the
logic of `OFXMLMapper`, which handles the job). The list of exceptions
could never be comprehensive.

We can make good use of Objective-C's dynamic nature to work around the
problem. We can tell if it's an array:

    // get the first element in the items
    NSArray *itemArray = [responseDict valueForKeyPath:@"items.item"];
    NSDictionary *firstItem = [itemArray objectAtIndex:0];

    // get the "event" element and see if it's an array
    id event = [firstItem valueForKeyPath:@"activity.event"];
        
    if ([event isKindOfClass:[NSArray class]]) {
        // it has more than one elements
        NSDictionary *someEvent = [event objectAtIndex:0];
    }
    else {
        // that's the only element
        NSDictionary *someEvent = event;
    }
    
On the other hand, the reason why we build the plural tag rule in 
`OFXMLMapper` is that writing the boilerplate above for frequently-used
tags again and again is very tedious. Since `OFXMLMapper` already handles
the plural tags, the borderline cases are easier to tackle.
    

Design Patterns and Tidbits
===========================

Design Your Own Trampolines
---------------------------

`OFFlickrAPIRequest` has a `sessionInfo` property that you can use to provide
state information of your app. However, it will soon become tedious to write
tons of `if`-`else`s in the delegate methods. My experience is that I design
a customized "session" object with three properties: delegate (that doesn't
have to be the originator of the request), selector to call on completion,
selector to call on error. Then the delegate methods for `OFFlickrAPIRequest`
simply dispatches the callbacks according to the session object.

If your controller calls a number of Flickr methods or involves multiple
stages/states, this design pattern will be helpful.

Thread-Safety
-------------

Each OFFlickrAPIRequest object can be used in the thread on which it is created. Do not pass them across threads. Delegate methods are also called in the thread in which the request object is running.

CFNetwork-Based
---------------

ObjectiveFlickr uses LFHTTPRequest, which uses only the CFNetwork stack.
NSURLConnection is reported to have its own headaches. On the other hand,
LFHTTPRequest does not handle non-HTTP URLs (it does handle HTTPS with
a catch: on iPhone you cannot use untrusted root certs) and does not do
HTTP authentication. It also does not manage caching. For web API
integration, however, LFHTTPRequest provides a lean way of making and
managing requests.

One side note: LFHTTPRequest will use your system's shared proxy settings
on your Mac or iPhone. This is how it requires `SystemConfiguration.framework`
on Mac when being built alone.


Possible Migration Path from ObjectiveFlickr 0.9.x
--------------------------------------------------

I didn't really seriously investigate this, but here are some thoughts:

* In theory 0.9.x and 2.0 should co-exist as there is no class name clashes.
* OFFlickrContext becomes OFFlickrAPIContext
* OFFlickrInvocation becomes OFFlickrAPIRequest
* OFFlickrUploader is now merged into OFFlickrAPIRequest
* Delegate methods are greatly simplified and redesigned




History
=======

ObjectiveFlickr was first released in late 2006. The previous version, 0.9.x,
has undergone one rewrite and is hosted on [Google 
Code](http://code.google.com/p/objectiveflickr). It also has a Ruby version
available as a [Ruby gem](http://rubyforge.org/frs/?group_id=2698).

The present rewrite derives from the experiences that I have had in
developing Mac and iPhone products (I run my own company, [Lithoglyph](lithoglyph.com)). It's a great learning process.


Acknowledgements
================

Many people have given kind suggestions and directions to the development
of ObjectiveFlickr. And there are a number of Mac apps that use it. I'd like
to thank Mathieu Tozer, Tristan O'Tierney, Christoph Priebe, Yung-Lun Lan, 
and Pierre Bernard for the feedbacks that eventually lead to the framework's
present design and shape.


Copyright and Software License
==============================

ObjectiveFlickr Copyright (c) 2006-2009 Lukhnos D. Liu.

LFWebAPIKit Copyright (c) 2007-2009 Lukhnos D. Liu and Lithoglyph Inc.

One test in LFWebAPIKit (`Tests/StreamedBodySendingTest`) makes
use of [Google Toolbox for Mac](
http://code.google.com/p/google-toolbox-for-mac/), Copyright (c) 2008 Google Inc. Refer to `COPYING.txt` in the directory for the full text of the Apache License, Version 2.0, under which the said software is licensed.

Both ObjectiveFlickr and LFWebAPIKit are released under the MIT license,
the full text of which is printed here as follows. You can also 
find the text at: <http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Contact
=======

* lukhnos {at} lukhnos {dot} org
* [@lukhnos](http://twitter.com/lukhnos) on Twitter
* <http://lukhnos.tumblr.com> (blog in English)

Links
=====

* Project host: <http://github.com/lukhnos/objectiveflickr>
* ObjectiveFlickr blog: <http://lukhnos.org/objectiveflickr/blog/>
* Discussion group: <http://groups.google.com/group/objectiveflickr>
* Issue tracking: <http://code.google.com/p/objectiveflickr/issues/list>
