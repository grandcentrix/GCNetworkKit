//
//  GCNetworkRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
