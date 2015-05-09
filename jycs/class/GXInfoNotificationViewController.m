//
//  GXInfoNotificationViewController.m
//  jycs
//
//  Created by appleseed on 3/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXInfoNotificationViewController.h"
#import "XLPagerTabStripViewController.h"
#import "GXCoreDataController.h"
#import "GXNotificationTableViewCell.h"
#import "Notification.h"

@interface GXInfoNotificationViewController () <XLPagerTabStripChildItem>
@property (nonatomic, strong)NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
@property (nonatomic, strong)NSArray* notifications;
@end

@implementation GXInfoNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;

    self.managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self loadNotificationFromCoreData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_NOTIFICATIONRECEIVED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self reloadDataSource];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

- (void)loadNotificationFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        self.notifications = [self.managedObjectContext executeFetchRequest:request error:&error];
        
    }];
}

- (void)reloadDataSource {
    [self loadNotificationFromCoreData];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GXNotificationTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
    cell.notification = notification;
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"notification_back.png"]];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static GXNotificationTableViewCell *sizingCell = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
//    });
//    
//    Notification* notification = [self.notifications objectAtIndex:indexPath.row];
//    sizingCell.titleLabel.text = [notification.title substringFromIndex:6];
//    sizingCell.bodyLabel.text = notification.body;
//    sizingCell.timeLabel.text = [self.dateFormatter stringFromDate:notification.timestamp];
//    
//    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
//    
//    [sizingCell setNeedsLayout];
//    [sizingCell layoutIfNeeded];
//    
//    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height + 1.0f; // Add 1.0f for the cell separator height
//}


#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"通知";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor blackColor];
}

@end
