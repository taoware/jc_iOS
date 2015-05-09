//
//  GXMainTabBarViewController.h
//  jycs
//
//  Created by appleseed on 3/30/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXInfoChatListViewController.h"
#import "GXContactListViewController.h"
#import "GXInfoNotificationViewController.h"

@interface GXMainTabBarViewController : UITabBarController
{
    EMConnectionState _connectionState;
}
@property (nonatomic, strong)GXContactListViewController* contactListVC;
@property (nonatomic, strong)GXInfoChatListViewController* chatListVC;
@property (nonatomic, strong)GXInfoNotificationViewController* notificationVC;

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)networkChanged:(EMConnectionState)connectionState;

@end
