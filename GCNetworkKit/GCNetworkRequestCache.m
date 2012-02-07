//
//  GCNetworkRequestCache.m
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

#import "GCNetworkRequestCache.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestCache ()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestCache ()

@property (nonatomic, strong, readwrite) NSString *_cacheDirectory;

- (void)_updateCachePath;
- (NSString *)_pathForRequest:(GCNetworkRequest *)request;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestCache
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkRequestCache
@synthesize _cacheDirectory;

#pragma mark Init

+ (GCNetworkRequestCache *)sharedCache {
    static dispatch_once_t pred;
    static GCNetworkRequestCache *__sharedCache = nil;
    
    dispatch_once(&pred, ^{
        __sharedCache = [[GCNetworkRequestCache alloc] init];
    });
    
    return __sharedCache;
}

- (id)init {
    if ((self = [super init]))
        [self _updateCachePath];
    
    return self;
}

#pragma mark Cache - Private

- (void)_updateCachePath {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self._cacheDirectory = [cachesDirectory stringByAppendingPathComponent:@"GCNetworkRequestCache"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:self._cacheDirectory 
                              withIntermediateDirectories:YES 
                                               attributes:nil
                                                    error:NULL];
}

- (NSString *)_pathForRequest:(GCNetworkRequest *)request {
    return [self._cacheDirectory stringByAppendingPathComponent:[request urlHash]];
}

#pragma mark Cache - Public

- (void)cacheData:(NSData *)data forRequest:(GCNetworkRequest *)request {
    [data writeToFile:[self _pathForRequest:request] atomically:YES];
}

- (BOOL)hasCachedDataForRequest:(GCNetworkRequest *)request {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self _pathForRequest:request]];
}

- (NSData *)cachedDataForRequest:(GCNetworkRequest *)request {
    return [NSData dataWithContentsOfFile:[self _pathForRequest:request]];
}

- (void)deleteCachedDataForRequest:(GCNetworkRequest *)request {
    [[NSFileManager defaultManager] removeItemAtPath:[self _pathForRequest:request]
                                               error:nil]; 
}

- (void)removeEverythingWithTimeIntervalSinceNow:(NSTimeInterval)interval {
    NSArray *contentOfCache = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self._cacheDirectory
                                                                                      error:nil];
    for (NSString *_name in contentOfCache) {
        NSString *path = [self._cacheDirectory stringByAppendingPathComponent:@"GCNetworkRequestCache"];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                            error:nil]; 
        NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
            
        if (-[creationDate timeIntervalSinceNow] > interval)
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void)clearCache {
    [[NSFileManager defaultManager] removeItemAtPath:self._cacheDirectory
                                               error:nil];
}

#pragma mark Memory


@end
