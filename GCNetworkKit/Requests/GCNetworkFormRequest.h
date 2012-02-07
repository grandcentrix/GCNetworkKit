//
//  GCNetworkFormRequest.h
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

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkFormRequest
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkFormRequest : GCNetworkRequest

@property (nonatomic, copy, readwrite) GCNetworkRequestProgressBlock uploadProgressHandler;

/* Add post data */
- (void)addPostString:(NSString *)string forKey:(NSString *)key;
- (void)addFile:(NSString *)filePath forKey:(NSString *)key;
- (void)addFile:(NSString *)path forKey:(NSString *)key andName:(NSString *)name;
- (void)addData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type;
- (void)addData:(NSData *)data forKey:(NSString *)key contentType:(NSString *)type andName:(NSString *)name;

@end
