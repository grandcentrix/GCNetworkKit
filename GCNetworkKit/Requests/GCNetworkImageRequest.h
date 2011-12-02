//
//  GCNetworkImageRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import "GCNetworkRequest.h"

typedef void (^GCNetworkImageRequestCompletionBlock)(UIImage *image);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkImageRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkImageRequest : GCNetworkRequest

@property (nonatomic, copy, readwrite) GCNetworkImageRequestCompletionBlock imageCompletionHandler;

@end
