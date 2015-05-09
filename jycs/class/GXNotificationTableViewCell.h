//
//  GXNotificationTableViewCell.h
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface GXNotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *readButton;

@property (strong, nonatomic)Notification* notification;

@end
