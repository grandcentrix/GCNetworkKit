//
//  GCNetworkRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import "GCNetworkRequest.h"
#import "GCNetworkCenter.h"
#import "NSString+GCNetworkRequest.h"

NSString *const GCNetworkRequestErrorDomain = @"de.GiulioPetek.GCNetworkRequest-ErrorDomain";
NSUInteger const GCNetworkRequestUserDidCancelErrorCode = 110;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  GCNetworkRequest()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequest ()  {
@private
    struct {
        BOOL started;
        BOOL finished;
    } _requestFlags;  
}

@property (nonatomic, strong, readwrite) NSURLConnection *_connection;
@property (nonatomic, strong, readwrite) NSMutableData *_downloadedData;
@property (nonatomic, strong, readwrite) NSURL *_url;
@property (nonatomic, strong, readwrite) NSMutableDictionary *_headerFields;
@property (nonatomic, strong, readwrite) NSMutableDictionary *_queryValues;
@property (nonatomic, readwrite) UIBackgroundTaskIdentifier taskIdentifier;
@property (nonatomic, readwrite) long long _downloadedContentLength;
@property (nonatomic, readwrite) long long _expectedContentLength;

- (void)_cleanUp;
- (NSMutableURLRequest *)_buildRequest;
- (NSURL *)_buildURL;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequest(GCNetworkErrors)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkRequest (GCNetworkErrors)

+ (NSError *)userCancellationError;
+ (NSError *)errorWithLocalizedDescription:(NSString *)description code:(NSInteger)code;
+ (NSError *)htmlErrorForCode:(NSInteger)code;

@end

@implementation GCNetworkRequest (GCNetworkErrors)

+ (NSError *)userCancellationError {
    return [GCNetworkRequest errorWithLocalizedDescription:@"User did cancel request." code:GCNetworkRequestUserDidCancelErrorCode];
}

+ (NSError *)errorWithLocalizedDescription:(NSString *)description code:(NSInteger)code {
    if ([description isEmpty])
        description = @"Invalid description for this error.";
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:GCNetworkRequestErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)htmlErrorForCode:(NSInteger)code {
    NSString *description = nil;
    if (code == 400)
        description = @"The request cannot be fulfilled due to bad syntax.";
    else if (code == 401)
        description = @"You are not authorized.";
    else if (code == 403)
        description = @"The server did not have permission to open the file.";
    else if (code == 404)
        description = @"Requested file not found or couldn't be opened.";
    else if (code == 415)
        description = @"Wrong media format.";
    else if (code == 418)
        description = @"I'm a teapot!";
    else if (code == 500)
        description = @"An internal server error occurred when requesting the file.";
    else if (code == 502)
        description = @"Bad Gateway.";
    else if (code == 503)
        description = @"Service currently unavailable.";
    else 
        description = @"An unknown error ocurred.";
    
    return [self errorWithLocalizedDescription:description code:code];
}

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkRequest
@synthesize timeoutInterval = _timeoutInterval;
@synthesize completionHandler = _completionHandler;
@synthesize responseHandler = _responseHandler;
@synthesize errorHandler = _errorHandler;
@synthesize progressHandler = _progressHandler;
@synthesize requestMethod = _requestMethod;
@synthesize expirationHandler = _expirationHandler;
@synthesize taskIdentifier = _taskIdentifier;
@synthesize continueInBackground = _continueInBackground;
@synthesize loadWhileScrolling = _loadWhileScrolling;
@synthesize showNetworkIndicator = _showNetworkIndicator;
@synthesize _connection;
@synthesize _url;
@synthesize _downloadedData;
@synthesize _downloadedContentLength;
@synthesize _expectedContentLength;
@synthesize _headerFields;
@synthesize _queryValues;

#pragma mark Init

+ (id)requestWithURL:(NSURL *)url {
    id request = [[self alloc] initWithURL:url];
    return request;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        [NSURLCache setSharedURLCache:nil];

        self._url = url;
        self.timeoutInterval = 60.0f;
        self.requestMethod = GCNetworkRequestMethodGET;
        self.continueInBackground = NO;
        self.loadWhileScrolling = NO;
        self.showNetworkIndicator = YES;
        
        self._headerFields = [NSMutableDictionary dictionary];
        self._queryValues = [NSMutableDictionary dictionary];
    }  
    
    return self;
}

#pragma mark Start/Cancel

- (void)start {
    if (_requestFlags.started)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSLock *lock = [[NSLock alloc] init];
        [lock lock];
        NSMutableURLRequest *request = [self _buildRequest];
        [lock unlock];
        
        self._connection = [[NSURLConnection alloc] initWithRequest:request 
                                                           delegate:self
                                                   startImmediately:NO];
        
        if (!self._connection) {
            NSError *internalError = [GCNetworkRequest errorWithLocalizedDescription:@"Internal error" code:100];
            [self connection:self._connection didFailWithError:internalError];
            
            return;
        }
        
        if (self.continueInBackground) {
            UIApplication *app = [UIApplication sharedApplication];
            __weak GCNetworkRequest *weakReference = self;
            self.taskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{                 
                if (weakReference.expirationHandler)
                    weakReference.expirationHandler();
            }];
        }
        
        if (self.loadWhileScrolling)
            [self._connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        else
            [self._connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self willChangeValueForKey:@"isRunning"];
        _requestFlags.started = YES;
        _requestFlags.finished = NO;
        [self didChangeValueForKey:@"isRunning"];
        
        self._downloadedContentLength = 0;
        
        if (self.showNetworkIndicator)
            [GCNetworkCenter addNetworkActivity];
        
        if (self.progressHandler)
            self.progressHandler(0.0f);
        
        [self._connection start];
    });
}

