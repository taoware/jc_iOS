//
//  GXMomentsTableViewCell.h
//  jycs
//
//  Created by appleseed on 4/13/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"
#import "User.h"
#import "Photo.h"
#import "GXSyncHeader.h"

@protocol GXMomentsTableViewCellDelegate  <NSObject>

- (void)resendButtonTappedWithMoment:(Moment*)moment;
- (void)userInfoTappedWithMoment:(Moment *)moment;

@end

@interface GXMomentsTableViewCell : UITableViewCell

/**
 *  头像
 */
@property(nonatomic,strong)UIImageView* headImageView;


/**
 *  用户名
 */
@property(nonatomic,strong)UILabel* userNameLabel;


/**
 *  用户名
 */
@property(nonatomic,strong)UILabel* typeLabel;

/**
 *  多久发送的微博 e.g 1个小时前
 */
@property(nonatomic,strong)UILabel* timeLabel;
@property(nonatomic,strong)UIButton* resendButton;


@property(nonatomic,strong)Moment* momentToDisplay;
@property(nonatomic,strong)id<GXMomentsTableViewCellDelegate> delegate;

/**
 *  自适应label
 */
@property(nonatomic,strong)UILabel* bodyLabel;

@property(nonatomic,strong)UIViewController* fromViewController;

@property(nonatomic)GXObjectSyncStatus syncStatus;


-(void)setImageswithURLs:(NSArray*) urls;
-(void)setImageswithThumbnailURLs:(NSArray *)urlsOfThumbnail;


@end
