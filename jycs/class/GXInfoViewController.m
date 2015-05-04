//
//  GXInfoViewController.m
//  jycs
//
//  Created by appleseed on 4/3/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXInfoViewController.h"

@interface GXInfoViewController ()

@end

@implementation GXInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showStoreInfo {
    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController* storeVC = [story instantiateViewControllerWithIdentifier:@"storeVC"];
    [self.navigationController pushViewController:storeVC animated:YES];
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
