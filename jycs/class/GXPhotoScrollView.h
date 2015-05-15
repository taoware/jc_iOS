//
//  GXPhotoScrollView.h
//  jycs
//
//  Created by appleseed on 5/15/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXPhotoItemViewController.h"

extern NSString * const GXPhotoScrollViewTappedNotification;

@interface GXPhotoScrollView : UIScrollView

@property (nonatomic, weak) id<GXPhotoItemViewControllerDataSource> dataSource;
@property (nonatomic) NSUInteger index;

@end