- (void)cancel {
    [self._connection performSelector:@selector(cancel) withObject:nil afterDelay:0.0001];
    
    if (_requestFlags.finished)
        return;
    
    NSError *userCancelled = [GCNetworkRequest userCancellationError];
    [self connection:self._connection didFailWithError:userCancelled];
}

#pragma mark Helper

- (NSURL *)_buildURL {
    NSMutableString *string = [[self._url absoluteString] mutableCopy];
    
    BOOL isFirstParam = YES;
    for (NSString *key in [self._queryValues allKeys]) {
        NSString *value = [self._queryValues objectForKey:key];
        if (isFirstParam) {
            isFirstParam = NO;
            [string appendFormat:@"?%@=%@", key, value];
        }
        else
            [string appendFormat:@"&%@=%@", key, value];
    }
    NSString *nonMutableString = [string copy];
    NSURL *url = [NSURL URLWithString:nonMutableString];

    return url;
}

- (NSMutableURLRequest *)_buildRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self _buildURL]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:self.timeoutInterval];  
    [self modifiedRequest:request];

    NSString *requestMethodString = nil;
    switch (self.requestMethod) {
        case GCNetworkRequestMethodGET: requestMethodString = @"GET"; break;
        case GCNetworkRequestMethodPOST: requestMethodString = @"POST"; break;
        case GCNetworkRequestMethodHEAD: requestMethodString = @"HEAD"; break;
        case GCNetworkRequestMethodDELETE: requestMethodString = @"DELETE"; break;
        case GCNetworkRequestMethodOPTIONS: requestMethodString = @"OPTIONS"; break;
        case GCNetworkRequestMethodTRACE: requestMethodString = @"TRACE"; break;
        case GCNetworkRequestMethodPUT: requestMethodString = @"PUT"; break;
        default: requestMethodString = @"GET"; break;
    }
    [request setHTTPMethod:requestMethodString];
        
    for (NSString *field in self._headerFields) {
        NSString *value = [self._headerFields objectForKey:field];
		[request setValue:value forHTTPHeaderField:field];
	}

    return request;
}

- (NSMutableURLRequest *)modifiedRequest:(NSMutableURLRequest *)request {    
    return request;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if (self.responseHandler)
        self.responseHandler(httpResponse);

    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode < 400) {
        self._downloadedData = [NSMutableData data];
        // To not use _expectedContentLenght is much safer
    }
    else {
        NSError *htmlError = [GCNetworkRequest htmlErrorForCode:statusCode];
        [self connection:self._connection didFailWithError:htmlError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {    
    [self._downloadedData appendData:data];
    self._downloadedContentLength += data.length;

    if (self._expectedContentLength == NSURLResponseUnknownLength)
        return;
    
    CGFloat progress = (float)self._downloadedContentLength / (float)self._expectedContentLength * 100;

    if (self.progressHandler)
        self.progressHandler(progress);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self._connection cancel];

    if (self.errorHandler)
        self.errorHandler(error);

    [self _cleanUp];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
    if (self.completionHandler)
        self.completionHandler(self._downloadedData); 
    
    [self _cleanUp];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

#pragma mark @properties

- (NSString *)requestHash {
    return [[self description] md5Hash];
}

- (NSURL *)baseURL {
    return self._url;
}

- (NSString *)urlHash {
    return [[[self _buildURL] absoluteString] md5Hash];
}

- (void)setContinueInBackground:(BOOL)_bool {    
    if (_bool && [[UIDevice currentDevice] isMultitaskingSupported])
        _continueInBackground = YES;
    else
        _continueInBackground = NO;
}

- (BOOL)isRunning {
    return _requestFlags.started;
}

#pragma mark HeaderFields

- (void)setHeaderValue:(NSString *)value forField:(NSString *)field {
    [self._headerFields setObject:value forKey:field];
}

- (NSString *)headerValueForField:(NSString *)field {
    return [self._headerFields objectForKey:field];
}

#pragma mark QueryValues

- (void)setQueryValue:(NSString *)value forKey:(NSString *)key {    
    [self._queryValues setObject:[value serializedString] forKey:key];
}

- (NSString *)queryValueForKey:(NSString *)key {
    return [self._queryValues objectForKey:key];
}

#pragma mark Memory

- (void)_cleanUp {
    if (self.continueInBackground) {
        if (self.taskIdentifier != UIBackgroundTaskInvalid) {            
            [[UIApplication sharedApplication] endBackgroundTask:self.taskIdentifier]; 
            self.taskIdentifier = UIBackgroundTaskInvalid;
        }
    }

    [self willChangeValueForKey:@"isRunning"];
    _requestFlags.finished = YES;
    _requestFlags.started = NO;
    [self didChangeValueForKey:@"isRunning"];
    
    if (self.showNetworkIndicator)
        [GCNetworkCenter removeNetworkActivity];
}

@end
