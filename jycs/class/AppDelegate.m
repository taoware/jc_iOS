//
//  AppDelegate.m
//  jycs
//
//  Created by appleseed on 2/2/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "AppDelegate.h"
#import "News.h"
#import "GXUserEngine.h"
#import "AppDelegate+EaseMob.h"
#import "SSKeychain.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // status bar appearance
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // navigation bar appearance
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:36.0/255.0 green:148.0/255.0 blue:96.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    // tabbar appearance
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       CUSTOMCOLOR, UITextAttributeTextColor,
                                                       nil] forState:UIControlStateHighlighted];
    [[UITabBar appearance] setTintColor:CUSTOMCOLOR];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    _connectionState = eEMConnectionConnected;
    
    // 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL autologin = [[defaults objectForKey:@"autoLogin"] boolValue];

    NSNotification* loginNotification = [NSNotification notificationWithName:@"autoLogin" object:@(YES)];
    NSString* username = [defaults objectForKey:@"userLoggedIn"];
    NSString* password = [SSKeychain passwordForService:SERVICENAME account:username];
    if (autologin && username && password) {
            if (!username.length || !password.length) {
                [self loginStateChange:nil];
            }

            [[GXUserEngine sharedEngine] asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, GXError *error) {
                if (!error) {
                    [self loginStateChange:loginNotification];
                } else {
                    switch (error.errorCode) {
                        case GXErrorAuthenticationFailure:
                            [[GXUserEngine sharedEngine] clearAutoLoginFlagInUserDefault];
                            [self loginStateChange:nil];
                            break;
                            
                        case GXErrorServerNotReachable:
                            [self loginStateChange:loginNotification];
                            break;
                        
                        case GXErrorEaseMobSeverError:
                            // had to enable easemob autologin, otherwise some callcack didn't get called
//                            TTAlert(@"即时通信功能暂时不可用");
                            [self loginStateChange:loginNotification];
                            break;
                        case GXErrorEaseMobAuthenticationFailure:
                            TTAlert(@"即时通信通能故障，请联系管理员");   
                            [self loginStateChange:loginNotification];
                            
                        default: {
                            [self loginStateChange:nil];
                            break;
                        }
                    }
                }
            }];
    } else {
        [self loginStateChange:nil];
    }
    
    
    [self.window setFrame:[[UIScreen mainScreen]bounds]];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)loginStateChange:(NSNotification *)notification {
    UINavigationController *nav = nil;
    
    BOOL loginSuccess = [notification.object boolValue];
    
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if (loginSuccess) {
        self.mainController = [story instantiateViewControllerWithIdentifier:@"mainVC"];
        nav = [[UINavigationController alloc]initWithRootViewController:self.mainController];
    } else {
        UIViewController* loginVC = [story instantiateViewControllerWithIdentifier:@"loginVC"];
        nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
    }

    self.window.rootViewController = nav;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
