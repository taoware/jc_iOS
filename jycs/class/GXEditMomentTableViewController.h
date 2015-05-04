//
//  GXAddMomentTableViewController.h
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unit.h"
#import "GXSquareTableViewController.h"

@interface GXEditMomentTableViewController : UITableViewController
@property (nonatomic, strong)NSMutableArray* imageAssets;
@property (nonatomic)NSInteger unitId;
@property (nonatomic)NSString* unitName;
@property (nonatomic, strong)Unit* unit;
@property (nonatomic, strong)NSString* type;
@property (nonatomic, strong)GXSquareTableViewController* squareVC;
@end
