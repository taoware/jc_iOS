//
//  GXPostViewController.m
//  jycs
//
//  Created by appleseed on 3/19/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPostViewController.h"
#import "GXHTTPManager.h"
#import "GXUserEngine.h"
#import "GXMomentsEngine.h"

@interface GXPostViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation GXPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)send:(UIButton *)sender {
    if (self.textField.text.length) {
        User* user = [[GXUserEngine sharedEngine] userLoggedIn];

        NSDictionary* jsonDic = [[NSMutableDictionary alloc]init];
        [jsonDic setValue:@(self.category) forKey:@"category"];

        [jsonDic setValue:@{@"__type": @"Pointer", @"className": @"_User", @"objectId": [user valueForKey:@"objectId"]} forKey:@"user"];
        [jsonDic setValue:self.textField.text forKey:@"subject"];
        [self showHudInView:self.view hint:@"正在发送"];
        [[GXHTTPManager sharedManager] POST:@"classes/Moments" parameters:jsonDic success:^(NSURLSessionDataTask *task, id responseObject) {
            [self hideHud];
            TTAlert(@"sent sucessfully");
            [[GXMomentsEngine sharedEngine] startSync];
//            NSLog(@"%@", responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            NSLog(@"%@", [[error userInfo] objectForKey:@"kErrorResponseObjectKey"]);
            TTAlert([[error userInfo] objectForKey:@"kErrorResponseObjectKey"]);
        }];
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
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
