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

@interface GXUserInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *regionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *positionCell;
@property (strong, nonatomic) UIView* footerView;
@property (strong, nonatomic) UIButton* contactButton;
@end

@implementation GXUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详细资料";
    self.tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User* user = self.moment.sender;
    [self.avatar setImageWithURL:[NSURL URLWithString:user.avatar.thumbnailURL] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    self.name.text = user.name;
    self.screenName.text = self.moment.screenName;
    
    self.phoneCell.detailTextLabel.text = user.mobile;
    self.regionCell.detailTextLabel.text = user.location;
    self.positionCell.detailTextLabel.text = self.moment.screenName;

}

- (UIButton *)contactButton {
    if (_contactButton == nil) {
        _contactButton = [[UIButton alloc] init];
        [_contactButton setTitle:@"发消息" forState:UIControlStateNormal];
        [_contactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactButton addTarget:self action:@selector(contactAction) forControlEvents:UIControlEventTouchUpInside];
        [_contactButton setBackgroundColor: [UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:205 / 255.0 alpha:1.0]];
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
    User* user = self.moment.sender;
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
