//
//  GXResetPasswordViewController.m
//  jycs
//
//  Created by appleseed on 3/13/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXResetPasswordViewController.h"
#import "GXUserEngine.h"

@interface GXResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPassField;
@property (weak, nonatomic) IBOutlet UITextField *PassField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmField;

@end

@implementation GXResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)comfirmReset:(id)sender {
    NSString* oldPass = self.oldPassField.text;
    NSString* newPass = self.PassField.text;
    NSString* comfirmPass = self.comfirmField.text;
    
    if (!oldPass.length || !newPass || !comfirmPass) {
        [[[UIAlertView alloc]initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [self showHudInView:self.view hint:@"正在重置"];
    [[GXUserEngine sharedEngine] asyncResetPasswordWithOldPass:oldPass andNewPass:newPass  completion:^(NSDictionary *resetInfo, GXError *error) {
        [self hideHud];
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            switch (error.errorCode) {
                case GXErrorOldPasswordInvalid:
                    TTAlert(@"原密码错误");
                    break;
                case GXErrorServerNotReachable:
                    TTAlert(@"服务器连接失败");
                    break;
                default:
                    TTAlert(@"密码重置失败");
                    break;
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
