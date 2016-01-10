//
//  ViewControllerPhone.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import "ViewControllerPhone.h"

#import "DiagramViewController.h"
#import "SearchViewController.h"
#import "VideoViewController.h"
#import "HistoryViewController.h"
//#import "AboutViewController.h"
#import "NZSL_Dict-Swift.h"

@interface ViewControllerPhone ()

@end

@implementation ViewControllerPhone {
    SearchViewController *searchController;
    DiagramViewController *diagramController;
    VideoViewController *videoController;
    HistoryViewController *historyController;
    UIViewController *aboutController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.viewControllers = @[
        searchController = [[SearchViewController alloc] init],
        diagramController = [[DiagramViewController alloc] init],
        videoController = [[VideoViewController alloc] init],
        historyController = [[HistoryViewController alloc] init],
        aboutController = [[AboutViewController alloc] init],
    ];
    searchController.delegate = self;
    diagramController.delegate = self;
    videoController.delegate = self;
    historyController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait
        || UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)returnToSearchView
{
    self.selectedViewController = searchController;
}

- (void)didSelectEntry:(DictEntry *)entry
{
    self.selectedViewController = diagramController;
}

@end
