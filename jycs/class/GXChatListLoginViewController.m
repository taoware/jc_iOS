//
//  GXChatListLoginViewController.m
//  jycs
//
//  Created by appleseed on 5/11/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXChatListLoginViewController.h"
#import "XLPagerTabStripViewController.h"

@implementation GXChatListLoginViewController

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"消息";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor blackColor];
}

@end
