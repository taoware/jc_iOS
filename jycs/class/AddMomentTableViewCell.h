//
//  AddMomentTableViewCell.h
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "Moment.h"

@protocol AddMomentCellDelegate <NSObject>

- (void)selectImageThunbnailAtIndex:(NSInteger)index;
- (void)addMoreImage;
- (void)momentTextDidChange;

@end

@interface AddMomentTableViewCell : UITableViewCell
@property (nonatomic, strong)Moment* momentEntry;
@property (nonatomic, strong)id<AddMomentCellDelegate> delegate;
@end
