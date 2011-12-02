//
//  GCNetworkAPIWrapper.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

typedef void (^GCNetworkAPIWrapperDictionaryCallback)(NSDictionary *dictionary, NSError *error);
typedef void (^GCNetworkAPIWrapperArrayCallback)(NSArray *array, NSError *error);
typedef void (^GCNetworkAPIWrapperStringCallback)(NSString *string, NSError *error);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@class GCNetworkRequestQueue, GCNetworkRequest, GCNetworkFormRequest, GCNetworkDownloadRequest;
@interface GCNetworkAPIWrapper : NSObject

/* A NSOperationQueue handling all network requests */
@property (nonatomic, strong, readonly) GCNetworkRequestQueue *networkQueue;

/* Singleton */
+ (id)sharedWrapper;

/* Check whether the main reachpoint is available */
+ (BOOL)endpointReachable;

/* Create requests based on the endpoint, user agent and access token */
- (GCNetworkRequest *)requestWithMethod:(NSString *)method;
- (GCNetworkFormRequest *)formRequestWithMethod:(NSString *)method;
- (GCNetworkDownloadRequest *)downloadedRequestWithMethod:(NSString *)method;

/* Authorization */
- (BOOL)isAuthorized;
- (void)unauthorize;
- (void)authorize:(NSString *)accessToken;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper (Subclassing)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkAPIWrapper (Subclassing)

- (void)deleteToken;
- (void)saveToken:(NSString *)token;
- (NSString *)loadToken;

+ (NSURL *)endpoint;
+ (NSString *)userAgent;
+ (NSString *)accesstokenKey;

@end
