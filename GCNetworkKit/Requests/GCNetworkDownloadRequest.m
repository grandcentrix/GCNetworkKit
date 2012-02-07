//
//  GCNetworkDownloadRequest.m
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

#import "GCNetworkDownloadRequest.h"

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkDownloadRequest()
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkDownloadRequest ()

@property (nonatomic, strong, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *_fileStream;
@property (nonatomic, readwrite) long long _downloadedContentLength;
@property (nonatomic, readwrite) long long _expectedContentLength;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkDownloadRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation GCNetworkDownloadRequest
@synthesize filePath = _filePath;
@synthesize autoDeleteTMPFile = _autoDeleteTMPFile;
@synthesize downloadCompletionHandler = _downloadCompletionHandler;
@synthesize _downloadedContentLength;
@synthesize _expectedContentLength;
@synthesize _fileStream;

#pragma mark Init

+ (id)requestWithURL:(NSURL *)anUrl {
    id request = [[self alloc] initWithURL:anUrl];
    return request;
}

- (id)initWithURL:(NSURL *)anUrl {
    if ((self = [super initWithURL:anUrl]))
        self.autoDeleteTMPFile = YES;
    
    return self;
}

#pragma mark Delete

- (void)deleteTMPFile {
    __block GCNetworkDownloadRequest *blockSelf = self; // __weak does not work here. It`s zeroing the reference to early.
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSFileManager *manager = [[NSFileManager alloc] init];
        
        NSError *error = nil;
        [manager removeItemAtPath:blockSelf.filePath error:&error];
    
        if (error && [manager fileExistsAtPath:blockSelf.filePath]) {
            [manager createFileAtPath:blockSelf.filePath contents:[NSData data] attributes:nil];
            [manager removeItemAtPath:blockSelf.filePath error:nil];
        }
    });
 }

#pragma mark NSURLConectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    [super connection:connection didReceiveResponse:aResponse];
    
    self.filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(), [aResponse suggestedFilename]];
    self._expectedContentLength = [(NSHTTPURLResponse *)aResponse expectedContentLength];
    self._downloadedContentLength = 0;
    
    self._fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
    [self._fileStream open];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    
    do {
        bytesWritten = [self._fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        if (bytesWritten == -1) {
            NSError *writeError = [NSError errorWithDomain:GCNetworkRequestErrorDomain
                                                      code:007
                                                  userInfo:[NSDictionary dictionaryWithObject:@"NSOutputStream writing error." forKey:NSLocalizedDescriptionKey]];
            [self connection:connection didFailWithError:writeError];
            break;
        } else
            bytesWrittenSoFar += bytesWritten;
    } while (bytesWrittenSoFar != dataLength);
    
    self._downloadedContentLength += data.length;

    if (self._expectedContentLength == NSURLResponseUnknownLength)
        return;
    
    CGFloat progress = (float)self._downloadedContentLength / (float)self._expectedContentLength * 100;
    if (self.progressHandler)
        self.progressHandler(progress);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError {   
    [super connection:connection didFailWithError:anError];
    
    [self._fileStream close];
    self._fileStream = nil;
    
    if (self.autoDeleteTMPFile)
        [self deleteTMPFile];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self._fileStream close];
    self._fileStream = nil;

    __block GCNetworkDownloadRequest *blockSelf = self; // __weak does not work here. It`s zeroing the reference to early.

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (blockSelf.downloadCompletionHandler)
                blockSelf.downloadCompletionHandler(blockSelf.filePath);
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            if (blockSelf.autoDeleteTMPFile)
                [blockSelf deleteTMPFile];
        });
    });
    
    [self performSelector:@selector(_cleanUp)];
}

@end
