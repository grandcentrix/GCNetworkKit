//
//  NSString+GCNetworkRequest.m
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import "NSString+GCNetworkRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/UTType.h>
#import <CommonCrypto/CommonHMAC.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (Validation)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation NSString (Validation)

- (BOOL)isEmpty {
    if ([self isEqualToString:@""] || self.length <= 0)
        return YES;
    
    return NO;
}

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (HTTP)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation NSString (HTTP)

#pragma mark Serialization

- (NSString *)serializedString {
    NSString *escaped_value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (__bridge_retained CFStringRef)self,
                                                                                  NULL,
                                                                                  (__bridge_retained CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8);
    return escaped_value;
}

#pragma mark MimeType

- (NSString *)mimeType {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge_retained  CFStringRef)self, NULL);
    if (uti != NULL) {
        CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        if (mime != NULL) {
            NSString *type = [NSString stringWithString:(__bridge_transfer NSString *)mime];
            CFRelease(mime);
            return type;
        }
    }
    
    return @"application/octet-stream";
}

@end

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//  NSString (Crypto)
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@implementation NSString (Crypto)

- (NSString *)md5Hash {
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return [output copy];
}

@end
