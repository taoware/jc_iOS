//
//  GXPostedViewController.m
//  jycs
//
//  Created by appleseed on 3/19/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPostedViewController.h"
#import "SRRefreshView.h"
#import "GXCoreDataController.h"
#import "GXUserEngine.h"

@interface GXPostedViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong)UISearchBar* searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic)NSArray* moments;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation GXPostedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self initData];
}

- (void)initData {
//    [self loadNewsRecordsFromCoreData];
    [self.tableView reloadData];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height) style:UITableViewStylePlain];
        //        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"OfficeCell"];
    }
    
    return _tableView;
}

//- (void)loadNewsRecordsFromCoreData {
//    [self.managedObjectContext performBlockAndWait:^{
//        [self.managedObjectContext reset];
//        NSError *error = nil;
//        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Moments"];
//        NSString* myObjectId = [GXUserEngine checkForCurrentUser].objectId;
//        request.predicate = [NSPredicate predicateWithFormat:@"fromUser.objectId == %@", myObjectId];
//        [request setSortDescriptors:[NSArray arrayWithObject:
//                                     [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
//        self.moments = [self.managedObjectContext executeFetchRequest:request error:&error];
//    }];
//}
//
//#pragma mark - table view delegate
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 154.0f;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//}
//
//#pragma mark - table view datasoure
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.moments.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
//    GXSquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"GXSquareTableViewCell" owner:self options:nil];
//        cell = [array objectAtIndex:0];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//    
////    Moments* moment = self.moments[indexPath.row];
////    cell.head.image = [UIImage imageNamed:@"u55"];
////    cell.title.text = moment.fromUser.realName;
////    cell.desc.text = moment.subject;
////    cell.date.text = [self.dateFormatter stringFromDate:moment.createdAt];
////    [cell.photo1 setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:moment.thumbnail1]] placeholderImage:nil success:NULL failure:NULL];
////    [cell.photo2 setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:moment.thumbnail2]] placeholderImage:nil success:NULL failure:NULL];
////    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    
//    return cell;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
