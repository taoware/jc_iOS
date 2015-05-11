//
//  GXNotificationLoginViewController.m
//  jycs
//
//  Created by appleseed on 5/11/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXNotificationLoginViewController.h"
#import "XLPagerTabStripViewController.h"


@implementation GXNotificationLoginViewController

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"通知";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor blackColor];
}

@end
