//
//  GCNetworkRequestQueue.m
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

#import "GCNetworkRequestQueue.h"
#import "GCNetworkRequestOperation.h"
#import "NSString+GCNetworkRequest.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestQueue()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestQueue ()

@property (nonatomic, strong, readwrite) NSOperationQueue *_operationQueue;
@property (nonatomic, strong, readwrite) NSMutableDictionary *_operations;

- (void)_doneForOperation:(GCNetworkRequestOperation *)operation;

@end
    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestOperator
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkRequestQueue
@synthesize maxConcurrentOperations = _maxConcurrentOperations;
@synthesize _operationQueue;
@synthesize _operations;

#pragma mark Init

+ (GCNetworkRequestQueue *)sharedQueue {
    static dispatch_once_t pred;
    static GCNetworkRequestQueue *__sharedQueue = nil;
    
    dispatch_once(&pred, ^{
        __sharedQueue = [[GCNetworkRequestQueue alloc] init];
    });
    
    return __sharedQueue;
}

- (id)init {
    if ((self = [super init])) {
        self._operationQueue = [NSOperationQueue new];
        [self._operationQueue setMaxConcurrentOperationCount:1];
        self._operationQueue.name = @"GCNetworkRequestOperator-NSOperationQueue";        
  
        self._operations = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context { 
    
    [self _doneForOperation:object];   
}

- (void)_doneForOperation:(GCNetworkRequestOperation *)operation {
    [self._operations removeObjectForKey:[operation operationHash]];
}

#pragma mark @properties

- (void)setMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations {
    [self._operationQueue setMaxConcurrentOperationCount:maxConcurrentOperations];
}

- (BOOL)isSuspended {
    return [self._operationQueue isSuspended];
}

#pragma mark Manage Operations

- (NSString *)addRequest:(id)request {
    GCNetworkRequestOperation *operation = [GCNetworkRequestOperation operationWithRequest:request];
    [operation addObserver:self
                forKeyPath:@"isFinished" 
                   options:0 
                   context:NULL];

    NSString *hash = [operation operationHash];
    [self._operations setObject:operation forKey:hash];
    [self._operationQueue addOperation:operation];
    
    return hash;
}

- (void)cancelRequestWithHash:(NSString *)hash {
    GCNetworkRequestOperation *operation = [self._operations objectForKey:hash];
    if (operation)
        [operation cancel];
}

- (void)cancelAllRequests {
    [self._operationQueue cancelAllOperations];
}

#pragma mark Suspend / Resume

- (void)suspend {
    if (!self.isSuspended)
        [self._operationQueue setSuspended:YES];
}

- (void)resume {
    if (self.isSuspended)
        [self._operationQueue setSuspended:NO];
}

#pragma mark Memory

- (void)dealloc {
    [self cancelAllRequests];
    
}

@end
