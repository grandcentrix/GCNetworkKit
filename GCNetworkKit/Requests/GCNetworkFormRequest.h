//
//  GCNetworkFormRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
