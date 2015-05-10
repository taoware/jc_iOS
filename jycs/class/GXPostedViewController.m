//
//  GXPostedViewController.m
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPostedViewController.h"
#import "GXCoreDataController.h"
#import "GXUserEngine.h"
#import "Moment.h"
#import "GXPostedTableViewCell.h"

@interface GXPostedViewController ()
@property (nonatomic, strong)NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong)NSArray* moments;
@end

@implementation GXPostedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的发布";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    [self loadMomentsFromCoreData];
    [self.tableView reloadData];
}

- (void)loadMomentsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GXPostedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postedMomentCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Moment* moment = [self.moments objectAtIndex:indexPath.row];
    cell.momentToDisplay = moment;
    
    return cell;
}

@end
