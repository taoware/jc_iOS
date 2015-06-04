//
//  GXPhotoPageViewController.m
//  jycs
//
//  Created by appleseed on 5/15/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPhotoPageViewController.h"
#import "GXPhotoItemViewController.h"
#import "GXPhotoScrollView.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "GXPhotoEngine.h"

@interface GXPhotoPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, GXPhotoItemViewControllerDataSource>
@property (nonatomic, strong) Moment *moment;
@property (nonatomic, assign, getter = isStatusBarHidden) BOOL statusBarHidden;
@end

@implementation GXPhotoPageViewController

- (id)initWithPhotos:(NSArray *)photos
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    if (self)
    {
        self.dataSource             = self;
        self.delegate               = self;
        self.view.backgroundColor   = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (id)initWithMomoent:(Moment *)moment {
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    if (self)
    {
        self.moment                 = moment;
        self.dataSource             = self;
        self.delegate               = self;
        self.view.backgroundColor   = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObserver];self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCurrentPhoto)];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}

- (BOOL)prefersStatusBarHidden
{
    return self.isStatusBarHidden;
}

- (void)deleteCurrentPhoto {
    NSString* photoURL;
    
    NSMutableOrderedSet* photos = [self.moment.photo mutableCopy];
    photoURL = [(Photo*)[photos objectAtIndex:self.pageIndex] imageURL];
    [photos removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:self.pageIndex]];
    self.moment.photo = photos;
    if (photos.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.pageIndex == photos.count) {
        self.pageIndex = self.pageIndex-1;
    } else {
        self.pageIndex = self.pageIndex;
    }
    
    [GXPhotoEngine deleteLocalPhotoWithURL:photoURL];
}

#pragma mark - Update Title

- (void)setTitleIndex:(NSInteger)index
{
    NSInteger count = self.moment.photo.count;
    self.title      = [NSString stringWithFormat:CTAssetsPickerControllerLocalizedString(@"%ld of %ld"), index, count];
}


#pragma mark - Page Index

- (NSInteger)pageIndex
{
    return ((GXPhotoItemViewController *)self.viewControllers[0]).pageIndex;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    NSInteger count = self.moment.photo.count;
    
    if (pageIndex >= 0 && pageIndex < count)
    {
        GXPhotoItemViewController *page = [GXPhotoItemViewController photoItemViewControllerForPageIndex:pageIndex];
        page.dataSource = self;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        [self setTitleIndex:pageIndex + 1];
    }
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((GXPhotoItemViewController *)viewController).pageIndex;
    
    if (index > 0)
    {
        GXPhotoItemViewController *page = [GXPhotoItemViewController photoItemViewControllerForPageIndex:(index - 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger count = self.moment.photo.count;
    NSInteger index = ((GXPhotoItemViewController *)viewController).pageIndex;
    
    if (index < count - 1)
    {
        GXPhotoItemViewController *page = [GXPhotoItemViewController photoItemViewControllerForPageIndex:(index + 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        GXPhotoItemViewController *vc   = (GXPhotoItemViewController *)pageViewController.viewControllers[0];
        NSInteger index                 = vc.pageIndex + 1;
        
        [self setTitleIndex:index];
    }
}


#pragma mark - Notification Observer

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(scrollViewTapped:)
                   name:GXPhotoScrollViewTappedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GXPhotoScrollViewTappedNotification object:nil];
}


#pragma mark - Tap Gesture

- (void)scrollViewTapped:(NSNotification *)notification
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)notification.object;
    
    if (gesture.numberOfTapsRequired == 1)
        [self toogleNavigationBar:gesture];
}


#pragma mark - Fade in / away navigation bar

- (void)toogleNavigationBar:(id)sender
{
    if (self.isStatusBarHidden)
        [self fadeNavigationBarIn];
    else
        [self fadeNavigationBarAway];
}

- (void)fadeNavigationBarAway
{
    self.statusBarHidden = YES;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self setNeedsStatusBarAppearanceUpdate];
                         [self.navigationController.navigationBar setAlpha:0.0f];
                         [self.navigationController setNavigationBarHidden:YES];
                         self.view.backgroundColor = [UIColor blackColor];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)fadeNavigationBarIn
{
    self.statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self setNeedsStatusBarAppearanceUpdate];
                         [self.navigationController.navigationBar setAlpha:1.0f];
                         self.view.backgroundColor = [UIColor whiteColor];
                     }];
}



#pragma mark - CTAssetItemViewControllerDataSource

- (Photo *)photoAtIndex:(NSUInteger)index;
{
    return [self.moment.photo objectAtIndex:index];
}


@end
