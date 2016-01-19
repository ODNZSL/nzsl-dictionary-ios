//
//  SearchViewController.m
//  NZSL Dict
//
//  Created by Greg Hewgill on 25/04/13.
//
//

#import "SearchViewController.h"

#import "AppDelegate.h"
#import "SignsDictionary.h"
#import "imageutil.h"

//#define LAUNCH_IMAGE

static NSString *HandshapeAnyCellIdentifier = @"CellAny";
static NSString *HandshapeIconCellIdentifier = @"CellIcon";

@interface SearchViewController ()

@end

@implementation SearchViewController {
    SignsDictionary *dict;
    DictEntry *wordOfTheDay;
    UISegmentedControl *modeSwitch;
    UISearchBar *searchBar;
    UITableView *searchTable;
    UIView *wotdView;
    UILabel *wotdLabel;
    UIImageView *wotdImageView;
    UIView *searchSelectorView;
    UICollectionView *handshapeSelector;
    UICollectionView *locationSelector;
    NSArray *searchResults;
    UISwipeGestureRecognizer *swipeRecognizer;
    BOOL subsequent_keyboard;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dispose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    float top_offset = IOS7() ? 20 : 0;
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, top_offset, view.bounds.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
#ifndef LAUNCH_IMAGE
    searchBar.placeholder = @"Enter Word";
#endif
    if (!IOS7()) {
        searchBar.showsCancelButton = YES;
    }
    searchBar.delegate = self;
    [view addSubview:searchBar];
    
    modeSwitch = [[UISegmentedControl alloc] initWithItems:@[@"Abc", [UIImage imageNamed:@"hands"]]];
    modeSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    modeSwitch.frame = CGRectMake(view.bounds.size.width - modeSwitch.bounds.size.width - 4, top_offset+6, modeSwitch.bounds.size.width, 32);
    modeSwitch.selectedSegmentIndex = 0;
    [modeSwitch addTarget:self action:@selector(selectSearchMode:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:modeSwitch];
    if (!IOS7()) {
        id appearance = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
        [appearance setTitle:@"XXXXXXXXX"];
    }
    
    searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, top_offset+44, view.bounds.size.width, view.bounds.size.height-(top_offset+44))];
    searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    searchTable.rowHeight = 50;
    searchTable.dataSource = self;
    searchTable.delegate = self;
    [view addSubview:searchTable];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    swipeRecognizer.delegate = self;
    [searchTable addGestureRecognizer:swipeRecognizer];
    
    wotdView = [[UIView alloc] initWithFrame:searchTable.frame];
    wotdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    wotdView.backgroundColor = [UIColor whiteColor];
    [view addSubview:wotdView];
    
    wotdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wotdView.bounds.size.width, 20)];
    wotdLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    wotdLabel.textAlignment = UITextAlignmentCenter;
    [wotdView addSubview:wotdLabel];
    
    wotdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, wotdView.bounds.size.width, wotdView.bounds.size.height-20)];
    wotdImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    wotdImageView.backgroundColor = [UIColor whiteColor];
    wotdImageView.contentMode = UIViewContentModeScaleAspectFit;
    wotdImageView.userInteractionEnabled = YES;
    [wotdImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectWotd:)]];
    [wotdView addSubview:wotdImageView];
    
    searchSelectorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 200)];
    searchSelectorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *handshapeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 20)];
    handshapeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    handshapeLabel.backgroundColor = [UIColor lightGrayColor];
    handshapeLabel.textColor = [UIColor whiteColor];
    handshapeLabel.shadowColor = [UIColor grayColor];
    handshapeLabel.shadowOffset = CGSizeMake(0, 1);
    handshapeLabel.font = [UIFont boldSystemFontOfSize:16];
    handshapeLabel.text = @"  Handshape";
    [searchSelectorView addSubview:handshapeLabel];
    
    UICollectionViewFlowLayout *hslayout = [[UICollectionViewFlowLayout alloc] init];
    hslayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    hslayout.itemSize = CGSizeMake(80, 80);
    handshapeSelector = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, view.bounds.size.width, 80) collectionViewLayout:hslayout];
    handshapeSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [handshapeSelector registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HandshapeAnyCellIdentifier];
    [handshapeSelector registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HandshapeIconCellIdentifier];
    handshapeSelector.backgroundColor = [UIColor whiteColor];
    handshapeSelector.scrollsToTop = NO;
    handshapeSelector.dataSource = self;
    handshapeSelector.delegate = self;
    [searchSelectorView addSubview:handshapeSelector];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, view.bounds.size.width, 20)];
    locationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    locationLabel.backgroundColor = [UIColor lightGrayColor];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.shadowColor = [UIColor grayColor];
    locationLabel.shadowOffset = CGSizeMake(0, 1);
    locationLabel.font = [UIFont boldSystemFontOfSize:16];
    locationLabel.text = @"  Location";
    [searchSelectorView addSubview:locationLabel];
    
    UICollectionViewFlowLayout *loclayout = [[UICollectionViewFlowLayout alloc] init];
    loclayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    loclayout.itemSize = CGSizeMake(80, 80);
    locationSelector = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 120, view.bounds.size.width, 80) collectionViewLayout:loclayout];
    locationSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [locationSelector registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HandshapeAnyCellIdentifier];
    [locationSelector registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HandshapeIconCellIdentifier];
    locationSelector.backgroundColor = [UIColor whiteColor];
    locationSelector.scrollsToTop = NO;
    locationSelector.dataSource = self;
    locationSelector.delegate = self;
    [searchSelectorView addSubview:locationSelector];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#ifndef LAUNCH_IMAGE
    dict = [[SignsDictionary alloc] initWithFile:@"nzsl.dat"];
    wordOfTheDay = [dict wordOfTheDay];
    if ([wotdLabel respondsToSelector:@selector(setAttributedText:)]) {
        // iOS 6 supports attributed text in labels
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:@"Word of the day: "];
        [as appendAttributedString:[[NSAttributedString alloc] initWithString:wordOfTheDay.gloss attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]}]];
        wotdLabel.attributedText = as;
    } else {
        wotdLabel.text = [NSString stringWithFormat:@"Word of the day: %@", wordOfTheDay.gloss];
    }
    wotdImageView.image = [UIImage imageNamed:wordOfTheDay.image];
    [self selectEntry:wordOfTheDay];
    [handshapeSelector selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
    [locationSelector selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
    [self selectSearchMode:modeSwitch];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shrinkSearchBar
{
    UIView *x = searchBar.subviews[0];
    /*for (UIView *v in x.subviews) {
        NSLog(@"%@", NSStringFromClass(v.class));
    }*/
    UIView *y = x.subviews[1];
    //NSLog(@"UISearchBarTextField %g,%g,%g,%g", y.frame.origin.x, y.frame.origin.y, y.frame.size.width, y.frame.size.height);
    y.frame = CGRectMake(y.frame.origin.x, y.frame.origin.y, x.frame.size.width-(y.frame.origin.x*2 + 100), y.frame.size.height);
}

- (void)viewDidLayoutSubviews
{
    if (IOS7()) {
        [self shrinkSearchBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (IOS7()) {
        [self shrinkSearchBar];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (IOS7()) {
        [self shrinkSearchBar];
    }
#ifndef LAUNCH_IMAGE
    if (modeSwitch.selectedSegmentIndex == 0 && searchBar.text.length == 0) {
        [searchBar becomeFirstResponder];
    }
#endif
}

- (void)adjustForKeyboard:(NSNotification *)notification
{
    NSValue *v = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect kr = [v CGRectValue];
    // This workaround avoids a problem when launching on the iPad in non-portrait mode.
    // On launch, the convertRect: call does not properly take into account the rotation
    // from device coordinates to interface coordinates. We seem to be able to detect
    // this when the following is true:
    UIInterfaceOrientation interface_orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation device_orientation = [UIDevice currentDevice].orientation;
    //NSLog(@"interface %d device %d", interface_orientation, device_orientation);
    BOOL fudge_rotation = (int)device_orientation != (int)interface_orientation;
    if (fudge_rotation) {
        //NSLog(@"before fudge %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
        CGRect screen = [UIScreen mainScreen].bounds;
        switch (interface_orientation) {
            case UIInterfaceOrientationLandscapeLeft:
                kr = CGRectMake(screen.size.height-(kr.origin.y+kr.size.height), kr.origin.x, kr.size.height, kr.size.width);
                break;
            case UIInterfaceOrientationLandscapeRight:
                kr = CGRectMake(kr.origin.y, screen.size.width-(kr.origin.x+kr.size.width), kr.size.height, kr.size.width);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                kr = CGRectMake(screen.size.width-(kr.origin.x+kr.size.width), screen.size.height-(kr.origin.y+kr.size.height), kr.size.width, kr.size.height);
                break;
            default:
                break;
        }
        //NSLog(@"  after %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
    } else {
        //NSLog(@"  before convertRect %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
        kr = [self.view convertRect:kr fromView:nil];
        //NSLog(@"  after %g %g %g %g", kr.origin.x, kr.origin.y, kr.size.width, kr.size.height);
    }
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (subsequent_keyboard && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [UIView animateWithDuration:duration
                delay:0
                options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]
                animations:^(void) {
            wotdView.frame = CGRectMake(wotdView.frame.origin.x, wotdView.frame.origin.y, wotdView.frame.size.width, kr.origin.y -  wotdView.frame.origin.y);
        } completion:NULL];
    } else {
        wotdView.frame = CGRectMake(wotdView.frame.origin.x, wotdView.frame.origin.y, wotdView.frame.size.width, kr.origin.y - wotdView.frame.origin.y);
    }
    subsequent_keyboard = YES;
    //NSLog(@"wotd origin %g height %g", wotdView.frame.origin.y, wotdView.frame.size.height);
}

- (void)selectWotd:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectEntry:wordOfTheDay];
        [searchBar resignFirstResponder];
        [self.delegate didSelectEntry:wordOfTheDay];
    }
}

- (void)selectSearchMode:(UISegmentedControl *)sender
{
    switch (modeSwitch.selectedSegmentIndex) {
        case 0:
            searchBar.text = @"";
            searchBar.userInteractionEnabled = YES;
            [searchBar becomeFirstResponder];
            wotdView.hidden = NO;
            searchTable.tableHeaderView = nil;
            [searchTable reloadData];
            break;
        case 1:
            searchBar.text = @"(handshape search)";
            [searchBar resignFirstResponder];
            searchBar.userInteractionEnabled = NO;
            wotdView.hidden = YES;
            searchTable.tableHeaderView = searchSelectorView;
            [self collectionView:handshapeSelector didSelectItemAtIndexPath:nil];
            break;
    }
    if (searchResults.count > 0) {
        [searchTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil || searchText.length == 0) {
        wotdView.hidden = NO;
        return;
    }
    wotdView.hidden = YES;
    searchResults = [dict searchFor:searchText];
    [searchTable reloadData];
}

- (void)selectEntry:(DictEntry *)entry
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EntrySelectedName object:self userInfo:@{@"entry": entry}];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)hideKeyboard
{
    [searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchResults.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d sign%s", searchResults.count, searchResults.count == 1 ? "" : "s"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, tableView.rowHeight*2, tableView.rowHeight-4)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryView = iv;
    }

    DictEntry *e = [searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = e.gloss;
    cell.detailTextLabel.text = e.minor;
    UIImageView *iv = (UIImageView *)cell.accessoryView;
    iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"50.%@", e.image]];
    iv.highlightedImage = IOS7() ? transparent_image(iv.image) : invert_image(iv.image);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DictEntry *entry = searchResults[indexPath.row];
    [self selectEntry:entry];
    [searchBar resignFirstResponder];
    [self.delegate didSelectEntry:entry];
}

