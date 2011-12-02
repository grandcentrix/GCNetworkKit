//
//  GCNetworkDownloadRequest.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
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
