//
//  VideoViewController.h
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import <UIKit/UIKit.h>

#import "ViewControllerPhone.h"

@interface VideoViewController : UIViewController <UISearchBarDelegate>

@property id<ViewControllerDelegate> delegate;

@end