NSString *Handshapes[] = {
    nil,
    @"1.1.1",
    @"1.1.2",
    @"1.1.3",
    @"1.2.1",
    @"1.2.2",
    @"1.3.1",
    @"1.3.2",
    @"1.4.1",
    @"2.1.1",
    @"2.1.2",
    @"2.2.1",
    @"2.2.2",
    @"2.3.1",
    @"2.3.2",
    @"2.3.3",
    @"3.1.1",
    @"3.2.1",
    @"3.3.1",
    @"3.4.1",
    @"3.4.2",
    @"3.5.1",
    @"3.5.2",
    @"4.1.1",
    @"4.1.2",
    @"4.2.1",
    @"4.2.2",
    @"4.3.1",
    @"4.3.2",
    @"5.1.1",
    @"5.1.2",
    @"5.2.1",
    @"5.3.1",
    @"5.3.2",
    @"5.4.1",
    @"6.1.1",
    @"6.1.2",
    @"6.1.3",
    @"6.1.4",
    @"6.2.1",
    @"6.2.2",
    @"6.2.3",
    @"6.2.4",
    @"6.3.1",
    @"6.3.2",
    @"6.4.1",
    @"6.4.2",
    @"6.5.1",
    @"6.5.2",
    @"6.6.1",
    @"6.6.2",
    @"7.1.1",
    @"7.1.2",
    @"7.1.3",
    @"7.1.4",
    @"7.2.1",
    @"7.3.1",
    @"7.3.2",
    @"7.3.3",
    @"7.4.1",
    @"7.4.2",
    @"8.1.1",
    @"8.1.2",
    @"8.1.3",
};

