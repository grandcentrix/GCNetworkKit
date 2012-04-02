//
//  Tweet.m
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//
//  Copyright 2012 Giulio Petek
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import "Tweet.h"
#import "GCNetworkKit.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// Tweet ()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface Tweet ()

@property (nonatomic, strong, readwrite) UIImage *_image;
@property (nonatomic, strong, readwrite) NSURL *_imageURL;
@property (nonatomic, strong, readwrite) NSString *user;
@property (nonatomic, strong, readwrite) NSString *content;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// Tweet
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation Tweet
@synthesize content = _content;
@synthesize textHeight;
@synthesize user = _user;
@synthesize _image;
@synthesize _imageURL;

#pragma mark init

+ (NSArray *)tweetsForJSON:(NSArray *)json {
    NSMutableArray *tweets = [NSMutableArray arrayWithCapacity:[json count]];
    for (NSDictionary *dict in json) {
        Tweet *tweet = [[Tweet alloc] initWihtJSON:dict];
        [tweets addObject:tweet];
    }
    
    return [tweets copy];
}

- (id)initWihtJSON:(NSDictionary *)json {
    if ((self = [super init])) {
        self.user = [json objectForKey:@"from_user"];
        self.content = [json objectForKey:@"text"];
        self._imageURL = [NSURL URLWithString:[json objectForKey:@"profile_image_url"]];
    }
    
    return self;
}

#pragma mark image loading

- (UIImage *)loadImageWithCallback:(TweetImageCallback)callback {
    if (self._image || !self._imageURL)
        return self._image;

    // The request
    GCNetworkImageRequest *request = [GCNetworkImageRequest requestWithURL:self._imageURL];
    request.timeoutInterval = 10.0f;
    request.loadWhileScrolling = YES;
    
    __GC_weak Tweet *_weak = self;
    request.imageCompletionHandler = ^(id image){
        callback(image);
            
        _weak._image = image;
        _weak._imageURL = nil;
    };
    
    [[GCNetworkRequestQueue sharedQueue] addRequest:request];;
       
    return nil;
}

@end
