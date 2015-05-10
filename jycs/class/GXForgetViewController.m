//
//  GXForgetViewController.m
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXForgetViewController.h"
#import "JKCountDownButton.h"
#import "GXForgetResetViewController.h"

@interface GXForgetViewController ()
@property (nonatomic, strong)NSString* verificationCode;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *verificationField;
@property (strong, nonatomic) NSString* mobile;
@end

@implementation GXForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)countDownXibTouched:(JKCountDownButton*)sender {
    sender.enabled = NO;
    //button type要 设置成custom 否则会闪动
    [sender startWithSecond:60];
    self.mobile = self.phoneField.text;
    self.verificationCode = [self generateRandom4DigitCode];
    NSString* message = [NSString stringWithFormat:@"您本次身份校验码是%@, 30分钟内有效，教育超市工作人员绝不会向您索取此校验码，切勿告知他人", self.verificationCode];
    NSString* url = [NSString stringWithFormat:@"http://vps1.taoware.com/notify?mobile=%@&message=%@", self.mobile, message];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
        return title;
    }];
    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        return @"点击重新获取";
        
    }];
}

- (NSString *)generateRandom4DigitCode {
    int randomNum = arc4random_uniform(10000);
    return [NSString stringWithFormat:@"%04d", randomNum];
}

- (BOOL)verifyCode:(NSString *)code {
    BOOL result = NO;
    
    if ([self.verificationCode isEqualToString:code]) {
        result = YES;
    }
    
    return YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"go reset password"]) {
        if (![self verifyCode:self.verificationField.text]) {
            TTAlert(@"验证码错误");
            return NO;
        }
        if (self.phoneField.text.length != 11) {
            TTAlert(@"手机格式错误");
            return NO;
        }
    }
    return YES;
}


@end
