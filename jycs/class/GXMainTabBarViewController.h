//
//  GXMainTabBarViewController.h
//  jycs
//
//  Created by appleseed on 3/30/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXChatListViewController.h"
#import "GXContactsViewController.h"
#import "GXInfoNotificationViewController.h"

@interface GXMainTabBarViewController : UITabBarController
{
    EMConnectionState _connectionState;
}

- (void)jumpToChatList;

- (void)setupUntreatedApplyCount;

- (void)networkChanged:(EMConnectionState)connectionState;

@end
