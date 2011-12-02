//
//  NSString+GCNetworkRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (Validation) 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface NSString (Validation)

@property (nonatomic, readonly, getter = isEmpty) BOOL empty;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (HTTP) 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface NSString (HTTP)

- (NSString *)serializedString;
- (NSString *)mimeType;

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (Crypto) 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface NSString (Crypto)

- (NSString *)md5Hash;

@end
