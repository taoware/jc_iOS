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
                switch (error.errorCode) {
                    case GXErrorJCServerAuthenticationFailure:
                        TTAlertNoTitle(error.description);
                        break;
                    case GXErrorServerNotReachable:
                        TTAlertNoTitle(@"服务器连接失败");
                        break;
                    case GXErrorEaseMobAuthenticationFailure:
                        TTAlertNoTitle(@"服务器内部错误");
                        break;
                    default:
                        TTAlertNoTitle(error.description);
                        break;
                }
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"信息不完整"
                                    message:@"请填写手机号及密码！"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];

    }

}

- (IBAction)visitAsGuest:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(YES)];
}


- (void)updateLoginButton {
    if (!self.usernameField.text.length || !self.passwordField.text.length) {
        self.login_Btn.enabled = NO;
        self.login_Btn.alpha = .8;
    } else {
        self.login_Btn.enabled = YES;
        self.login_Btn.alpha = 1;
    }
}

#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self updateLoginButton];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateLoginButton];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateLoginButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    return YES;
}



@end
