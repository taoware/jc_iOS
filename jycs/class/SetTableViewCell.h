//
//  SetTableViewCell.h
//  jycs
//
//  Created by appleseed on 2/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *foldingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *setName;
@end
