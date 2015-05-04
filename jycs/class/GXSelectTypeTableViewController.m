//
//  GXSelectTypeTableViewController.m
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSelectTypeTableViewController.h"

@interface GXSelectTypeTableViewController ()
@property (nonatomic, strong)NSArray* typeArray;
@property (nonatomic, strong)NSArray* typeDescriptionArray;
@end

@implementation GXSelectTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送至";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedSelectType)];
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
    cell.textLabel.text = [[self typeArray] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];  // not working, maybe because of chinese character
    cell.detailTextLabel.text = [[self typeDescriptionArray] objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if ([self.currentType isEqualToString:[[self typeArray] objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger typeIndex = [self.typeArray indexOfObject:self.currentType];
    if (typeIndex == indexPath.row) {
        return;
    }
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:typeIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentType = [self.typeArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
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
        _typeArray = @[@"员工广场", @"联采广场", @"供应商广场"];
    }
    return _typeArray;
}

- (NSArray *)typeDescriptionArray {
    if (!_typeDescriptionArray) {
        _typeDescriptionArray = @[
                                  @"所选单位的员工均可见",
                                  @"全国联采业务员均可见",
                                  @"仅供应商可见"
                                  ];
    }
    return _typeDescriptionArray;
}

#pragma mark - action

- (void)finishedSelectType {
    self.addMomentVC.type = self.currentType;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
