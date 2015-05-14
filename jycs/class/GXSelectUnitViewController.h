//
//  GXSelectUnitTableViewController.h
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXMomentEntryViewController.h"
#import "Unit.h"

@protocol GXSelectUnitDelegate;

@interface GXSelectUnitViewController : UITableViewController
@property (nonatomic, strong)id<GXSelectUnitDelegate> delegate;
@property (nonatomic, strong)Unit* unit;
@property (nonatomic, strong)NSManagedObjectContext* context;
@end

@protocol GXSelectUnitDelegate <NSObject>
- (void)didFinishSelectUnit:(Unit *)unit;
@end
