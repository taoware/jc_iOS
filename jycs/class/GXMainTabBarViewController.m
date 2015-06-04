//
//  GXMainTabBarViewController.m
//  jycs
//
//  Created by appleseed on 3/30/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMainTabBarViewController.h"
#import "GXUserEngine.h"
#import "GXChatListViewController.h"
#import "GXContactsViewController.h"
#import "GXMomentListViewController.h"
#import "ApplyViewController.h"
#import "CallViewController.h"
#import "GXUserEngine.h"
#import "Notification+Create.h"
#import "GXCoreDataController.h"
#import "User+Permission.h"
#import "GXGoToLoginViewController.h"
#import "GXMeTableViewController.h"
#import "GXInfoViewController.h"
#import "GXGoLoginViewController.h"
#import "GXMomentsEngine.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface GXMainTabBarViewController () <UIAlertViewDelegate, IChatManagerDelegate, EMCallManagerDelegate>
@property (nonatomic, strong)GXInfoViewController* infoVC;
@property (nonatomic, strong)GXChatListViewController* chatListVC;
@property (nonatomic, strong)GXContactsViewController* contactsVC;
@property (nonatomic, strong)GXMomentListViewController* squareVC;
@property (nonatomic, strong)GXMeTableViewController* meVC;

@property (nonatomic, strong)UIBarButtonItem* showItem;
@property (nonatomic, strong)UIBarButtonItem* addItem;
@property (nonatomic, strong)UIBarButtonItem* refreshItem;
@property (nonatomic, strong)UIBarButtonItem* giftItem;
@property (nonatomic, strong)UIBarButtonItem* sendItem;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property (nonatomic) BOOL wasInSquare;
@end

@implementation GXMainTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //if 使tabBarController中管理的viewControllers都符合 UIRectEdgeNone
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"资讯";
    self.wasInSquare = NO;
    
    self.infoVC = self.viewControllers[0];
    self.chatListVC = self.viewControllers[1];
    self.contactsVC = self.viewControllers[2];
//    [self.contactsVC performSelector:@selector(view)];   // force load contactListVC
    self.squareVC = self.viewControllers[3];
    self.meVC = self.viewControllers[4];
    [self setupTabBarappearance];
    
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];
#warning 把self注册为SDK的delegate
    [self registerNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callOutWithChatter:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
    
    UIButton *showButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [showButton setImage:[UIImage imageNamed:@"store.png"] forState:UIControlStateNormal];
    [showButton addTarget:_infoVC action:@selector(showStoreInfo) forControlEvents:UIControlEventTouchUpInside];
    _showItem = [[UIBarButtonItem alloc] initWithCustomView:showButton];
//    self.navigationItem.rightBarButtonItem = _showItem;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [addButton setImage:[UIImage imageNamed:@"add_contact.png"] forState:UIControlStateNormal];
    [addButton addTarget:_contactsVC action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    _addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    _refreshItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTouched:)];
    
    UIButton *giftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [giftButton setImage:[UIImage imageNamed:@"gift.png"] forState:UIControlStateNormal];
    [giftButton addTarget:_squareVC action:@selector(showGiftInfo) forControlEvents:UIControlEventTouchUpInside];
    _giftItem = [[UIBarButtonItem alloc] initWithCustomView:giftButton];
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [sendButton setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
    [sendButton addTarget:_squareVC action:@selector(sendSquareMoments) forControlEvents:UIControlEventTouchUpInside];
    _sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    [self setupUnreadMessageCount];
    [self setupUntreatedApplyCount];
    
    [self fetchBuddyList];
    [self fetchMembersInGroup];
}

