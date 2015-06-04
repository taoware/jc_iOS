//
//  GXInfoChatListViewController.h
//  jycs
//
//  Created by appleseed on 3/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GXChatListViewController : BaseViewController

- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
