//
//  GCNetworkImageRequest.m
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

#import "GCNetworkImageRequest.h"
#import "GCDataTransformer.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkImageRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkImageRequest
@synthesize imageCompletionHandler = _imageCompletionHandler;

#pragma mark @override

- (GCNetworkRequestCompletionBlock)completionHandler {
    GCNetworkRequestCompletionBlock block = ^(NSData *downloadedData){   
        TransformNSDataToImage(downloadedData, ^(id image){
            self.imageCompletionHandler(image); 
        });
    };
    
    return [block copy];
}

@end