- (void)setupSubviews {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    GXGoLoginViewController *goToLoginVCForChatList = [storyboard instantiateViewControllerWithIdentifier:@"goLogin"];
    goToLoginVCForChatList.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_message.png"] selectedImage:[UIImage imageNamed:@"tabbar_messageHL.png"]];
    GXGoLoginViewController *goToLoginVCForContact = [storyboard instantiateViewControllerWithIdentifier:@"goLogin"];
    goToLoginVCForContact.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"tabbar_contact.png"] selectedImage:[UIImage imageNamed:@"tabbar_contactHL.png"]];
    GXGoLoginViewController *goToLoginVCForSquare = [storyboard instantiateViewControllerWithIdentifier:@"goLogin"];
    goToLoginVCForSquare.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"广场" image:[UIImage imageNamed:@"tabbar_square.png"] selectedImage:[UIImage imageNamed:@"tabbar_squareHL.png"]];
    GXGoLoginViewController *goToLoginVCForMe = [storyboard instantiateViewControllerWithIdentifier:@"goLogin"];
    goToLoginVCForMe.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我" image:[UIImage imageNamed:@"tabbar_me.png"] selectedImage:[UIImage imageNamed:@"tabbar_meHL.png"]];
    
    UIViewController* noPermisssionForChatList = [storyboard instantiateViewControllerWithIdentifier:@"noPermission"];
    noPermisssionForChatList.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_message.png"] selectedImage:[UIImage imageNamed:@"tabbar_messageHL.png"]];
    UIViewController* noPermissionForContact = [storyboard instantiateViewControllerWithIdentifier:@"noPermission"];
    noPermissionForContact.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageNamed:@"tabbar_contact.png"] selectedImage:[UIImage imageNamed:@"tabbar_contactHL.png"]];
    UIViewController* noPermissionForSquare = [storyboard instantiateViewControllerWithIdentifier:@"noPermission"];
    noPermissionForSquare.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"广场" image:[UIImage imageNamed:@"tabbar_square.png"] selectedImage:[UIImage imageNamed:@"tabbar_squareHL.png"]];


    
    NSMutableArray *tabbarViewControllers = [self.viewControllers mutableCopy];
    User* userLoggedIn = [GXUserEngine sharedEngine].userLoggedIn;
    NSLog(@"%@", userLoggedIn);
    id obj = [userLoggedIn.hasPermisson anyObject];
    NSLog(@"%i", userLoggedIn.hasPermisson.count);
    NSLog(@"%@", userLoggedIn.name);
    NSLog(@"%@", userLoggedIn.managedObjectContext);
    if (!userLoggedIn) {
        [tabbarViewControllers replaceObjectAtIndex:1 withObject:goToLoginVCForChatList];
        [tabbarViewControllers replaceObjectAtIndex:2 withObject:goToLoginVCForContact];
        [tabbarViewControllers replaceObjectAtIndex:3 withObject:goToLoginVCForSquare];
        [tabbarViewControllers replaceObjectAtIndex:4 withObject:goToLoginVCForMe];
    } else {
        if (![userLoggedIn canIM]) {
            [tabbarViewControllers replaceObjectAtIndex:1 withObject:noPermisssionForChatList];
            [tabbarViewControllers replaceObjectAtIndex:2 withObject:noPermissionForContact];
        }
        if (![userLoggedIn canVisitSquare]) {
            [tabbarViewControllers replaceObjectAtIndex:3 withObject:noPermissionForSquare];
        }
    }
    
    self.viewControllers = tabbarViewControllers;
}

// force loadBuddyList, tried asyncFetchBuddyList method, but the callback didFetchedBuddyList:error not called
- (void)fetchBuddyList {
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error && buddyList.count) {
            [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:[buddyList valueForKey:@"username"] completion:^(GXError *error) {
                [_contactsVC reloadDataSource];
            }];
        }
    } onQueue:dispatch_get_main_queue()];
}

