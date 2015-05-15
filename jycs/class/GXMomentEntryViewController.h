//
//  GXAddMomentTableViewController.h
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unit.h"
#import "GXMomentListViewController.h"

@protocol GXMomentEntryDelegate;

@interface GXMomentEntryViewController : UITableViewController
@property (nonatomic, strong)Moment* momentEntry;
@property (nonatomic, strong)NSManagedObjectContext* context;
@property (nonatomic, weak)id<GXMomentEntryDelegate> delegate;
@end

@protocol GXMomentEntryDelegate <NSObject>
- (void)didFinishMomentEntryViewController:(GXMomentEntryViewController *)viewController didSave:(BOOL)didSave;
@end

