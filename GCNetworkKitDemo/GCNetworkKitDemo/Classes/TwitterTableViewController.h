//
//  TwitterTableViewController.h
//
//  Created by Giulio Petek on 11.09.11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

#import <UIKit/UIKit.h>

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
// TwitterTableViewController
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

@interface TwitterTableViewController : UITableViewController

@property (nonatomic, retain, readwrite) NSMutableArray *tweets;
@property (nonatomic, retain, readwrite) NSString *requestHash;

- (void)loadTweets;
- (void)cancelLoadingTweets;
- (void)proceedTweets:(NSData *)data;

+ (void)uploadImage:(UIImage *)image username:(NSString *)username andPassword:(NSString *)password;
+ (void)downloadPodcastAtURL:(NSURL *)url;
+ (void)loadImageAtURL:(NSURL *)url;
+ (void)shortenURL:(NSURL *)url;

@end
