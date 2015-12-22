//
//  HistoryViewController.h
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import <UIKit/UIKit.h>

#import "SearchViewController.h"

@interface HistoryViewController : UITableViewController

@property id<SearchViewControllerDelegate> delegate;

@end
