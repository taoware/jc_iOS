//
//  GXPhotoItemViewController.m
//  jycs
//
//  Created by appleseed on 5/15/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPhotoItemViewController.h"
#import "GXPhotoScrollView.h"

@implementation GXPhotoItemViewController

+ (GXPhotoItemViewController *)photoItemViewControllerForPageIndex:(NSInteger)pageIndex
{
    return [[self alloc] initWithPageIndex:pageIndex];
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    if (self = [super init])
    {
        self.pageIndex = pageIndex;
    }
    
    return self;
}


- (void)loadView
{
    GXPhotoScrollView *scrollView   = [[GXPhotoScrollView alloc] init];
    scrollView.dataSource           = self.dataSource;
    scrollView.index                = self.pageIndex;
    
    self.view = scrollView;
}


@end