- (void)fetchMembersInGroup {
    NSArray *rooms = [[EaseMob sharedInstance].chatManager groupList];
    NSMutableArray* usernames = [[NSMutableArray alloc]init];
    
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    for (EMGroup* room in rooms) {
        dispatch_group_enter(group);
        [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:room.groupId completion:^(EMGroup *room, EMError *error) {
            [usernames addObjectsFromArray:room.members];
            
            // Leave the group as soon as the request failed
            dispatch_group_leave(group);
        } onQueue:nil];
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:usernames completion:NULL];
    });
}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)setupTabBarappearance {
    UITabBarController *tabBarController = self;
    UITabBar *tabBar = tabBarController.tabBar;
    tabBar.backgroundImage = [UIImage imageNamed:@"tabbarBackground"];
    tabBar.shadowImage = [UIImage imageNamed:@"tabbar_shadow"];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    
    tabBarItem1.title = @"资讯";
    tabBarItem2.title = @"消息";
    tabBarItem3.title = @"通讯录";
    tabBarItem4.title = @"广场";
    tabBarItem5.title = @"我";
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_infoHL.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_info.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_messageHL.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_message.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_contactHL.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_contact.png"]];
    [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_squareHL.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_square.png"]];
    [tabBarItem5 setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_meHL.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_me.png"]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = [tabBar.items indexOfObject:item];

    if (self.wasInSquare) {
        [[GXMomentsEngine sharedEngine] removeObserver:self forKeyPath:@"syncInProgress"];
    }
    self.wasInSquare = false;
//    if (![GXUserEngine sharedEngine].userLoggedIn.audit.boolValue) {
//        if (index == 0) {
//            self.title = @"资讯";
//            self.navigationItem.rightBarButtonItem = nil;
//            self.navigationItem.rightBarButtonItem = self.showItem;
//        }else if (index == 1){
//            self.navigationItem.rightBarButtonItem = nil;
//            self.title = @"消息";
//        }else if (index == 2){
//            self.title = @"通讯录";
//            self.navigationItem.rightBarButtonItem = nil;
//            self.navigationItem.rightBarButtonItems = nil;
//        }else if (index == 3){
//            self.title = @"广场";
//            self.navigationItem.rightBarButtonItem = nil;
//            self.navigationItem.rightBarButtonItems = nil;
//        }else if (index == 4) {
//            self.title = @"我";
//            self.navigationItem.rightBarButtonItem = nil;
//            self.navigationItem.rightBarButtonItems = nil;
//        }
//    } else {
        if (index == 0) {
            self.title = @"资讯";
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItem = nil;
        }else if (index == 1){
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItem = nil;
            self.title = @"消息";
        }else if (index == 2) {
            self.title = @"通讯录";
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = self.addItem;
            
        }else if (index == 3){
            self.title = @"广场";
            self.wasInSquare = YES;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItem = self.refreshItem;
            self.navigationItem.rightBarButtonItem = self.sendItem;
            [self checkSyncStatus];
            [[GXMomentsEngine sharedEngine] addObserver:self forKeyPath:@"syncInProgress" options:NSKeyValueObservingOptionNew context:nil];
        }else if (index == 4){
            self.title = @"我";
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItem = nil;
        }
//    }
}

- (IBAction)refreshButtonTouched:(id)sender {
    [[GXMomentsEngine sharedEngine] startSync];
}

- (void)checkSyncStatus {
    if ([[GXMomentsEngine sharedEngine] syncInProgress]) {
        [self replaceRefreshButtonWithActivityIndicator];
    } else {
        [self removeActivityIndicatorFromRefreshButon];
    }
}

- (void)replaceRefreshButtonWithActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.leftBarButtonItem = activityItem;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)removeActivityIndicatorFromRefreshButon {
    self.navigationItem.leftBarButtonItem = self.refreshItem;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"syncInProgress"]) {
        [self checkSyncStatus];
    }
}




#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                [[ApplyViewController shareController] clear];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } onQueue:nil];
        }
    }
    else if (alertView.tag == 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    } else if (alertView.tag == 101) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - private

-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EMSDKFull sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EMSDKFull sharedInstance].callManager removeDelegate:self];
}


-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14], UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,
                                        nil] forState:UIControlStateNormal];
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14],
                                        UITextAttributeFont,RGBACOLOR(0x00, 0xac, 0xff, 1),UITextAttributeTextColor,
                                        nil] forState:UIControlStateSelected];
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatListVC) {
        if (unreadCount > 0) {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (_contactsVC) {
        if (unreadCount > 0) {
            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    [_chatListVC networkChanged:connectionState];
}

- (void)callOutWithChatter:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        EMError *error = nil;
        NSString *chatter = [object objectForKey:@"chatter"];
        EMCallSessionType type = [[object objectForKey:@"type"] intValue];
        EMCallSession *callSession = nil;
        if (type == eCallSessionTypeAudio) {
            callSession = [[EMSDKFull sharedInstance].callManager asyncMakeVoiceCall:chatter timeout:50 error:&error];
        }
        else if (type == eCallSessionTypeVideo){
            callSession = [[EMSDKFull sharedInstance].callManager asyncMakeVideoCall:chatter timeout:50 error:&error];
        }
        
        if (callSession && !error) {
            [[EMSDKFull sharedInstance].callManager removeDelegate:self];
            
            //            _callController = nil;
            CallViewController *callController = [[CallViewController alloc] initWithSession:callSession isIncoming:NO];
            callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            //            _callController = callController;
            [self presentViewController:callController animated:NO completion:nil];
        }
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)callControllerClose:(NSNotification *)notification
{
    //    [_callController dismissViewControllerAnimated:NO completion:nil];
    //    [[EMSDKFull sharedInstance].callManager removeDelegate:_callController];
    //    _callController = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    [[EMSDKFull sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [self setupUnreadMessageCount];
    [_chatListVC refreshDataSource];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    
}

- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    return ret;
}

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else {
            [self playSoundAndVibration];
        }
#endif
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.vidio", @"Vidio");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        NSString *hintText = NSLocalizedString(@"reconnection.retry", @"Fail to log in your account, is try again... \nclick 'logout' button to jump to the login page \nclick 'continue to wait for' button for reconnection successful");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                            message:hintText
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"reconnection.wait", @"continue to wait")
                                                  otherButtonTitles:NSLocalizedString(@"logout", @"Logout"),
                                  nil];
        alertView.tag = 99;
        [alertView show];
        [_chatListVC isConnect:NO];
    }
}

