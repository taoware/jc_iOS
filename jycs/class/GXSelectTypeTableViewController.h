//
//  GXSelectTypeTableViewController.h
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXEditMomentTableViewController.h"

@interface GXSelectTypeTableViewController : UITableViewController
@property (nonatomic, strong)GXEditMomentTableViewController* addMomentVC;
@property (nonatomic, strong)NSString* currentType;
@end
