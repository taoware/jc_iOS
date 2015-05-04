//
//  AppDelegate.h
//  jycs
//
//  Created by appleseed on 2/2/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXMainTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    EMConnectionState _connectionState;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GXMainTabBarViewController* mainController;
@end

