//
//  GCNetworkRequestCache.h
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
