//
//  GCNetworkRequestQueue.h
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
