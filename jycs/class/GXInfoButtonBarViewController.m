//
//  GXButtonBarViewController.m
//  jycs
//
//  Created by appleseed on 3/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXInfoButtonBarViewController.h"
#import "GXInfoNewsViewController.h"
#import "GXInfoChatListViewController.h"
#import "GXInfoNotificationViewController.h"
#import "AppDelegate.h"
#import "GXUserEngine.h"
#import "GXChatListLoginViewController.h"
#import "GXNotificationLoginViewController.h"

@interface GXInfoButtonBarViewController ()

@end

@implementation GXInfoButtonBarViewController
{
    BOOL _isReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.buttonBarView.selectedBar setBackgroundColor:CUSTOMCOLOR];
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    UIViewController* child_2, *child_3;
    GXInfoNewsViewController * child_1 = [[GXInfoNewsViewController alloc] init];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if (![GXUserEngine sharedEngine].userLoggedIn.audit.boolValue) {
        child_2 = [story instantiateViewControllerWithIdentifier:@"chatListLogin"];
        child_3 = [story instantiateViewControllerWithIdentifier:@"notificationLogin"];
    } else {
        child_2 = [[GXInfoChatListViewController alloc] init];
        child_3 = [story instantiateViewControllerWithIdentifier:@"InfoNotificationViewController"];
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.mainController.chatListVC = (GXInfoChatListViewController *)child_2;
    }

    if (!_isReload){
        return @[child_1, child_2, child_3];
    }
    
    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_1, child_2, child_3, nil];
    NSUInteger count = [childViewControllers count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [childViewControllers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger nItems = 1 + (rand() % 8);
    return [childViewControllers subarrayWithRange:NSMakeRange(0, nItems)];
}

-(void)reloadPagerTabStripView
{
    _isReload = YES;
    [super reloadPagerTabStripView];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel * label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.font = self.buttonBarView.labelFont;
    UIViewController<XLPagerTabStripChildItem> * childController =   [self.pagerTabStripChildViewControllers objectAtIndex:indexPath.item];
    [label setText:[childController titleForPagerTabStripViewController:self]];
    CGSize labelSize = [label intrinsicContentSize];
    
    return CGSizeMake(100, collectionView.frame.size.height);
}


@end
