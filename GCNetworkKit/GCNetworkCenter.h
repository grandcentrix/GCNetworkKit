//
//  GCNetworkCenter.h
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

extern NSString *const GCNetworkCenterConnectionDidChangeNotification;

typedef enum {
	GCNoConnection = 0, // No internet connection available.
	GCWiFiConnection = 1, // WiFi connection available.
    GCWWANConnection = 2, // Carrier connection available (3g etc.)
    GCUnknownConnection = 3
} GCNetworkCenterConnectionType;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// GCNetworkCenter
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface GCNetworkCenter : NSObject 

@property (nonatomic, assign, getter = isListening) BOOL listen;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, readonly) GCNetworkCenterConnectionType connectionType;

+ (GCNetworkCenter *)defaultCenter;

+ (BOOL)hostIsReachable:(NSString *)host;

// Statusbar network indicator handling.
+ (void)addNetworkActivity;
+ (void)removeNetworkActivity;

@end