NSString *Locations[][2] = {
    {nil, nil},
    {@"in front of body", @"location.1.1.in_front_of_body.png"},
    {@"in front of face", @"location.2.2.in_front_of_face.png"},
    {@"head", @"location.3.3.head.png"},
    {@"top of head", @"location.3.4.top_of_head.png"},
    {@"eyes", @"location.3.5.eyes.png"},
    {@"nose", @"location.3.6.nose.png"},
    {@"ear", @"location.3.7.ear.png"},
    {@"cheek", @"location.3.8.cheek.png"},
    {@"lower head", @"location.3.9.lower_head.png"},
    {@"neck/throat", @"location.4.10.neck_throat.png"},
    {@"shoulders", @"location.4.11.shoulders.png"},
    {@"chest", @"location.4.12.chest.png"},
    {@"abdomen", @"location.4.13.abdomen.png"},
    {@"hips/pelvis/groin", @"location.4.14.hips_pelvis_groin.png"},
    {@"upper leg", @"location.4.15.upper_leg.png"},
    {@"upper arm", @"location.5.16.upper_arm.png"},
    {@"elbow", @"location.5.17.elbow.png"},
    {@"lower arm", @"location.5.18.lower_arm.png"},
    {@"wrist", @"location.6.19.wrist.png"},
    {@"fingers/thumb", @"location.6.20.fingers_thumb.png"},
    {@"back of hand", @"location.6.22.back_of_hand.png"},
    //@"palm",
    //@"blades",
};

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == handshapeSelector) {
        return sizeof(Handshapes) / sizeof(Handshapes[0]);
    }
    if (collectionView == locationSelector) {
        return sizeof(Locations) / sizeof(Locations[0]);
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if (indexPath.row == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:HandshapeAnyCellIdentifier forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
        if (label == nil) {
            label = [[UILabel alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 3, 3)];
            label.tag = 1;
            label.text = @"(any)";
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:label];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor blueColor];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:HandshapeIconCellIdentifier forIndexPath:indexPath];
        UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:1];
        if (img == nil) {
            img = [[UIImageView alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 3, 3)];
            img.tag = 1;
            img.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:img];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor blueColor];
        }
        if (collectionView == handshapeSelector) {
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"handshape.%@.png", Handshapes[indexPath.row]]];
        } else if (collectionView == locationSelector) {
            img.image = [UIImage imageNamed:Locations[indexPath.row][1]];
        }
        img.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *handshape = handshapeSelector.indexPathsForSelectedItems;
    NSArray *location = locationSelector.indexPathsForSelectedItems;
    searchResults = [dict searchHandshape:handshape.count ? Handshapes[((NSIndexPath *)handshape[0]).row] : nil
                                 location:location.count ? Locations[((NSIndexPath *)location[0]).row][0] : nil];
    [searchTable reloadData];
}

@end
