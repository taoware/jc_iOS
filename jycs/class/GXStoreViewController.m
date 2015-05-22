//
//  GXStoreViewController.m
//  jycs
//
//  Created by appleseed on 3/26/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXStoreViewController.h"
#import "GXCoverFlowCollectionViewCell.h"
#import "GXStoreShowTableViewCell.h"
#import "GXStoreTableViewController.h"
#import "GXCoreDataController.h"
#import "GXStoreEngine.h"
#import "Store.h"
#import "Photo.h"
#import "ResourceFetcher.h"
#import "GXArticleViewController.h"
#import "GXStoreCarouselView.h"

@interface GXStoreViewController () <UITableViewDataSource,UITableViewDelegate, GXStoreShowTableViewCellDelegate>
@property (weak, nonatomic)IBOutlet UITableView *storeTableView;
@property (nonatomic, strong)GXStoreCarouselView* carouselView;
@property (nonatomic, strong)NSArray* slideStores;
@property (nonatomic, strong)NSArray* stores;
@property (nonatomic, strong)NSArray* provinces;
@property (nonatomic, strong)NSDictionary* storesInProvince;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation GXStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.storeTableView.tableHeaderView = self.carouselView;
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    [[GXStoreEngine sharedEngine] startSync];
    
    [self updateUI];
}

- (void)updateUI {
    [self loadRecordsFromCoreData];
    [self.storeTableView reloadData];
    self.carouselView.stores = self.slideStores;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_STORESYNCCOMPLETED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self updateUI];
    }];
    
}

- (GXStoreCarouselView *)carouselView {
    if (!_carouselView) {
        _carouselView = [[GXStoreCarouselView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        __block GXStoreViewController* weakSelf = self;
        [_carouselView setDidSelectBlock:^(GXCarouselItem *item, NSInteger index) {
            Store* store = weakSelf.slideStores[index];
            [weakSelf didSelectStore:store];
        }];
    }
    return _carouselView;
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
        [self loadSlideStoreFromCoreData];
        [self loadDistinctProvinceFromCoreData];
        [self loadStoresInProvinceFromCoreData];
        
    }];
}

- (void)loadSlideStoreFromCoreData {
    // load slide store
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"slideshow"];
    request.predicate = predicate;
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
    self.slideStores = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)loadDistinctProvinceFromCoreData {
    // load store by province
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"province"]];
    fetchRequest.returnsDistinctResults = YES;
    
    // Now it should yield an NSArray of distinct values in dictionaries.
    NSArray *dictionaries = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    self.provinces = [dictionaries valueForKey:STORE_PROVINCE];
}

- (void)loadStoresInProvinceFromCoreData {
    NSMutableDictionary* storesInProvince = [[NSMutableDictionary alloc]init];
    for (NSString* province in self.provinces) {
        NSError *error = nil;
        NSArray* stores = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"province = %@", province];
        request.predicate = predicate;
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
        stores = [self.managedObjectContext executeFetchRequest:request error:&error];
        [storesInProvince setValue:stores forKey:province];
    }
    self.storesInProvince = storesInProvince;
}

#pragma mark - table view delegate 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.provinces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GXStoreShowTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"storeShowCell" forIndexPath:indexPath];
    NSString* province = self.provinces[indexPath.section];
    NSArray* stores = [self.storesInProvince valueForKey:province];
    cell.regionLabel.text = province;
    cell.delegate = self;
    cell.stores = stores;
    
    cell.firstStoreLabel.text = nil;
    cell.firstStoreThumbnail.image = nil;
    cell.secondStoreLabel.text = nil;
    cell.secondStoreThumbnail.image = nil;
    cell.thirdStoreLabel.text = nil;
    cell.thirdStoreThumbnail.image = nil;
    
    NSUInteger numToDisplay = MIN(stores.count, 3);
    for (int i =0; i < numToDisplay; i++) {
        Store* store = stores[i];
        UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
        switch (i) {
            case 0:
                cell.firstStoreLabel.text = store.storeName;
                [cell.firstStoreThumbnail setImageWithURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            case 1:
                cell.secondStoreLabel.text = store.storeName;
                [cell.secondStoreThumbnail setImageWithURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            case 2:
                cell.thirdStoreLabel.text = store.storeName;
                [cell.thirdStoreThumbnail setImageWithURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            default:
                break;
        }
    }

    return cell;
}

- (void)didSelectStore:(Store *)store {
    GXArticleViewController* articleVC = [[GXArticleViewController alloc]init];
    articleVC.articleUrl = store.url;
    [self.navigationController pushViewController:articleVC animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIView* view = sender;
    if ([segue.identifier isEqualToString:@"goToStoresInProvince"]) {
        CGPoint pointInTable = [view convertPoint:view.bounds.origin toView:self.storeTableView];
        NSIndexPath *indexPath = [self.storeTableView indexPathForRowAtPoint:pointInTable];
        GXStoreTableViewController* storeTableVC = segue.destinationViewController;
        storeTableVC.province = self.provinces[indexPath.section];
        storeTableVC.storeInProvince = [self.storesInProvince valueForKey:storeTableVC.province];
    }
}


@end
