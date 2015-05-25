//
//  GXSettingTableViewController.m
//  jycs
//
//  Created by appleseed on 3/13/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSettingTableViewController.h"
#import "GXUserEngine.h"
#import "GXResetPasswordViewController.h"
#import "SSKeychain.h"

@interface GXSettingTableViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@end

@implementation GXSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.logoutCell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.logoutCell.textLabel.text, [GXUserEngine sharedEngine].userLoggedIn.mobile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"确定退出?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil]show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self showHudInView:self.view hint:@"正在登出"];
        [[GXUserEngine sharedEngine] asyncLogoutWithCompletion:^(NSDictionary *info, GXError *error) {
            [self hideHud];
            if (error) {
                NSLog(@"%@", error.description);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(NO)];
        }];
    }
}


@end
