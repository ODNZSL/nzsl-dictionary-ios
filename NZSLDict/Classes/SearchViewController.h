//
//  SearchViewController.h
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import <UIKit/UIKit.h>

#import "SignsDictionary.h"

@protocol SearchViewControllerDelegate <NSObject>

- (void)didSelectEntry:(DictEntry *)entry;

@end

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property id<SearchViewControllerDelegate> delegate;

@end
