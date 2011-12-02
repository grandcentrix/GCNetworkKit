//
//  GCNetworkImageRequest.m
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
        TransformNSDataToUIImage(downloadedData, ^(UIImage *image){
            self.imageCompletionHandler(image); 
        });
    };
    
    return [block copy];
}

@end
