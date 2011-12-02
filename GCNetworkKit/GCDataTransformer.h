//
//  GCDataTransformer.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

/* Transform JSON data to a foundation object (NSArray, NSDictionary ...) */
extern void TransformJSONDataToNSObject(NSData *data, void (^callback)(id object, NSError *error));

/* Transform raw data to a NSString */
extern void TransformNSDataToNSString(NSData *data, NSStringEncoding encoding, void (^callback)(NSString *string));

/* Transform raw data to an UIImage */
extern void TransformNSDataToUIImage(NSData *data, void (^callback)(UIImage *image));

/* Transform plist data to a foundation object (NSArray, NSDictionary ...) */
extern void TransformPlistDataToNSObject(NSData *data, void (^callback)(id object, NSError *error));