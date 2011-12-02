//
//  GCNetworkRequestOperation.m
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([self isCancelled])
            [self._request cancel];
        else
            [self._request start];
    });
}

- (void)_finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isExecuting"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self willChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isFinished"];
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
