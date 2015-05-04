//
//  DeleteableCTAssetsPageViewController.m
//  jycs
//
//  Created by appleseed on 4/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "DeleteableCTAssetsPageViewController.h"

@implementation DeleteableCTAssetsPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImageAtIndex)];
}

- (void)deleteImageAtIndex {
    if ([self.delegator respondsToSelector:@selector(deleteImageAtIndex:)]) {
        [self.delegator deleteImageAtIndex:self.pageIndex];
    }
}

@end
