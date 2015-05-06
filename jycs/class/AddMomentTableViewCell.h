//
//  AddMomentTableViewCell.h
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

@protocol AddMomentCellDelegate <NSObject>

- (void)selectImageThunbnailAtIndex:(NSInteger)index;
- (void)addMoreImage;
- (void)textViewDidEndEditing:(UITextView *)textView;

@end

@interface AddMomentTableViewCell : UITableViewCell
@property (nonatomic, strong)SZTextView* momentTextView;
@property (nonatomic, strong)NSMutableArray* imagesForMoment;     // type of UIImage
@property (nonatomic, strong)id<AddMomentCellDelegate> delegate;
@end
