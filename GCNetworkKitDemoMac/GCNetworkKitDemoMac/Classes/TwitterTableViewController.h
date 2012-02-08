//
//  TwitterTableViewController.h
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//
//  Copyright 2012 Alex Zielenski, Guilio Petek
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

#import <Cocoa/Cocoa.h>

@interface TwitterTableViewController : NSViewController
@property (nonatomic, assign, readwrite) IBOutlet NSTableView *tableView;
@property (nonatomic, retain, readwrite) NSMutableArray *tweets;
@property (nonatomic, retain, readwrite) NSString *requestHash;
- (void)viewWillLoad;
- (void)viewDidLoad;

- (void)loadTweets;
- (void)cancelLoadingTweets;
- (void)proceedTweets:(NSData *)data;

+ (void)uploadImage:(NSImage *)image username:(NSString *)username andPassword:(NSString *)password;
+ (void)downloadPodcastAtURL:(NSURL *)url;
+ (void)loadImageAtURL:(NSURL *)url;
+ (void)shortenURL:(NSURL *)url;
@end
