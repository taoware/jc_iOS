//
//  GXGoLoginViewController.m
//  jycs
//
//  Created by appleseed on 5/27/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXGoLoginViewController.h"
#import "GXUserEngine.h"

@interface GXGoLoginViewController ()

@end

@implementation GXGoLoginViewController

- (IBAction)goToLoginPage:(UIButton *)sender {
    [GXUserEngine sharedEngine].userLoggedIn = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(NO)];
}


@end
