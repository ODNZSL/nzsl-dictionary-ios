//
//  AboutViewController.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 29/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

#import "AppDelegate.h"

@interface AboutViewController ()

@end

@implementation AboutViewController {
    UIWebView *webView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"About" image:[UIImage imageNamed:@"info"] tag:0];
    }
    return self;
}

- (void)loadView
{
    webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (IOS7() && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        webView.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    webView.delegate = self;
    self.view = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about.html" ofType:nil]]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL isFileURL]) {
        return YES;
    }
    if ([request.URL.scheme isEqualToString:@"follow"]) {
        [self openTwitterClientForUserName:@"NZSLDict"];
        return NO;
    }
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
}

// https://gist.github.com/vhbit/958738
- (BOOL)openTwitterClientForUserName:(NSString*)userName {
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter:@{username}", // Twitter
                     @"tweetbot:///user_profile/{username}", // TweetBot
                     @"echofon:///user_timeline?{username}", // Echofon              
                     @"twit:///user?screen_name={username}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={username}", // Seesmic
                     @"x-birdfeed://user?screen_name={username}", // Birdfeed
                     @"tweetings:///user?screen_name={username}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{username}", // SimplyTweet
                     @"icebird://user?screen_name={username}", // IceBird
                     @"fluttr://user/{username}", // Fluttr
                     /** uncomment if you don't have a special handling for no registered twitter clients */
                     @"http://twitter.com/{username}", // Web fallback, 
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{username}" withString:userName]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            return YES;
        }
    }
    return NO;
}

@end
