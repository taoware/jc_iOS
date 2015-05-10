//
//  StoreShowTableViewCell.h
//  jycs
//
//  Created by appleseed on 3/26/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"

@class GXStoreShowTableViewCell;

@protocol GXStoreShowTableViewCellDelegate<NSObject>

- (void)didSelectStore:(Store*)store;

@end

@interface GXStoreShowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstStoreThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *secondStoreThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *thirdStoreThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *firstStoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdStoreLabel;

@property (strong, nonatomic)id<GXStoreShowTableViewCellDelegate> delegate;
@property (strong, nonatomic)NSArray* stores;
@end
