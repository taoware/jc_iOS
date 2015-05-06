//
//  GXContactViewController.m
//  jycs
//
//  Created by appleseed on 5/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXContactViewController.h"
#import "AddFriendViewController.h"

@implementation GXContactViewController
- (void)addFriendAction
{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:addController animated:YES];
}
@end
