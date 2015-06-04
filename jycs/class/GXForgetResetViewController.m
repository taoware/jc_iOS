//
//  GXForgetResetViewController.m
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXForgetResetViewController.h"
#import "GXUserEngine.h"

@interface GXForgetResetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *conformField;
@end

@implementation GXForgetResetViewController

- (IBAction)doneWithReset:(UIBarButtonItem *)sender {
    NSString* password = self.passwordField.text;
    NSString* conformPass = self.conformField.text;
    if (![password isEqualToString:conformPass]) {
        TTAlertNoTitle(@"两次密码不相同");
        return ;
    } else if (![self validatePassword:password]) {
        TTAlertNoTitle(@"密码要求6-16位，至少1个数字，1个字母");
        return;
    } else {
        [self showHudInView:self.view hint:@"正在重置"];
        [[GXUserEngine sharedEngine] asyncPasswordForgotWithMobile:self.mobile NewPass:password completion:^(GXError *error) {
            [self hideHud];
            if (!error) {
                [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            } else {
                switch (error.errorCode) {
                    case GXErrorServerNotReachable:
                        TTAlertNoTitle(@"服务器连接失败");
                        break;
                    default:
                        TTAlertNoTitle(error.description);
                        break;
                }
            }
        }];
    }
}

- (BOOL)validatePassword:(NSString *)password {
    BOOL result;
    
    NSString *passwordRegex =@"^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+){6,16}$";
    NSPredicate *passwordPred = [NSPredicate predicateWithFormat:@"%@ MATCHES %@", password, passwordRegex];
    result = [passwordPred evaluateWithObject:passwordRegex];
    
    return result;
}
@end
