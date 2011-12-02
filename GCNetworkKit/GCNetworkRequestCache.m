//
//  GCNetworkRequestCache.m
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
