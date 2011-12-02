//
//  GCNetworkCenter.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <Foundation/Foundation.h>

extern NSString *const GCNetworkCenterConnectionDidChangeNotification;

typedef enum {
	GCNoConnection = 0,
	GCWiFiConnection = 1,
    GCWWANConnection = 2,
    GCUnknownConnection = 3
} GCNetworkCenterConnectionType;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkCenter
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkCenter : NSObject 

@property (nonatomic, assign, getter = isListening) BOOL listen;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, readonly) GCNetworkCenterConnectionType connectionType;

/* Singleton */
+ (GCNetworkCenter *)defaultCenter;

/* Check if a host is reachable */
+ (BOOL)hostIsReachable:(NSString *)host;

/* Statusbar network indicator handling */
+ (void)addNetworkActivity;
+ (void)removeNetworkActivity;

@end
