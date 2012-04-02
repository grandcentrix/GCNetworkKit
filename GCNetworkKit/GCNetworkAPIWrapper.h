//
//  GCNetworkAPIWrapper.h
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

typedef void (^GCNetworkAPIWrapperDictionaryCallback)(NSDictionary *dictionary, NSError *error);
typedef void (^GCNetworkAPIWrapperArrayCallback)(NSArray *array, NSError *error);
typedef void (^GCNetworkAPIWrapperStringCallback)(NSString *string, NSError *error);
typedef void (^GCNetworkAPIWrapperErrorCallback)(NSError *error);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@class GCNetworkRequestQueue, GCNetworkRequest, GCNetworkFormRequest, GCNetworkDownloadRequest;
@interface GCNetworkAPIWrapper : NSObject

@property (nonatomic, strong, readonly) GCNetworkRequestQueue *networkQueue;

+ (id)sharedWrapper;

// Check whether the main entpoint is reachable
+ (BOOL)endpointReachable;

// Create requests based on the endpoint and default header as well as query values
- (GCNetworkRequest *)requestWithMethod:(NSString *)method;
- (GCNetworkFormRequest *)formRequestWithMethod:(NSString *)method;
- (GCNetworkDownloadRequest *)downloadedRequestWithMethod:(NSString *)method;

- (NSURL *)urlForMethod:(NSString *)method;
- (void)appendDefaultValuesToRequest:(id)request;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper (Subclassing)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkAPIWrapper (Subclassing)

+ (NSURL *)endpoint;
+ (NSDictionary *)defaultHeaderValues;
+ (NSDictionary *)defaultQueryValues;

@end
