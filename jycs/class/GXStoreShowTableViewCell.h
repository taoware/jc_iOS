//
//  StoreShowTableViewCell.h
//  jycs
//
//  Created by appleseed on 3/26/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXStoreShowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstStoreThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *secondStoreThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *thirdStoreThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *firstStoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdStoreLabel;
@end
