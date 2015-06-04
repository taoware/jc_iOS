//
//  GXUserInfoViewController.h
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"
#import "EMBuddy+JCuser.h"

@interface GXUserInfoViewController : UITableViewController
@property (nonatomic, strong)Moment* moment;
@property (nonatomic, strong)EMBuddy* buddy;
@end
