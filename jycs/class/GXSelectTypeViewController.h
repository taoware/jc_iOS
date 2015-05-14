//
//  GXSelectTypeTableViewController.h
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GXSelectTypeDelegate;

@interface GXSelectTypeViewController : UITableViewController
@property (nonatomic, strong)NSString* type;
@property (nonatomic, strong)id<GXSelectTypeDelegate> delegate;
@end

@protocol GXSelectTypeDelegate <NSObject>
- (void)didFinishSelectType:(NSString *)type;
@end