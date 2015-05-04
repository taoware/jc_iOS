//
//  GXLoginViewController.m
//  jycs
//
//  Created by appleseed on 2/6/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXLoginViewController.h"
#import "GXUserEngine.h"
#import "GXErrorDefs.h"
#import "SSKeychain.h"

@interface GXLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *login_Btn;
@end

@implementation GXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg"]];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self setupForDismissKeyboard];
    [self updateLoginButton];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* username = [defaults objectForKey:@"userLoggedIn"];
    NSString* password = [SSKeychain passwordForService:SERVICENAME account:username];
    self.usernameField.text = username;
    self.passwordField.text = password;
    
    [self updateLoginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackOpaque;
}


- (IBAction)login:(UIButton *)sender {
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    if (username&&password&&username.length&&password.length) {
        [self showHudInView:self.view hint:@"正在登陆"];
        [[GXUserEngine sharedEngine] asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, GXError *error) {
            [self hideHud];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(YES)];
            } else {
                NSLog(error.description);
                switch (error.errorCode) {
                    case GXErrorJCServerAuthenticationFailure:
                        TTAlertNoTitle(@"用户名、密码不匹配");
                        break;
                    case GXErrorServerNotReachable:
                        TTAlertNoTitle(@"服务器连接失败");
                        break;
                    case GXErrorEaseMobAuthenticationFailure:
                        TTAlertNoTitle(@"环信：用户名或密码错误");
                        break;
                    default:
                        TTAlertNoTitle(@"登陆失败");
                        break;
                }
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];

    }

}

- (void)updateLoginButton {
    if (!self.usernameField.text.length && !self.passwordField.text.length) {
        self.login_Btn.enabled = NO;
        self.login_Btn.alpha = .8;
    } else {
        self.login_Btn.enabled = YES;
        self.login_Btn.alpha = 1;
    }
}

#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.passwordField) {
        self.passwordField.text = @"";
    }
    [self updateLoginButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    return YES;
}



@end
