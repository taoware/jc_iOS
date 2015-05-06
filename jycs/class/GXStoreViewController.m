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

@interface GXStoreViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIView* coverFlowContainer;
@property (strong, nonatomic) UICollectionView *coverFlow;
@property (strong, nonatomic) UIView *carouselShadow;
@property (weak, nonatomic)IBOutlet UITableView *storeTableView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UILabel *coverTitle;
@property (nonatomic, strong)NSArray* slideStores;
@property (nonatomic, strong)NSArray* stores;
@property (nonatomic, strong)NSArray* provinces;
@property (nonatomic, strong)NSDictionary* storesInProvince;
@property (nonatomic ,strong)NSTimer* timer;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation GXStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(changeCover) userInfo:nil repeats:YES];
    
    self.storeTableView.tableHeaderView = self.coverFlowContainer;
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    [[GXStoreEngine sharedEngine] startSync];
    
    [self initData];
}

- (void)initData {
    [self loadRecordsFromCoreData];
    [self.storeTableView reloadData];
    [self reloadCoverFlow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_STORESYNCCOMPLETED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        
        [self.storeTableView reloadData];
        [self reloadCoverFlow];
        if (self.slideStores.count >= 2) {
            // scroll to the first page, note that this call will trigger scrollViewDidScroll: once and only once
            [self.coverFlow scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        Store* firstSlideStore = [self.slideStores firstObject];
        self.coverTitle.text = firstSlideStore.storeName;
        
    }];
    
}

- (void)reloadCoverFlow {
    if (!self.slideStores.count) {
        self.carouselShadow.hidden = true;
    } else {
        self.carouselShadow.hidden = NO;
    }
    self.pageControl.numberOfPages = self.slideStores.count-2;
    [self.coverFlow reloadData];
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
        [self loadSlideStoreFromCoreData];
        [self loadDistinctProvinceFromCoreData];
        [self loadStoresInProvinceFromCoreData];
        
        if (self.slideStores.count>=2) {
            // duplicate the last item and put it at first
            // duplicate the first item and put it at last
            id firstItem = [_slideStores firstObject];
            id lastItem = [_slideStores lastObject];
            NSMutableArray *workingArray = [_slideStores mutableCopy];
            [workingArray insertObject:lastItem atIndex:0];
            [workingArray addObject:firstItem];
            _slideStores = [NSArray arrayWithArray:workingArray];
        }
        
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


- (UIView *)coverFlowContainer {
    if (!_coverFlowContainer) {
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        // add coverflow to first page
        _coverFlowContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 160)];
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = CGSizeMake(viewWidth, 160);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.coverFlow = [[UICollectionView alloc]initWithFrame:_coverFlowContainer.bounds  collectionViewLayout:flowLayout];
        
        self.coverFlow.delegate = self;
        self.coverFlow.dataSource = self;
        self.coverFlow.pagingEnabled = YES;
        self.coverFlow.backgroundColor = nil;
        [self.coverFlow registerNib:[UINib nibWithNibName:@"GXCoverFlowCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CoverFlowCell"];
        self.coverFlow.showsHorizontalScrollIndicator = NO;
        self.coverFlow.showsVerticalScrollIndicator = NO;
        [_coverFlowContainer addSubview:self.coverFlow];
        
        self.carouselShadow = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.coverFlow.bounds)-25, viewWidth, 25)];
        self.carouselShadow.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"carousel_bg"]];
        self.carouselShadow.hidden = YES;
        [_coverFlowContainer addSubview:self.carouselShadow];
        
        self.coverTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.coverFlow.bounds)-25, viewWidth-70, 25)];
        self.coverTitle.textColor = [UIColor whiteColor];
        self.coverTitle.font = [UIFont systemFontOfSize:13];
        self.coverTitle.text = @"上海教育超市学生信的过的超市";
        [_coverFlowContainer addSubview:self.coverTitle];
        
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(viewWidth-70, CGRectGetHeight(self.coverFlow.bounds)-20, 70, 20)];
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        self.pageControl.numberOfPages = 6;
        [_coverFlowContainer addSubview:self.pageControl];
    }
    return _coverFlowContainer;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(15, 140, 80, 37)];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    }
    return _pageControl;
}

- (UILabel *)coverTitle {
    if (!_coverTitle) {
        _coverTitle = [[UILabel alloc]initWithFrame:CGRectMake(126, 140, 186, 21)];
        _coverTitle.textColor = [UIColor whiteColor];
        _coverTitle.text = @"上海教育超市学生信的过的超市";
    }
    return _coverTitle;
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
    
    NSUInteger numToDisplay = MIN(stores.count, 3);
    for (int i =0; i < numToDisplay; i++) {
        Store* store = stores[i];
        UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
        switch (i) {
            case 0:
                cell.firstStoreLabel.text = store.storeName;
                [cell.firstStoreThumbnail setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            case 1:
                cell.secondStoreLabel.text = store.storeName;
                [cell.secondStoreThumbnail setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            case 2:
                cell.thirdStoreLabel.text = store.storeName;
                [cell.thirdStoreThumbnail setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:store.photo.thumbnailURL] placeholderImage:placeholderImage];
                break;
            default:
                break;
        }
    }

    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.coverFlow.bounds.size;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.slideStores.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GXCoverFlowCollectionViewCell *cell = (GXCoverFlowCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CoverFlowCell" forIndexPath:indexPath];
    Store* store = self.slideStores[indexPath.row];
    UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];

    [cell.imageView setImageWithURL:[NSURL URLWithString:store.photo.imageURL] placeholderImage:placeholderImage];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        // Calculate where the collection view should be at the right-hand end item
        float contentOffsetWhenFullyScrolledRight = self.coverFlow.frame.size.width * ([self.slideStores count] -1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            // user is scrolling to the right from the last item to the 'fake' item 1.
            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            
            [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            // user is scrolling to the left from the first item to the fake 'item N'.
            // reposition offset to show the 'real' item N at the right end end of the collection view
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.slideStores count] -2) inSection:0];
            
            [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

        }
        
        NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
        if (page == 0) {
            page = self.slideStores.count-2;
        } else if (page == self.slideStores.count-1) {
            page = 0;
        } else {
            page--;
        }
        self.pageControl.currentPage = page;
        Store* currentStore = self.slideStores[page];
        self.coverTitle.text = currentStore.storeName;
        
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
        if (page == 0) {
            page = self.slideStores.count-2;
        } else if (page == self.slideStores.count-1) {
            page = 0;
        } else {
            page--;
        }
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}


#pragma mark - action 

- (void)changeCover {
    if (self.slideStores.count >= 2) {
        NSIndexPath* indexPath = (NSIndexPath*)[[self.coverFlow indexPathsForVisibleItems] firstObject];
        Store* currentStore = self.slideStores[indexPath.item];
        self.coverTitle.text = currentStore.storeName;
        if (indexPath.item == self.slideStores.count-1) {
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.coverFlow scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:indexPath.item+1 inSection:indexPath.section];
        [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
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
