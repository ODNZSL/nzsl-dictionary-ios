//
//  ViewControllerPad.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 27/04/13.
//
//

#import "ViewControllerPad.h"

#import "DetailViewController.h"
#import "DiagramViewController.h"
#import "SearchViewController.h"
#import "VideoViewController.h"
#import "HistoryViewController.h"
#import "AboutViewController.h"

@interface ViewControllerPad ()

@end

@implementation ViewControllerPad {
    SearchViewController *searchController;
    HistoryViewController *historyController;
    DetailViewController *detailViewController;
    UIViewController *diagramController;
    UIViewController *videoController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarController *tabbar = [[UITabBarController alloc] init];
        tabbar.viewControllers = @[
            searchController = [[SearchViewController alloc] init],
            historyController = [[HistoryViewController alloc] init],
        ];
        self.viewControllers = @[
            tabbar,
            detailViewController = [[DetailViewController alloc] init],
        ];
        self.delegate = detailViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
