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
#import "Notification+Create.h"

@interface GXInfoNotificationViewController () <IChatManagerDelegate, XLPagerTabStripChildItem>
@property (nonatomic, strong)NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
@property (nonatomic, strong)NSMutableArray* dataSource;
@end

@implementation GXInfoNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;

    self.managedObjectContext = [[GXCoreDataController sharedInstance] masterManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshDataSource];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [self.tableView reloadData];
}

- (NSMutableArray *)loadDataSource {
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    conversations = [self filterForConversationPrefixedGroup:conversations];
    NSMutableArray* messages = [[NSMutableArray alloc]init];
    for (EMConversation* conversation in conversations) {
        [messages addObjectsFromArray:[conversation loadAllMessages]];
    }
    NSArray* sorte = [messages sortedArrayUsingComparator:^NSComparisonResult(EMMessage *message1, EMMessage *message2) {
        if(message1.timestamp > message2.timestamp) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    NSArray* notification = [Notification loadNotificationsFromNotificationsArray:sorte intoManagedObjectContext:self.managedObjectContext];
    
    ret = [[NSMutableArray alloc] initWithArray:notification];
    return ret;
}

- (NSArray *)filterForConversationPrefixedGroup:(NSArray *)conversations {
    NSMutableArray* filteredConversation = [[NSMutableArray alloc]init];
    for (EMConversation* conversation in conversations) {
        if (conversation.isGroup && [[self groupNameFromgroupId:conversation.chatter] hasPrefix:@"group_"]) {
            [filteredConversation addObject:conversation];
        }
    }
    return filteredConversation;
}

- (NSString *)groupNameFromgroupId:(NSString *)groupId {
    NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    for (EMGroup* group in groupArray) {
        if ([group.groupId isEqualToString:groupId]) {
            return group.groupSubject;
        }
    }
    return nil;
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GXNotificationTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    Notification* notification = [self.dataSource objectAtIndex:indexPath.row];
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
