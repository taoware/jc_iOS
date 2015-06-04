//
//  GXUserInfoViewController.m
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXUserInfoViewController.h"
#import "User.h"
#import "Photo.h"
#import "ChatViewController.h"
#import "GXUserEngine.h"

@interface GXUserInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *positionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *companyCell;
@property (strong, nonatomic) UIView* footerView;
@property (strong, nonatomic) UIButton* contactButton;
@end

@implementation GXUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料";
    self.tableView.allowsSelection = NO;
    self.tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    User* user;
    if (self.moment) {
        user = self.moment.sender;
    }
    
    if (self.buddy) {
        user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:self.buddy.username];
    }
    [self.avatar setImageWithURL:[NSURL URLWithString:user.avatar.thumbnailURL] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    self.nameLabel.text = user.name;
    self.companyLabel.text = user.address;
    
    self.phoneCell.detailTextLabel.text = user.mobile;
    self.nameCell.detailTextLabel.text = user.name;
    self.positionCell.detailTextLabel.text = user.position;
    self.companyCell.detailTextLabel.text = user.address;
}

- (UIButton *)contactButton {
    if (_contactButton == nil) {
        _contactButton = [[UIButton alloc] init];
        [_contactButton setTitle:@"发消息" forState:UIControlStateNormal];
        [_contactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactButton addTarget:self action:@selector(contactAction) forControlEvents:UIControlEventTouchUpInside];
        [_contactButton setBackgroundColor: [UIColor colorWithRed:36.0/255.0 green:148.0/255.0 blue:96.0/255.0 alpha:1.0]];
    }
    
    return _contactButton;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        self.contactButton.frame = CGRectMake(20, 20, _footerView.frame.size.width - 40, 50);
        [_footerView addSubview:self.contactButton];
    }
    return _footerView;
}

- (void)contactAction {
    User* user;
    if (self.moment) {
        user = self.moment.sender;
    }
    if (self.buddy) {
        user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:self.buddy.username];
    }
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if (loginUsername && loginUsername.length > 0) {
        if ([loginUsername isEqualToString:user.imUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
    }

    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:user.imUsername isGroup:NO];
    chatController.title = user.name;
    [self.navigationController pushViewController:chatController animated:YES];
}

@end
