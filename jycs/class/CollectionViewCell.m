//
//  CollectionViewCell.m
//  jycs
//
//  Created by appleseed on 2/4/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 初始化时加载collectionCell.xib文件
//        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CollectionViewCell" owner:self options:nil];
//        
//        // 如果路径不存在，return nil
//        if (arrayOfViews.count < 1)
//        {
//            return nil;
//        }
//        // 如果xib中view不属于UICollectionViewCell类，return nil
//        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
//        {
//            return nil;
//        }
//        // 加载nib
//        self = [arrayOfViews objectAtIndex:0];

        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(frame)-10, CGRectGetWidth(frame)-10)];
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetWidth(frame), CGRectGetWidth(frame), 20)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.imageView];
        [self addSubview:self.label];
    }
    return self;
}


@end
