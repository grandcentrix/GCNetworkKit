//
//  GCNetworkAPIWrapper.m
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import "GCNetworkAPIWrapper.h"
#import "GCNetworkCenter.h"
#import "GCNetworkRequestQueue.h"
#import "GCNetworkRequest.h"
#import "GCNetworkFormRequest.h"
#import "GCNetworkDownloadRequest.h"
#import "NSString+GCNetworkRequest.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkAPIWrapper()

@property (nonatomic, strong, readwrite) GCNetworkRequestQueue *networkQueue;
@property (nonatomic, strong, readwrite) NSString *_token;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkAPIWrapper
@synthesize networkQueue = _networkQueue;
@synthesize _token;

#pragma mark Init

static NSMutableDictionary *__sharedWrappers = nil;
+ (id)sharedWrapper {
    id sharedWrapper = nil;
    
    @synchronized([self class]) {
        if (!__sharedWrappers)
            __sharedWrappers = [[NSMutableDictionary alloc] init];
        
        NSString *key = NSStringFromClass(self);
        sharedWrapper = [__sharedWrappers objectForKey:key];
        if (!sharedWrapper) {
            sharedWrapper = [self new];
            
            if (sharedWrapper)
                [__sharedWrappers setObject:sharedWrapper forKey:key];
        }
    }
    
    return sharedWrapper;
}

- (id)init {
    if ((self = [super init])) {
        self.networkQueue = [GCNetworkRequestQueue new];
        self._token = [self loadToken];
    }
    
    return self;
}

#pragma mark Subclasses

+ (NSURL *)endpoint {
    return [NSURL URLWithString:@""];
}

+ (NSString *)userAgent {
    return NSStringFromClass([self class]);
}

+ (NSString *)accesstokenKey {
    return @"access_token";
}

#pragma mark Reachability

+ (BOOL)endpointReachable {
    return [GCNetworkCenter hostIsReachable:[[self endpoint] host]];
}

#pragma mark Simple auth.

+ (NSString *)accesTokenKey {
    return @"access_token";
}

- (void)saveToken:(NSString *)token {
    // Subclass
}

- (void)deleteToken {
    // Subclass  
}

- (NSString *)loadToken {
    return nil;
}

- (BOOL)isAuthorized {
    if (!self._token)
        self._token = [self loadToken];
    return self._token ? YES : NO;
}

- (void)authorize:(NSString *)accessToken {
    self._token = accessToken;
    [self saveToken:accessToken];
}

- (void)unauthorize {
    self._token = nil;
    [self deleteToken];
}

#pragma mark Requests

- (GCNetworkRequest *)requestWithMethod:(NSString *)method {
    NSString *baseString = [[[self class] endpoint] absoluteString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseString, method]];
    GCNetworkRequest *r = [GCNetworkRequest requestWithURL:url];
    [r setHeaderValue:[[self class] userAgent] forField:@"User-Agent"];
    
    if (self._token && ![self._token isEmpty])
        [r setQueryValue:self._token forKey:[[self class] accesTokenKey]];
    
    return r;
}

- (GCNetworkFormRequest *)formRequestWithMethod:(NSString *)method {
    NSString *baseString = [[[self class] endpoint] absoluteString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseString, method]];
    GCNetworkFormRequest *r = [GCNetworkFormRequest requestWithURL:url];
    [r setHeaderValue:[[self class] userAgent] forField:@"User-Agent"];
    
    if (self._token && ![self._token isEmpty])
        [r setQueryValue:self._token forKey:[[self class] accesTokenKey]];
    
    return r;
}

- (GCNetworkDownloadRequest *)downloadedRequestWithMethod:(NSString *)method {
    NSString *baseString = [[[self class] endpoint] absoluteString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseString, method]];
    GCNetworkDownloadRequest *r = [GCNetworkDownloadRequest requestWithURL:url];
    [r setHeaderValue:[[self class] userAgent] forField:@"User-Agent"];
    
    if (self._token && ![self._token isEmpty])
        [r setQueryValue:self._token forKey:[[self class] accesTokenKey]];
    
    return r;
}

@end
