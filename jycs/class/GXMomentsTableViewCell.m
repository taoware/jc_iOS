//
//  GXMomentsTableViewCell.m
//  jycs
//
//  Created by appleseed on 4/13/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMomentsTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+AutoLayout.h"
#import "SFPhotoBrowser.h"

/*
 *  从RGB获得颜色 0xffffff
 */
#define UIColorFromRGB(rgbValue)                            \
[UIColor                                                    \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0   \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0             \
blue:((float)(rgbValue & 0xFF))/255.0                       \
alpha:1.0]



#define UserNameColor     UIColorFromRGB(0xeca55d)

#define HeadImageSize     CGSizeMake(34.f,  34.f)

#define BigImageSize      CGSizeMake(70.f, 70.f)
#define SquareImageSize   CGSizeMake(70.f,  70.f)


#define ImageMargin                         10.f
#define MaxImageCount                       9
#define MinimumImageCount                   0

@interface GXMomentsTableViewCell ()
@property (nonatomic,strong ) NSArray        * urlArray;
@property (nonatomic,strong) NSArray         * urlThumbnailArray;

@property (nonatomic,strong ) NSMutableArray * imageViewArray;

//对于每个cell 用一个bool值去标识是否已设置约束
@property (nonatomic, assign) BOOL           didSetupConstraints;
@end

@implementation GXMomentsTableViewCell
{
    UIImageView* prototypeImage;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.bodyLabel];
        [self.contentView addSubview:self.userNameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.resendButton];
    }
    return self;
}

-(void)updateConstraints
{
    //如果未设置约束 则进行约束
    if (!self.didSetupConstraints)
    {
        [self.headImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:12];
        [self.headImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
        [self.headImageView autoSetDimensionsToSize:HeadImageSize];
        
        //[UIImageView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        //}];
        //距离底部的高度也需要设置
        //[self.headImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10 relation:NSLayoutRelationGreaterThanOrEqual];
        
        
        
        [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headImageView withOffset:15.f];
        [self.bodyLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.headImageView];
        [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:30.f];
        [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10 relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.userNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12.f];
        [self.userNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.headImageView withOffset:15.f];
        [self.userNameLabel sizeToFit];
        
        
        [self.timeLabel autoPinEdge:ALEdgeTop  toEdge:ALEdgeBottom ofView:self.userNameLabel withOffset:10.f];
        [self.timeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeRight ofView:self.headImageView withOffset:15.f];
        [self.timeLabel sizeToFit];
        
        [self.resendButton autoPinEdge:ALEdgeTop  toEdge:ALEdgeBottom ofView:self.userNameLabel withOffset:8.f];
        [self.resendButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeRight ofView:self.headImageView withOffset:15.f];
        self.resendButton.hidden = YES;
        [self.resendButton setTitle:@"点击重新发送" forState:UIControlStateNormal];
//        [self.resendButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resendButtonTapped)]];
        [self.resendButton addTarget:self action:@selector(resendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.resendButton sizeToFit];
        
        /**
         *  设置图片的约束
         */
//        [self layoutImagesInContentView];
        
        
        self.didSetupConstraints = YES;
        
    }
    
    [self layoutImagesInContentView];
    
    //这句一定要写， 不写会崩
    [super updateConstraints];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    
    self.bodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bodyLabel.frame);
}
                                              
- (void)resendButtonTapped {
    [self.delegate resendButtonTappedWithMoment:self.momentToDisplay];
}


#pragma mark- Outside Method
-(void)setImageswithURLs:(NSArray *)urls
{
    if (urls.count>MaxImageCount)  NSAssert(nil,@"set images must less than 9",MaxImageCount);
    
    _urlArray = urls;
    
}

-(void)setImageswithThumbnailURLs:(NSArray *)urlsOfThumbnail
{
    if (urlsOfThumbnail.count>MaxImageCount)  NSAssert(nil,@"set images must less than 9",MaxImageCount);
    
    _urlThumbnailArray =[[NSArray alloc]initWithArray:urlsOfThumbnail];
    [self.imageViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewArray removeAllObjects];
    
    [_urlThumbnailArray enumerateObjectsUsingBlock:^(NSString* url, NSUInteger idx, BOOL *stop) {
        UIImageView* imgV=[[UIImageView alloc]initForAutoLayout];
        imgV.tag = idx;
        
        imgV.backgroundColor=[UIColor lightGrayColor];
        imgV.contentMode=UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        imgV.userInteractionEnabled=YES;
        [imgV addGestureRecognizer:[self addTapGestureRecognizer]];
        
        [imgV setImageWithURL:[NSURL URLWithString:url]];
        
        [self.imageViewArray addObject:imgV];
    }];
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
        [SFPhotoBrowser animateShowBigPhotosFromThumbImageViews:self.imageViewArray fromViewController:self.fromViewController bigPhotoesURL:self.urlArray curIndex:iv.tag didEndShowing:^{
            
        } didEndDismissing:^{
        }];
    }
    
}


