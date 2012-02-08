//
//  GCTableCellView.m
//
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
//
//  Copyright 2012 Alex Zielenski
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

#import "GCTableCellView.h"

@implementation GCTableCellView
@synthesize detailTextLabel = _detailTextLabel;
- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
	static NSColor *labelColor;
	labelColor = [NSColor colorWithDeviceWhite:0.3 alpha:1.0];
	
	[super setBackgroundStyle:backgroundStyle];
	if (backgroundStyle == NSBackgroundStyleLight) {
		[self.detailTextLabel setTextColor:labelColor];
	} else if (backgroundStyle == NSBackgroundStyleDark) {
		[self.detailTextLabel setTextColor:[NSColor whiteColor]]; // cached internally

	}
}
@end
