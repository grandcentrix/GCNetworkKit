//
//  GCNetworkRequestOperation.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestOperation
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestOperation : NSOperation

/* Returns MD5 hash of this operation */
@property (nonatomic, readonly) NSString *operationHash;

- (id)initWithRequest:(id)request;
+ (id)operationWithRequest:(id)request;

@end
