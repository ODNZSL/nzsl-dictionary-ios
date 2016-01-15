//
//  DiagramViewController.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import "DiagramViewController.h"

#import "AppDelegate.h"
#import "Dictionary.h"
#import "DiagramView.h"
#import "NZSLDict-Swift.h"

@interface DiagramViewController ()

@end

@implementation DiagramViewController {
    DictEntry *currentEntry;
    UISearchBar *searchBar;
    DiagramView *diagramView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Diagram" image:[UIImage imageNamed:@"hands"] tag:0];
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
    
    diagramView = [[DiagramView alloc] initWithFrame:CGRectMake(0, top_offset+44, view.bounds.size.width, view.bounds.size.height-(top_offset+44))];
    [view addSubview:diagramView];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [self showCurrentEntry];
}

- (void)showEntry:(NSNotification *)notification
{
    currentEntry = notification.userInfo[@"entry"];
    if (diagramView == nil) {
        return;
    }
    [self showCurrentEntry];
}

- (void)showCurrentEntry
{
    searchBar.text = currentEntry.gloss;
    [diagramView showEntry:currentEntry];
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
