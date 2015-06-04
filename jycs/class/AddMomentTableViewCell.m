//
//  AddMomentTableViewCell.m
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "AddMomentTableViewCell.h"
#import "UIView+AutoLayout.h"
#import "CTAssetsPageViewController.h"
#import "GXPhotoEngine.h"
#import "Photo.h"

#define SquareImageSize   CGSizeMake(66.5f,  66.5f)

@interface AddMomentTableViewCell () <UITextViewDelegate>
@property (nonatomic) BOOL didSetupConstraints;
@property (nonatomic, strong)NSMutableArray* imageViewArray;
@property (nonatomic, strong)UIImageView* plusImageView;
@property (nonatomic, strong)SZTextView* momentTextView;
@property (nonatomic, strong)NSMutableArray* imagesForMoment;     // type of UIImage

@end

@implementation AddMomentTableViewCell
{
    UIImageView* prototypeImage;
}
@synthesize imagesForMoment = _imagesForMoment;


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        [self.contentView addSubview:self.momentTextView];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        [self.momentTextView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12.0];
        [self.momentTextView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:12.0];
        [self.momentTextView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8.0];
        [self.momentTextView autoSetDimension:ALDimensionHeight toSize:100.0];
        
        self.didSetupConstraints = YES;
    }
    [self layoutImagesInContentView];
    
    [super updateConstraints];
}

- (void)layoutImagesInContentView {
    
    NSInteger imageCount=_imageViewArray.count;
    
    //如果没有图片数组则不对此进行布局
    if (imageCount==0) return;
    
    
    for (UIImageView* imgV in _imageViewArray)
    {
        [self.contentView addSubview:imgV];
    }
    
    prototypeImage=[_imageViewArray firstObject];
    
    //一张图
    if (imageCount==1)
    {
        
        UIImageView* imgView=[_imageViewArray firstObject];
        
        
        [imgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.momentTextView withOffset:5.f];
        
        [imgView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:12.f];
        
        
        /**
         *  不这么写会因为优先级的关系报错 可以尝试下看看  但是如果这么写了之后会高度由于多图原因就变化了。
         */
        [UIImageView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
            [imgView autoSetDimensionsToSize:SquareImageSize];
        }];
        
        
        [imgView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.f relation:NSLayoutRelationGreaterThanOrEqual];
        
    }
    
    //四张图为一行 为小图显示
    if (imageCount>1&&imageCount<=9)
    {
        /**
         *  确认第一张图的位置 后面依次进行排列
         */
        [prototypeImage autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.momentTextView withOffset:5.f];
        
        [prototypeImage autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:12.f];
        
        
        /**
         *  不这么写会因为优先级的关系报错 可以尝试下看看
         */
        [UIImageView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
            [prototypeImage autoSetDimensionsToSize:SquareImageSize];
        }];
        [prototypeImage autoSetDimensionsToSize:SquareImageSize];
        
        
        NSLayoutConstraint*  firtImageLayout=
        [prototypeImage autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.f relation:NSLayoutRelationGreaterThanOrEqual];
        
        //图片等宽高
        [_imageViewArray autoMatchViewsDimension:ALDimensionWidth];
        [_imageViewArray autoMatchViewsDimension:ALDimensionHeight];
        
        //判断有几行
        NSInteger count=0;
        
        UIView *previousView = nil;
        for (UIView *view in _imageViewArray)
        {
            if (previousView)
            {
                if (count%4!=0)
                {
                    // NSLog(@"count:%ld",(long)count);
                    [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousView withOffset:10.0f];
                    [view autoAlignAxis:ALAxisHorizontal toSameAxisOfView:previousView];
                }
                else
                {
                    //判断下一行的距离
                    [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousView withOffset:10.f];
                    //走着这里的一定为下一行的第一张图片
                    [view autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:prototypeImage];
                    
                    [self.contentView removeConstraint:firtImageLayout];
                    
                    [view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.f relation:NSLayoutRelationGreaterThanOrEqual];
                }
                
            }
            previousView = view;
            
            count++;
        }
        
    }

}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    self.momentEntry.text = textView.text;
    [self.delegate momentTextDidChange];
}

#pragma mark - properties

- (void)setMomentEntry:(Moment *)momentEntry {
    _momentEntry = momentEntry;
    
    [self.imageViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewArray removeAllObjects];
    [self.plusImageView removeFromSuperview];
    [momentEntry.photo enumerateObjectsUsingBlock:^(Photo* photo, NSUInteger idx, BOOL *stop) {
        UIImageView* imageView  = [[UIImageView alloc]initForAutoLayout];
        imageView.tag = idx;
        
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled=YES;
        [imageView addGestureRecognizer:[self addTapGestureRecognizer]];
        imageView.image = [GXPhotoEngine imageForlocalPhotoUrl:photo.imageURL];
        
        [self.imageViewArray addObject:imageView];
    }];
    
    if (!self.onlyText) {
        if (self.imageViewArray.count < 9) {
            [self.imageViewArray addObject:self.plusImageView];
        }
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraints];

}

- (SZTextView *)momentTextView {
    if (!_momentTextView) {
        _momentTextView = [[SZTextView alloc]init];
        _momentTextView.placeholder = @"请输入您要发布的内容";
        _momentTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _momentTextView.delegate = self;
    }
    return _momentTextView;
}

- (void)setImagesForMoment:(NSMutableArray *)imagesForMoment {
    _imagesForMoment = imagesForMoment;
    
    [self.imageViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewArray removeAllObjects];
    [self.plusImageView removeFromSuperview];
    [imagesForMoment enumerateObjectsUsingBlock:^(UIImage* image, NSUInteger idx, BOOL *stop) {
        UIImageView* imageView  = [[UIImageView alloc]initForAutoLayout];
        imageView.tag = idx;
        
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled=YES;
        [imageView addGestureRecognizer:[self addTapGestureRecognizer]];
        imageView.image = image;
        
        [self.imageViewArray addObject:imageView];
    }];
    
    if (self.imageViewArray.count < 9) {
        [self.imageViewArray addObject:self.plusImageView];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

-(UITapGestureRecognizer*)addTapGestureRecognizer
{
    UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgViewTapped:)];
    
    return tapGesture;
}

-(void)imgViewTapped:(UITapGestureRecognizer*) tapGestureRecognizer
{
    UIImageView *iv = (UIImageView *)tapGestureRecognizer.view;
    if (iv.image != nil) {
        if ([self.delegate respondsToSelector:@selector(selectImageThunbnailAtIndex:)]) {
            [self.delegate selectImageThunbnailAtIndex:iv.tag];
        }
    }
    
}

-(void)addMoreImage:(UITapGestureRecognizer*)tapGestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(addMoreImage)]) {
        [self.delegate addMoreImage];
    }
}

- (UIImageView *)plusImageView {
    if (!_plusImageView) {
        _plusImageView = [[UIImageView alloc]init];
        _plusImageView.image = [UIImage imageNamed:@"plusSign"];
        _plusImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addMoreImage:)];
        [_plusImageView addGestureRecognizer:tap];
    }
    return _plusImageView;
}

- (NSMutableArray *)imagesForMoment {
    if (!_imagesForMoment) {
        _imagesForMoment = [[NSMutableArray alloc]init];
    }
    return _imagesForMoment;
}

- (NSMutableArray *)imageViewArray {
    if (!_imageViewArray) {
        _imageViewArray = [[NSMutableArray alloc]init];
    }
    return _imageViewArray;
}

@end
