//
//  DeleteableCTAssetsPageViewController.h
//  jycs
//
//  Created by appleseed on 4/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "CTAssetsPageViewController.h"

@protocol  DeleteableCTAssetsPageViewController<NSObject>

- (void)deleteImageAtIndex:(int)index;

@end

@interface DeleteableCTAssetsPageViewController : CTAssetsPageViewController
@property (nonatomic, strong)id<DeleteableCTAssetsPageViewController> delegator;
@end
