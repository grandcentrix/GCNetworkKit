//
//  GCNetworkRequest.h
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

extern NSString *const GCNetworkRequestErrorDomain;
extern NSUInteger const GCNetworkRequestUserDidCancelErrorCode;

typedef enum {
	GCNetworkRequestMethodGET = 0,
	GCNetworkRequestMethodPOST = 1,
    GCNetworkRequestMethodDELETE = 2,
    GCNetworkRequestMethodHEAD = 3,
    GCNetworkRequestMethodOPTIONS = 4,
    GCNetworkRequestMethodPUT = 5,
    GCNetworkRequestMethodTRACE = 6
} GCNetworkRequestMethod;

@class GCNetworkRequest;
typedef void (^GCNetworkRequestResponseBlock)(NSHTTPURLResponse *response);
typedef void (^GCNetworkRequestCompletionBlock)(NSData *responseData);
typedef void (^GCNetworkRequestErrorBlock)(NSError *error);
typedef void (^GCNetworkRequestProgressBlock)(CGFloat progress);
typedef void (^GCNetworkRequestExpirationBlock)();

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequest : NSObject

@property (nonatomic, readwrite) NSTimeInterval timeoutInterval;
@property (nonatomic, readwrite, getter = isContinuingInBackground) BOOL continueInBackground;
@property (nonatomic, readwrite, getter = isLoadingWhileScrolling) BOOL loadWhileScrolling;
@property (nonatomic, readwrite, getter = isShowingNetworkIndicator) BOOL showNetworkIndicator;
@property (nonatomic, readwrite) GCNetworkRequestMethod requestMethod;
@property (nonatomic, readonly, getter = isRunning) BOOL requestRunning;
@property (nonatomic, readonly) NSString *urlHash;
@property (nonatomic, readonly) NSString *requestHash;
@property (nonatomic, strong, readonly) NSURL *baseURL;

/* Callbacks */
@property (nonatomic, copy, readwrite) GCNetworkRequestResponseBlock responseHandler;
@property (nonatomic, copy, readwrite) GCNetworkRequestCompletionBlock completionHandler;
@property (nonatomic, copy, readwrite) GCNetworkRequestErrorBlock errorHandler;
@property (nonatomic, copy, readwrite) GCNetworkRequestProgressBlock progressHandler;
@property (nonatomic, copy, readwrite) GCNetworkRequestExpirationBlock expirationHandler;

+ (id)requestWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;

- (void)start;
- (void)cancel;

/* Header values */
- (void)setHeaderValue:(NSString *)value forField:(NSString *)field;
- (NSString *)headerValueForField:(NSString *)field;

/* Query values */
- (void)setQueryValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)queryValueForKey:(NSString *)key;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequest (Subclassing)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequest (Subclassing)

- (NSMutableURLRequest *)modifiedRequest:(NSMutableURLRequest *)request;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequest (NSURLConnectionDelegate)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequest (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

@end
