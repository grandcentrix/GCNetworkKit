//
//  GCNetworkRequestCache.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>
#import "GCNetworkRequest.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestCache
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestCache : NSObject

/* Singleton */
+ (GCNetworkRequestCache *)sharedCache;

- (BOOL)hasCachedDataForRequest:(GCNetworkRequest *)request;
- (NSData *)cachedDataForRequest:(GCNetworkRequest *)request;
- (void)cacheData:(NSData *)data forRequest:(GCNetworkRequest *)request;
- (void)deleteCachedDataForRequest:(GCNetworkRequest *)request;

/* Removes any cached data */
- (void)clearCache;

/* Removes everything older than the given seconds */
- (void)removeEverythingWithTimeIntervalSinceNow:(NSTimeInterval)interval;

@end
