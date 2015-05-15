//
//  GXPhotoItemViewController.h
//  jycs
//
//  Created by appleseed on 5/15/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol GXPhotoItemViewControllerDataSource;

@interface GXPhotoItemViewController : UIViewController

+ (GXPhotoItemViewController *)photoItemViewControllerForPageIndex:(NSInteger)pageIndex;

@property (nonatomic, weak) id<GXPhotoItemViewControllerDataSource> dataSource;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@protocol GXPhotoItemViewControllerDataSource <NSObject>
@required
- (Photo *)photoAtIndex:(NSUInteger)index;

@end
