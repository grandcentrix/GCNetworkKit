//
//  GCNetworkFormRequest.m
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

#import "GCNetworkFormRequest.h"
#import "NSString+GCNetworkRequest.h"
#import "GCNetworkKit.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkFormRequest()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkFormRequest()

@property (nonatomic, strong, readwrite) NSOutputStream *_tmpFileWriterStream;
@property (nonatomic, strong, readwrite) NSOperationQueue *_writeQueue;
@property (nonatomic, strong, readwrite) NSString *_tmpPath;
@property (nonatomic, strong, readonly) NSString *_formattedBoundary;
@property (nonatomic, strong, readonly) NSString *_htmlBoundary;
@property (nonatomic, readwrite, getter = _isFirstBoundary) BOOL _firstBoundary;
@property (nonatomic, readwrite) BOOL _cancelled;

- (void)_appendBodyString:(NSString *)string;
- (void)_addPartWithString:(NSString *)string forKey:(NSString *)key;
- (void)_addPartWithData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type andName:(NSString *)name;
- (void)_addPartWithFilePath:(NSString *)path forKey:(NSString *)key andName:(NSString *)name;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkFormRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkFormRequest
@synthesize _tmpFileWriterStream;
@synthesize _tmpPath;
@synthesize _firstBoundary;
@synthesize _formattedBoundary;
@synthesize _writeQueue;
@synthesize _cancelled;
@synthesize _htmlBoundary = __htmlBoundary;
@synthesize uploadProgressHandler = _uploadProgressHandler;

#pragma mark Init

- (id)initWithURL:(NSURL *)url {
    if ((self = [super initWithURL:url])) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        NSString *extension = @"GCNetworkFormRequest";
        NSString *bodyFileName = [(__bridge NSString *)uuidStr stringByAppendingPathExtension:extension];
        CFRelease(uuidStr);
        CFRelease(uuid);        

        self._writeQueue = [NSOperationQueue new];
        [self._writeQueue setMaxConcurrentOperationCount:1];
        
        self._tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:bodyFileName];      
        self._tmpFileWriterStream = [NSOutputStream outputStreamToFileAtPath:self._tmpPath
                                                                      append:YES];
        [self._tmpFileWriterStream open];
    }
    
    return self;
}
   
#pragma mark Start

- (void)cancel {
    [super cancel];
    
    [self._writeQueue cancelAllOperations];
    self._cancelled = YES;
}

- (void)start {
    self._cancelled = NO;

    __GC_weak GCNetworkFormRequest *weakReference = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self._writeQueue waitUntilAllOperationsAreFinished];

        if (weakReference._cancelled)
            return;
        
        [super start];
    });
}

#pragma mark Helper

- (NSString *)_formattedBoundary {
    if (self._isFirstBoundary) {
        self._firstBoundary = NO;
        
        return [NSString stringWithFormat:@"--%@\r\n", self._htmlBoundary];
    }
    
    return [NSString stringWithFormat:@"\r\n--%@\r\n", self._htmlBoundary];
}

- (void)_appendBodyString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self._tmpFileWriterStream write:[data bytes] maxLength:[data length]];
}

#pragma mark Strings

- (void)addPostString:(NSString *)string forKey:(NSString *)key {    
    [self _addPartWithString:string forKey:key];
}

- (void)_addPartWithString:(NSString *)string forKey:(NSString *)key {
    
    if (!string || [string isEmpty] || !key)
        return;
    
    __GC_weak GCNetworkFormRequest *weakReference = self;

    [self._writeQueue addOperationWithBlock:^{
        [weakReference _appendBodyString:weakReference._formattedBoundary];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]];
        [weakReference _appendBodyString:string];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Just so the operation doesn`t count as finished. 
        });
    }];
}

#pragma mark Files

- (void)addFile:(NSString *)path forKey:(NSString *)key {
    NSString *name = [NSString stringWithFormat:@"%d-%@", [[[NSDate date] description] hash], [path lastPathComponent]];
    [self addFile:path
           forKey:key
          andName:name];
}

- (void)addFile:(NSString *)path forKey:(NSString *)key andName:(NSString *)name {    
    NSString *extension = [[[path lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:1];
    name = [NSString stringWithFormat:@"%@.%@", name, extension];
    
    [self _addPartWithFilePath:path
                        forKey:key
                       andName:name];
}

- (void)_addPartWithFilePath:(NSString *)path forKey:(NSString *)key andName:(NSString *)name {

    if (!path || [path isEmpty] || !key)
        return;
    
    __GC_weak GCNetworkFormRequest *weakReference = self;
    
    [self._writeQueue addOperationWithBlock:^{
        NSString *contentType = [[path pathExtension] mimeType];

        [weakReference _appendBodyString:weakReference._formattedBoundary];
        [weakReference _appendBodyString:@"Content-Disposition: form-data; "];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"name=\"%@\"; ", key]];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"filename=\"%@\"\r\n", name]];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType]];
        
        NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        NSData *readData;
        while ((readData = [readFileHandle readDataOfLength:1024 * 10]) != nil && [readData length] > 0)
            [weakReference._tmpFileWriterStream write:[readData bytes] maxLength:[readData length]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Just so the operation doesn`t count as finished. 
        });
    }];
}

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
#pragma mark Data
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

