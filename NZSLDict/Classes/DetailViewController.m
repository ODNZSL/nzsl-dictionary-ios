//
//  DetailViewController.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 28/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"
#import "AboutViewController.h"
#import "DiagramView.h"
#import "Dictionary.h"
#import "NZSLDict-Swift.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
{
    UINavigationBar *navigationBar;
    DiagramView *diagramView;
    UIView *videoView;
    UINavigationItem *navigationTitle;
    DictEntry *currentEntry;
    MPMoviePlayerController *player;
    UIActivityIndicatorView *activity;
    UIPopoverController *aboutPopoverController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEntry:) name:EntrySelectedName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    float top_offset = IOS7() ? 20 : 0;
    
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, top_offset, view.bounds.size.width, 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navigationBar.delegate = self;
    [view addSubview:navigationBar];
    
    diagramView = [[DiagramView alloc] initWithFrame:CGRectMake(0, top_offset+44, view.bounds.size.width, view.bounds.size.height/2)];
    diagramView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:diagramView];
    
    videoView = [[UIView alloc] initWithFrame:CGRectMake(0, top_offset+44+view.bounds.size.height/2, view.bounds.size.width, view.bounds.size.height - (top_offset+44+view.bounds.size.height/2))];
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    videoView.backgroundColor = [UIColor blackColor];
    [view addSubview:videoView];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playButton.frame = CGRectMake((videoView.bounds.size.width-100)/2, (videoView.bounds.size.height-40)/2, 100, 40);
    playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [playButton setTitle:@"Play Video" forState:UIControlStateNormal];
    playButton.titleLabel.textColor = [UIColor blackColor];
    [playButton addTarget:self action:@selector(startPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [videoView addSubview:playButton];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    navigationTitle = [[UINavigationItem alloc] initWithTitle:@""];
    [navigationTitle setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(showAbout:)]];
    [navigationBar setItems:[NSArray arrayWithObjects:navigationTitle, nil] animated:NO];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [player.view setFrame:videoView.bounds];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)showEntry:(NSNotification *)notification
{
    currentEntry = notification.userInfo[@"entry"];
    navigationTitle.title = currentEntry.gloss;
    [diagramView showEntry:currentEntry];
    [player.view removeFromSuperview];
    player = nil;
}

- (IBAction)startPlayer:(id)sender
{
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:currentEntry.video]];
    [player prepareToPlay];
    [player.view setFrame:videoView.bounds];
    [videoView addSubview:player.view];
    [player play];

    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [videoView addSubview:activity];
    activity.frame = CGRectOffset(activity.frame,
        (CGRectGetWidth(videoView.bounds) - CGRectGetWidth(activity.bounds)) / 2,
        (CGRectGetHeight(videoView.bounds) - CGRectGetHeight(activity.bounds)) / 2);
    [activity startAnimating];
}

- (void)playerPlaybackStateDidChange:(NSNotification *)notification
{
    [activity stopAnimating];
    [activity removeFromSuperview];
    activity = nil;
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification
{
    MPMovieFinishReason r = [[notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    //NSLog(@"here %d", r);
    if (r == MPMovieFinishReasonPlaybackError) {
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Network access required"
            message:@"Playing videos requires access to the Internet."
            delegate:nil
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showAbout:(id)sender
{
    if (!aboutPopoverController) {
        AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        aboutPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    }
    if ([aboutPopoverController isPopoverVisible]) {
        [aboutPopoverController dismissPopoverAnimated:YES];
    } else {
        [aboutPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

@end
