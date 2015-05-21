//
//  GXPhotoPageViewController.h
//  jycs
//
//  Created by appleseed on 5/15/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@protocol GXPhotoPageViewControllerDelegate;

/**
 *  A view controller that shows selected photos and vidoes from user's photo library that let the user navigate the item page by page.
 */
@interface GXPhotoPageViewController : UIPageViewController

/**
 *  The index of the photo or video with the currently showing item.
 */
@property (nonatomic, assign) NSInteger pageIndex;


/**
 *  @name Creating a Photos Page View Controller
 */

/**
 *  Initializes a newly created view controller with an array of photo items.
 *
 *  @param An array of Photo objects.
 *
 *  @return An instance of `GXPhotoPageViewController` initialized to show the image items in `Photos`.
 */
- (id)initWithPhotos:(NSArray *)photos;

- (id)initWithMomoent:(Moment *)moment;

@end
