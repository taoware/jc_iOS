//
//  GXGoToLoginViewController.m
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXGoToLoginViewController.h"
#import "GXUserEngine.h"

@implementation GXGoToLoginViewController

- (IBAction)goToLoginPage:(UIButton *)sender {
    [GXUserEngine sharedEngine].userLoggedIn = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(NO)];
}


@end