- (void)addData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type {
    NSString *name = [NSString stringWithFormat:@"MyFile.%@", [[type componentsSeparatedByString:@"/"] objectAtIndex:1]];
    [self addData:data
           forKey:key
      contentType:type
          andName:name];
}

- (void)addData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type andName:(NSString *)name {
    if ([type isEmpty])
        type = @"application/octet-stream";
    
    name = [NSString stringWithFormat:@"%@.%@", name, [[type componentsSeparatedByString:@"/"] objectAtIndex:1]];
    [self _addPartWithData:data
                    forKey:key
               contentType:type
                   andName:name];
}

- (void)_addPartWithData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type andName:(NSString *)name {  
    
    if (!data || !key)
        return;
    
    __GC_weak GCNetworkFormRequest *weakReference = self;

    [self._writeQueue addOperationWithBlock:^{
        [weakReference _appendBodyString:weakReference._formattedBoundary];
        [weakReference _appendBodyString:@"Content-Disposition: form-data; "];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"name=\"%@\"; ", key]];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"filename=\"%@\"\r\n", name]];
        [weakReference _appendBodyString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", type]];
        
        NSInteger       dataLength;
        const uint8_t * dataBytes;
        NSInteger       bytesWritten;
        NSInteger       bytesWrittenSoFar;
        
        dataLength = [data length];
        dataBytes  = [data bytes];
        
        bytesWrittenSoFar = 0;
        
        do { 
            bytesWritten = [weakReference._tmpFileWriterStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            bytesWrittenSoFar += bytesWritten;
        } while (bytesWrittenSoFar != dataLength);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
           // Just so the operation doesn`t count as finished. 
        });
    }];
}

#pragma mark @properties

- (NSString *)_htmlBoundary {
    if (__htmlBoundary)
        return __htmlBoundary;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    unichar randomLetter1 = random() % 26 + 65;
    unichar randomLetter2 = random() % 26 + 65;
    __htmlBoundary = [[NSString stringWithFormat:@"%c_%d_%c", randomLetter1, interval, randomLetter2] md5Hash];
    __htmlBoundary = [NSString stringWithFormat:@"htmlBoundaryStart%@htmlBoundaryEnd", __htmlBoundary];

    return __htmlBoundary;
}

- (void)setRequestMethod:(GCNetworkRequestMethod)requestMethod {
    return;
}

- (GCNetworkRequestMethod)requestMethod {
    return GCNetworkRequestMethodPOST;
}

- (void)setHeaderValue:(NSString *)value forField:(NSString *)field {
    if ([field isEqualToString:@"Content-Type"] || [field isEqualToString:@"Content-Length"])
        return;
    
    [super setHeaderValue:value forField:field];
}

#pragma mark GCNetworkRequest

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite > 0) {
        CGFloat progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (totalBytesExpectedToWrite <= totalBytesWritten)
            progress = 1.0f;
        
        if (self.uploadProgressHandler)
            self.uploadProgressHandler(progress);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError {
    [[NSFileManager defaultManager] removeItemAtPath:self._tmpPath error:nil];
    
    [super connection:connection didFailWithError:anError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSFileManager defaultManager] removeItemAtPath:self._tmpPath error:nil];

    [super connectionDidFinishLoading:connection];
}

- (NSMutableURLRequest *)modifiedRequest:(NSMutableURLRequest *)request {
    [self _appendBodyString:[NSString stringWithFormat:@"\r\n--%@--\r\n", self._htmlBoundary]];
    
    [self._tmpFileWriterStream close];
    self._tmpFileWriterStream = nil;
    [request setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:self._tmpPath]];

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self._tmpPath error:nil];
    NSInteger size = [[fileAttributes objectForKey:NSFileSize] intValue];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self._htmlBoundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", size] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];

    return request;
}

#pragma mark Memory

- (void)dealloc {
    [self._tmpFileWriterStream close];
}

@end
