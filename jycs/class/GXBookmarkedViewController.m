//
//  GXBookmarkedViewController.m
//  jycs
//
//  Created by appleseed on 5/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXBookmarkedViewController.h"
#import "GXCoreDataController.h"
#import "GXNotificationTableViewCell.h"
#import "Notification.h"

@interface GXBookmarkedViewController ()
@property (nonatomic, strong)NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
@property (nonatomic, strong)NSArray* notifications;
@end

@implementation GXBookmarkedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;

    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self loadNotificationFromCoreData];
    [self.tableView reloadData];
}

- (void)loadNotificationFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isFavorite = YES"];
        request.predicate = predicate;
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        self.notifications = [self.managedObjectContext executeFetchRequest:request error:&error];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     GXNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkCell" forIndexPath:indexPath];
 
 // Configure the cell...
     Notification* notification = [self.notifications objectAtIndex:indexPath.row];
     cell.notification = notification;
 
 return cell;
 }

@end
