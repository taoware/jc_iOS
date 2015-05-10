//
//  StoreShowTableViewCell.m
//  jycs
//
//  Created by appleseed on 3/26/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXStoreShowTableViewCell.h"

@implementation GXStoreShowTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFirstStoreThumbnail:(UIImageView *)firstStoreThumbnail {
    _firstStoreThumbnail = firstStoreThumbnail;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(storeImageTapped:)];
    [_firstStoreThumbnail addGestureRecognizer:tap];
}

- (void)setSecondStoreThumbnail:(UIImageView *)secondStoreThumbnail {
    _secondStoreThumbnail = secondStoreThumbnail;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(storeImageTapped:)];
    [_secondStoreThumbnail addGestureRecognizer:tap];
}

- (void)setThirdStoreThumbnail:(UIImageView *)thirdStoreThumbnail {
    _thirdStoreThumbnail = thirdStoreThumbnail;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(storeImageTapped:)];
    [_thirdStoreThumbnail addGestureRecognizer:tap];
}

- (void)storeImageTapped:(UIGestureRecognizer*)sender {
    int index = sender.view.tag;
    if (index < self.stores.count) {
        [self.delegate didSelectStore:[self.stores objectAtIndex:index]];
    }
    
}

@end
