//
//  GXMyMomentsViewController.m
//  jycs
//
//  Created by appleseed on 5/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMyMomentsViewController.h"
#import "GXMomentsTableViewCell.h"
#import "GXCoreDataController.h"
#import "GXUserEngine.h"

static NSString *CellIdentifier = @"MomentsCellIdentifier";

@interface GXMyMomentsViewController ()
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (strong, nonatomic) NSArray* moments;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation GXMyMomentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsSelection = NO;
    
    self.title = @"我的发布";
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    [self.tableView registerClass:[GXMomentsTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] masterManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self loadMomentsFromCoreData];
}

- (void)loadMomentsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Moment"];
        User* userLoggedIn = [GXUserEngine sharedEngine].userLoggedIn;
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"sender.objectId == %@", userLoggedIn.objectId];
        request.predicate = predicate;
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
        self.moments = [self.managedObjectContext executeFetchRequest:request error:&error];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.moments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXMomentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    
    Moment* moment = self.moments[indexPath.row];
    cell.fromViewController = self;
    cell.momentToDisplay = moment;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *reuseIdentifier = CellIdentifier;
    
    GXMomentsTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[GXMomentsTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    Moment* moment =[self.moments objectAtIndex:indexPath.row];
    cell.momentToDisplay = moment;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Moment* moment =[self.moments objectAtIndex:indexPath.row];
    if (moment.photo.count == 0) {
        return 89.0f;
    } else if (moment.photo.count>0 && moment.photo.count <4) {
        return 164.0f;
    } else if (moment.photo.count>3 && moment.photo.count <7) {
        return 244.0f;
    } else if (moment.photo.count>6 && moment.photo.count <10) {
        return 324.0f;
    }
    return 100.0f;
}



@end
