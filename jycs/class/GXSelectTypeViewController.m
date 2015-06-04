//
//  GXSelectTypeTableViewController.m
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSelectTypeViewController.h"
#import "GXUserEngine.h"
#import "User+Permission.h"

@interface GXSelectTypeViewController ()
@property (nonatomic, strong)NSMutableArray* typeArray;
@end

@implementation GXSelectTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送至";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    [self toggleDoneButton];
}

- (void)toggleDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = self.type?YES:NO;
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self typeArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TypeSelectCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString* type = [[self typeArray] objectAtIndex:indexPath.row];
    cell.textLabel.text = type;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];  // not working, maybe because of chinese character
    cell.detailTextLabel.text = [self typeDescriptionForType:type];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if ([self.type isEqualToString:[[self typeArray] objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger typeIndex = [self.typeArray indexOfObject:self.type];
    if (typeIndex == indexPath.row) {
        return;
    }
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:typeIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.type = [self.typeArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self toggleDoneButton];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

#pragma mark - properties

- (NSArray *)typeArray {
    if (!_typeArray) {
        _typeArray = [[NSMutableArray alloc]init];
//        User* user = [GXUserEngine sharedEngine].userLoggedIn;
//        if ([user canSendMomentForEmployee]) {
            [_typeArray addObject:@"员工广场"];
//        }
//        if ([user canSendMomentForPurchase]) {
            [_typeArray addObject:@"联采广场"];
//        }
//        if ([user canSendMomentForSupplier]) {
            [_typeArray addObject:@"供应商广场"];
//        }
    }
    return _typeArray;
}

- (NSString *)typeDescriptionForType:(NSString *)type {
    NSDictionary* typeDic = @{@"员工广场": @"发给员工的信息",
                              @"联采广场": @"发给联采业务员的信息",
                              @"供应商广场": @"发给供应商的信息"};
    return typeDic[type];
}

#pragma mark - action

- (void)doneButtonTapped {
    [self.delegate didFinishSelectType:[self.type substringToIndex:self.type.length-2]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