#pragma mark - Layout Method
-(void)layoutImagesInContentView
{
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
        
        
        [imgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.bodyLabel withOffset:5.f];
        
        [imgView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:12.f];
        
        
        /**
         *  不这么写会因为优先级的关系报错 可以尝试下看看  但是如果这么写了之后会高度由于多图原因就变化了。
         */
        [UIImageView autoSetPriority:UILayoutPriorityDefaultHigh forConstraints:^{
            [imgView autoSetDimensionsToSize:BigImageSize];
        }];
        
        
        [imgView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.f relation:NSLayoutRelationGreaterThanOrEqual];
        
    }
    
    //三张图为一行 为小图显示 九图为3列
    else if (imageCount>1&&imageCount<=9)
    {
        /**
         *  确认第一张图的位置 后面依次进行排列
         */
        [prototypeImage autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.bodyLabel withOffset:5.f];
        
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
        // [_imageViewArray autoAlignViewsToAxis:ALAxisHorizontal];
        
        //判断有几行
        //NSInteger row=_imageViewArray.count%3==0?1:_imageViewArray.count/3+1;
        NSInteger count=0;
        
        UIView *previousView = nil;
        for (UIView *view in _imageViewArray)
        {
            if (previousView)
            {
                if (count%3!=0)
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



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Property Accessor

- (void)setIsSynced:(BOOL)isSynced {
    _syncStatus = isSynced;
    self.timeLabel.hidden = isSynced;
    self.resendButton.hidden = !isSynced;
}

- (void)setSyncStatus:(GXObjectSyncStatus)syncStatus {
    _syncStatus = syncStatus;
    switch (syncStatus) {
        case GXObjectSynced:
            self.timeLabel.hidden = NO;
            self.resendButton.hidden = YES;
            break;
        case GXObjectSyncing:
            self.timeLabel.hidden = YES;
            self.resendButton.hidden = NO;
            self.resendButton.enabled = NO;
            [self.resendButton setTitle:@"正在发送" forState:UIControlStateNormal];
            break;
        case GXObjectSyncFailed:
            self.timeLabel.hidden = YES;
            self.resendButton.hidden = NO;
            self.resendButton.enabled = YES;
            [self.resendButton setTitle:@"点击重新发送" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

-(UIImageView *)headImageView
{
    if (!_headImageView)
    {
        _headImageView=[[UIImageView alloc]initForAutoLayout];
        _headImageView.backgroundColor=[UIColor lightGrayColor];
        _headImageView.contentMode=UIViewContentModeScaleToFill;
        _headImageView.clipsToBounds=YES;
        _headImageView.layer.cornerRadius=5.f;
    }
    return _headImageView;
}

-(UILabel *)bodyLabel
{
    if (!_bodyLabel)
    {
        _bodyLabel=[[UILabel alloc]initForAutoLayout];
        // _bodyLabel.backgroundColor=[UIColor blueColor];
        _bodyLabel.textColor=[UIColor blackColor];
        _bodyLabel.font=[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        //以下几个属性必须设置
        _bodyLabel.numberOfLines=0;
        _bodyLabel.textAlignment=NSTextAlignmentLeft;
        [_bodyLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    return _bodyLabel;
}

-(UILabel *)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel=[[UILabel alloc]initForAutoLayout];
        _userNameLabel.textColor=UserNameColor;
        _userNameLabel.font=[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
    }
    return _userNameLabel;
}

-(UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel=[[UILabel alloc]initForAutoLayout];
        _timeLabel.textColor=[UIColor grayColor];
        _timeLabel.font=[UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UIButton *)resendButton
{
    if (!_resendButton) {
        _resendButton = [[UIButton alloc]initForAutoLayout];
        _resendButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_resendButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [_resendButton setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    }
    return _resendButton;
}

-(NSMutableArray *)imageViewArray
{
    if (!_imageViewArray)
    {
        _imageViewArray=[[NSMutableArray alloc]init];
    }
    return _imageViewArray;
}

@end
