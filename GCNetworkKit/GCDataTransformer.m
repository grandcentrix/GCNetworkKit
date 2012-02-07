//
//  GCDataTransformer.m
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

#import "GCDataTransformer.h"

#pragma mark JSON -> NSObject

void TransformJSONDataToNSObject(NSData *data, void (^callback)(id object, NSError *error)) {
    if (!callback)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        id object = nil;
        NSError *error = nil;
        
        object = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            callback(object, error);
        });
    });
}

#pragma mark NSData -> NSString

void TransformNSDataToNSString(NSData *data, NSStringEncoding encoding, void (^callback)(NSString *string)) {
    if (!callback)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            callback(string);
        });
    });
}

#pragma mark NSData -> UIImage

void TransformNSDataToUIImage(NSData *data, void (^callback)(UIImage *image)) {
    if (!callback)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            callback(image);
        });
        
    }); 
}

#pragma mark Plist -> Data

extern void TransformPlistDataToNSObject(NSData *data, void (^callback)(id object, NSError *error)) {
    if (!callback)
        return; 
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *errorString = nil;
        NSError *error = nil;
        id object = [NSPropertyListSerialization propertyListFromData:data
                                                     mutabilityOption:NSPropertyListImmutable
                                                               format:nil
                                                     errorDescription:&errorString];
        if (errorString)
            error = [NSError errorWithDomain:errorString code:898 userInfo:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(object, error);
        });
    });

}
