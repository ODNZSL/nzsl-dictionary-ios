//
//  AppDelegate.h
//  NZSLDict
//
//  Created by Greg Hewgill on 16/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS7() SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

#define EntrySelectedName @"EntrySelected"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
