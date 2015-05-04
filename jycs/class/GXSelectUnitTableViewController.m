//
//  GXSelectUnitTableViewController.m
//  jycs
//
//  Created by appleseed on 4/23/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSelectUnitTableViewController.h"
#import "Unit.h"
#import "GXUserEngine.h"
#import "GXCoreDataController.h"

@interface GXSelectUnitTableViewController ()
@property (nonatomic, strong)NSArray* unitArray;
@property (nonatomic, strong)Unit* currentUnit;
@end

@implementation GXSelectUnitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送单位";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedSelectUnit)];
}

#pragma mark - properties

- (NSArray *)unitArray {
    if (!_unitArray) {
        NSManagedObjectContext* manageObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
        [manageObjectContext performBlockAndWait:^{
//            [manageObjectContext reset];
            
            NSSet *units = [GXUserEngine sharedEngine].userLoggedIn.inUnit;
            _unitArray = [units allObjects];
        }];
    }
    return _unitArray;
}

- (void)setUnitidSelected:(NSNumber *)unitidSelected {
    _unitidSelected = unitidSelected;
    for (Unit* unit in self.unitArray) {
        if ([unit.objectId isEqualToNumber:unitidSelected]) {
            self.currentUnit = unit;
        }
    }
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
    
    if (self.currentUnit) {
        if ([self.unitidSelected isEqualToNumber:self.currentUnit.objectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger typeIndex = [self.unitArray indexOfObject:self.currentUnit];
    if (typeIndex == indexPath.row) {
        return;
    }
    NSIndexPath* oldIndexPath = [NSIndexPath indexPathForRow:typeIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentUnit = [self.unitArray objectAtIndex:indexPath.row];
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


#pragma mark - action

- (void)finishedSelectUnit {
    self.addMomentVC.unitId = [self.currentUnit.objectId integerValue];
    self.addMomentVC.unitName = self.currentUnit.name;
    self.addMomentVC.unit = self.currentUnit;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