#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            //发送本地推送
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date]; //触发通知的时间
            User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:username];
            notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), user?user.name:@"未知"];
            notification.alertAction = NSLocalizedString(@"open", @"Open");
            notification.timeZone = [NSTimeZone defaultTimeZone];
        }
#endif
        
        [_contactsVC reloadApplyView];
    }];
}

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:[buddyList valueForKey:@"username"] completion:^(GXError *error) {
        if (!isAdd)
        {
            NSMutableArray *deletedBuddies = [NSMutableArray array];
            for (EMBuddy *buddy in changedBuddies)
            {
                [deletedBuddies addObject:buddy.username];
            }
            [[EaseMob sharedInstance].chatManager removeConversationsByChatters:deletedBuddies deleteMessages:YES append2Chat:YES];
            [_chatListVC refreshDataSource];
        }
        [_contactsVC reloadDataSource];
    }];
}

- (void)didRemovedByBuddy:(NSString *)username
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:username];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:user?user.name:@"未知" deleteMessages:YES append2Chat:YES];
//        NSString *message = [NSString stringWithFormat:@"'%@' 已经将你从联系人中删除", user?user.name:@"未知"];
//        TTAlertNoTitle(message);
        [_chatListVC refreshDataSource];
        [_contactsVC reloadDataSource];
    }];
}

- (void)didAcceptedByBuddy:(NSString *)username
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:username];
        NSString *message = [NSString stringWithFormat:@"'%@' 已同意添加你为联系人", user?user.name:@"未知"];
        TTAlertNoTitle(message);
        [_contactsVC reloadDataSource];
    }];
}

- (void)didRejectedByBuddy:(NSString *)username
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:username];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.beRefusedToAdd", @"you are shameless refused by '%@'"), user?user.name:@"未知"];
        TTAlertNoTitle(message);
    }];
}

- (void)didAcceptBuddySucceed:(NSString *)username
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        [_contactsVC reloadDataSource];
    }];
}

#pragma mark - IChatManagerDelegate 群组变化

- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
#endif
        
        [_contactsVC reloadGroupView];
    }];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        if (!error) {
#if !TARGET_IPHONE_SIMULATOR
            [self playSoundAndVibration];
#endif
            
            [_contactsVC reloadGroupView];
        }
    }];
}

- (void)didReceiveGroupRejectFrom:(NSString *)groupId
                          invitee:(NSString *)username
                           reason:(NSString *)reason
{
    [[GXUserEngine sharedEngine] asyncFetchUserInfoWithEasemobUsername:@[username] completion:^(GXError *error) {
        User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:username];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.beRefusedToAdd", @"you are shameless refused by '%@'"), user?user.name:@"未知"];
        TTAlertNoTitle(message);
    }];
}


- (void)didReceiveAcceptApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedToJoin", @"agreed to join the group of \'%@\'"), groupname];
    [self showHint:message];
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
        
    } onQueue:nil];
}

- (void)didRemovedFromServer
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

//- (void)didConnectionStateChanged:(EMConnectionState)connectionState
//{
//    [_chatListVC networkChanged:connectionState];
//}

#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    [self hideHud];
    [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    [self hideHud];
    if (error) {
        [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
    }else{
        [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
    }
}

#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    if (callSession.status == eCallSessionStatusConnected)
    {
        EMError *error = nil;
        BOOL isShowPicker = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowPicker"] boolValue];
        
#warning 在后台不能进行视频通话
        if(callSession.type == eCallSessionTypeVideo && [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
            error = [EMError errorWithCode:EMErrorInitFailure andDescription:@"后台不能进行视频通话"];
        }
        else if (!isShowPicker){
            [[EMSDKFull sharedInstance].callManager removeDelegate:self];
            //            _callController = nil;
            CallViewController *callController = [[CallViewController alloc] initWithSession:callSession isIncoming:YES];
            callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            //            _callController = callController;
            [self presentViewController:callController animated:NO completion:nil];
        }
        
        if (error || isShowPicker) {
            [[EMSDKFull sharedInstance].callManager asyncEndCall:callSession.sessionId reason:eCallReason_Hangup];
        }
    }
}

#pragma mark - public

- (void)jumpToChatList
{
    if(_chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:_chatListVC];
    }
}


@end
