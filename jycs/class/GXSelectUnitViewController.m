//
//  GXSelectUnitTableViewController.m
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSelectUnitViewController.h"
#import "Unit.h"
#import "GXUserEngine.h"
#import "GXCoreDataController.h"

@interface GXSelectUnitViewController ()
@property (nonatomic, strong)NSArray* unitArray;
@end

@implementation GXSelectUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送单位";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    [self toggleDoneButton];
}

- (void)toggleDoneButton {
    self.navigationItem.rightBarButtonItem.enabled = self.unit?YES:NO;
}

#pragma mark - properties

- (NSArray *)unitArray {
    if (!_unitArray) {
        [self.context performBlockAndWait:^{
            User* userLoggedIn = (User*)[self.context objectWithID:[GXUserEngine sharedEngine].userLoggedIn.objectID];
            NSSet *units = userLoggedIn.inUnit;
            _unitArray = [units allObjects];
        }];
    }
    return _unitArray;
}

#pragma mark - table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self unitArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TypeSelectCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    Unit* unit = [self.unitArray objectAtIndex:indexPath.row];
    cell.textLabel.text = unit.name;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];  // not working, maybe because of chinese character
    cell.detailTextLabel.text = unit.uriName;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if (self.unit) {
        if ([self.unit.objectId isEqualToNumber:unit.objectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger typeIndex = [self.unitArray indexOfObject:self.unit];
    if (typeIndex == indexPath.row) {
        return;
    }
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:typeIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.unit = [self.unitArray objectAtIndex:indexPath.row];
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


#pragma mark - action

- (void)doneButtonTapped {
    [self.delegate didFinishSelectUnit:self.unit];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
