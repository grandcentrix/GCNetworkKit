//
//  GCNetworkRequestOperation.m
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

#import "GCNetworkRequestOperation.h"
#import "GCNetworkRequest.h"
#import "NSString+GCNetworkRequest.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  Defines
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

static void *GCNetworkRequestOperationIsRunningDidChangeContext;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestOperation()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequestOperation () {
@private
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic, strong, readwrite) GCNetworkRequest *_request;

- (void)_finish;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequestOperation
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkRequestOperation
@synthesize _request;

#pragma mark Init

+ (id)operationWithRequest:(id)request {
    GCNetworkRequestOperation *op = [[GCNetworkRequestOperation alloc] initWithRequest:request];
    return op;
}

- (id)initWithRequest:(id)request {    
    if ((self = [super init])) {
        self._request = request;
		
        [self._request addObserver:self
                        forKeyPath:@"isRunning" 
                           options:0 
                           context:GCNetworkRequestOperationIsRunningDidChangeContext];
		
        _isExecuting = NO;        
        _isFinished = NO;
    }
    
    return self;
}

#pragma mark Start / Finish / Cancel

- (void)start {
	if (self.isFinished)
		return;
	
    dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self willChangeValueForKey:@"isExecuting"];
        if ([self isCancelled]) {
            [self._request cancel];
			
			_isExecuting = NO;
        } else {
            [self._request start];
			
			_isExecuting = YES;
		}
		[self didChangeValueForKey:@"isExecuting"];
    });
}

- (void)_finish {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.isCancelled)
            return;
		
        [super cancel];
        
        if (self.isExecuting && !self.isFinished)
            [self._request cancel];
    });
}

#pragma mark Getter

- (NSString *)operationHash {
    return [[self description] md5Hash];
}

#pragma mark NSOperation

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context { 
    
    if (context == GCNetworkRequestOperationIsRunningDidChangeContext) {
        if (![self._request isRunning])
            [self _finish];
    }
    else [super observeValueForKeyPath:keyPath
                              ofObject:object
                                change:change
                               context:context];
}

#pragma mark Memory

- (void)dealloc {
    [self._request removeObserver:self forKeyPath:@"isRunning"];
}

@end
