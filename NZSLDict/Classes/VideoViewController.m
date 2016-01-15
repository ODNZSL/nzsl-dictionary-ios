//
//  VideoViewController.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import "VideoViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"
#import "Dictionary.h"
#import "NZSLDict-Swift.h"

@interface VideoViewController ()

@end

@implementation VideoViewController {
    DictEntry *currentEntry;
    UISearchBar *searchBar;
    DetailView *detailView;
    UIView *videoBack;
    UIActivityIndicatorView *activity;
    MPMoviePlayerController *player;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Video" image:[UIImage imageNamed:@"movie"] tag:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEntry:) name:EntrySelectedName object:nil];
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
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, top_offset, view.bounds.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.delegate = self;
    [view addSubview:searchBar];
    
    detailView = [[DetailView alloc] initWithFrame:CGRectMake(0, top_offset+44, view.bounds.size.width, DetailView.height)];
    detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view addSubview:detailView];
    
    videoBack = [[UIView alloc] initWithFrame:CGRectMake(0, top_offset+44+DetailView.height, view.bounds.size.width, view.bounds.size.height-(top_offset+44+DetailView.height))];
    videoBack.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:videoBack];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showCurrentEntry];
}

- (void)showEntry:(NSNotification *)notification
{
    currentEntry = notification.userInfo[@"entry"];
    player = nil;
}

- (void)showCurrentEntry
{
    searchBar.text = currentEntry.gloss;
    [detailView showEntry:currentEntry];
    [self performSelector:@selector(startVideo) withObject:nil afterDelay:0];
}

- (void)startVideo
{
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:currentEntry.video]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player prepareToPlay];
    [player.view setFrame:videoBack.bounds];
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [videoBack addSubview:player.view];
    [player play];

    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [videoBack addSubview:activity];
    activity.frame = CGRectOffset(activity.frame,
        (videoBack.bounds.size.width - activity.bounds.size.width) / 2,
        (videoBack.bounds.size.height - activity.bounds.size.height) / 2);
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

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.delegate returnToSearchView];
    return NO;
}

@end
