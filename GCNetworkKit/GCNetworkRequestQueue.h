//
//  GCNetworkRequestQueue.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestQueue
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestQueue : NSObject

@property (nonatomic, readwrite) NSUInteger maxConcurrentOperations;
@property (nonatomic, readonly, getter = isSuspended) BOOL suspended;

/* Singleton */
+ (GCNetworkRequestQueue *)sharedQueue;

- (NSString *)addRequest:(id)request;

/* Cancel single or all activities */
- (void)cancelRequestWithHash:(NSString *)hash;
- (void)cancelAllRequests;

/* Puase / Resume all activities */
- (void)suspend;
- (void)resume;

@end
