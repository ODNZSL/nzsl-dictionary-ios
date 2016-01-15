////
////  HistoryViewController.m
////  NZSL Dict
////
////  Created by Greg Hewgill on 25/04/13.
////
////
//
//#import "HistoryViewController.h"
//
//#import "AppDelegate.h"
//#import "Dictionary.h"
//#import "imageutil.h"
//
//@interface HistoryViewController ()
//
//@end
//
//@implementation HistoryViewController {
//    NSMutableArray *history;
//}
//
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:0];
//        history = [[NSMutableArray alloc] init];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEntry:) name:EntrySelectedName object:nil];
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
// 
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    
//    if (IOS7()) {
//        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
//    }
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)addEntry:(NSNotification *)notification
//{
//    DictEntry *entry = notification.userInfo[@"entry"];
//    if (![notification.userInfo.allKeys containsObject:@"no_add_history"]) {
//        NSUInteger i = [history indexOfObject:entry];
//        if (i != NSNotFound) {
//            [history removeObjectAtIndex:i];
//        }
//        [history insertObject:entry atIndex:0];
//        while (history.count > 100) {
//            [history removeLastObject];
//        }
//        [self.tableView reloadData];
//    }
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return history.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, tableView.rowHeight*2, tableView.rowHeight-4)];
//        iv.contentMode = UIViewContentModeScaleAspectFit;
//        cell.accessoryView = iv;
//    }
//    
//    DictEntry *entry = history[indexPath.row];
//    cell.textLabel.text = entry.gloss;
//    cell.detailTextLabel.text = entry.minor;
//    UIImageView *iv = (UIImageView *)cell.accessoryView;
//    iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"50.%@", entry.image]];
//    iv.highlightedImage = IOS7() ? transparent_image(iv.image) : invert_image(iv.image);
//    
//    return cell;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//    [[NSNotificationCenter defaultCenter] postNotificationName:EntrySelectedName object:self userInfo:@{
//        @"entry": history[indexPath.row],
//        @"no_add_history": @"no_add",
//    }];
//    [self.delegate didSelectEntry:history[indexPath.row]];
//}
//
//@end
