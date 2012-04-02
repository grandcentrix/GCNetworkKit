//
//  GCDataTransformer.h
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

#import <Foundation/Foundation.h>

// Transform JSON data to a foundation object (NSArray, NSDictionary ...)
extern void TransformJSONDataToNSObject(NSData *data, void (^callback)(id object, NSError *error));

// Transform raw data to a NSString
extern void TransformNSDataToNSString(NSData *data, NSStringEncoding encoding, void (^callback)(NSString *string));

// Transform raw data to an UIImage
extern void TransformNSDataToImage(NSData *data, void (^callback)(id image));

// Transform plist data to a foundation object (NSArray, NSDictionary ...)
extern void TransformPlistDataToNSObject(NSData *data, void (^callback)(id object, NSError *error));