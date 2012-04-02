//
//  GCNetworkAPIWrapper.m
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

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkAPIWrapper
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkAPIWrapper
@synthesize networkQueue = _networkQueue;

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
            sharedWrapper = [[self alloc] init];
            
            if (sharedWrapper)
                [__sharedWrappers setObject:sharedWrapper forKey:key];
        }
    }
    
    return sharedWrapper;
}

- (id)init {
    if ((self = [super init]))
        self.networkQueue = [[GCNetworkRequestQueue alloc] init];
    
    return self;
}

#pragma mark Subclasses

+ (NSURL *)endpoint {
    return nil;
}

+ (NSDictionary *)defaultHeaderValues {
    return nil; 
}

+ (NSDictionary *)defaultQueryValues {
    return nil; 
}

#pragma mark Reachability

+ (BOOL)endpointReachable {
    return [GCNetworkCenter hostIsReachable:[[self endpoint] host]];
}

#pragma mark Requests

- (NSURL *)urlForMethod:(NSString *)method {
    NSString *baseString = [[[self class] endpoint] absoluteString];
   return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseString, method]];
}

- (void)appendDefaultValuesToRequest:(id)request {
    for (NSString *queryKey in [[[self class] defaultQueryValues] allKeys]) {
        NSString *queryValue = [[[self class] defaultQueryValues] objectForKey:queryKey];
        [request setQueryValue:queryValue forKey:queryKey];
    }
    
    for (NSString *headerKey in [[[self class] defaultHeaderValues] allKeys]) {
        NSString *headerValue = [[[self class] defaultHeaderValues] objectForKey:headerKey];
        [request setQueryValue:headerValue forKey:headerKey];
    }
}

- (GCNetworkRequest *)requestWithMethod:(NSString *)method {
    GCNetworkRequest *request = [GCNetworkRequest requestWithURL:[self urlForMethod:method]];
    [self appendDefaultValuesToRequest:request];
    
    return request;
}

- (GCNetworkFormRequest *)formRequestWithMethod:(NSString *)method {
    GCNetworkFormRequest *request = [GCNetworkFormRequest requestWithURL:[self urlForMethod:method]];
    [self appendDefaultValuesToRequest:request];
    
    return request;
}

- (GCNetworkDownloadRequest *)downloadedRequestWithMethod:(NSString *)method {
    GCNetworkDownloadRequest *request = [GCNetworkDownloadRequest requestWithURL:[self urlForMethod:method]];
    [self appendDefaultValuesToRequest:request];
 
    return request;
}

@end
