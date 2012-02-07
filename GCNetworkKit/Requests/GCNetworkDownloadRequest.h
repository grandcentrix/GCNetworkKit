//
//  GCNetworkDownloadRequest.h
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

#import "GCNetworkRequest.h"

typedef void (^GCNetworkDownloadRequestCompletionBlock)(NSString *filePath);

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkDownloadRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkDownloadRequest : GCNetworkRequest

@property (nonatomic, copy, readwrite) GCNetworkDownloadRequestCompletionBlock downloadCompletionHandler;

/* Default is YES. Auto deletes temorary downloaded file after callback is done */
@property (nonatomic, readwrite) BOOL autoDeleteTMPFile;

- (void)deleteTMPFile;

@end
