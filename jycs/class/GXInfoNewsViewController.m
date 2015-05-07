//
//  GXInfoNewsViewController.m
//  jycs
//
//  Created by appleseed on 3/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXInfoNewsViewController.h"
#import "GXCoverFlowCollectionViewCell.h"
#import "NewsTableViewCell.h"
#import "News.h"
#import "Photo.h"
#import "GXCoreDataController.h"
#import "GXNewsEngine.h"
#import "SRRefreshView.h"
#import "XLPagerTabStripViewController.h"

@interface GXInfoNewsViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, XLPagerTabStripChildItem>
@property (nonatomic, strong) UIView* coverFlowContainer;
@property (nonatomic, strong) UICollectionView* coverFlow;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (strong, nonatomic) UIView *carouselShadow;
@property (nonatomic, strong) UILabel* coverTitle;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) UITableView* newsTableView;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (strong, nonatomic) NSArray *slideNews; // data source
@property (strong, nonatomic) NSArray* news;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation GXInfoNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.newsTableView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(changeCover) userInfo:nil repeats:YES];
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
//    [[GXNewsEngine sharedEngine] startSync];
    [self.slimeView setLoadingWithExpansion];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_NEWSSYNCCOMPLETED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadRecordsFromCoreData];
        
        [self.newsTableView reloadData];
        [self reloadCoverFlow];

        if (self.slideNews.count >= 2) {
            // scroll to the first page, note that this call will trigger scrollViewDidScroll: once and only once
            [self.coverFlow scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        News* firstSlideNews = [self.slideNews firstObject];
        self.coverTitle.text = firstSlideNews.title;
        
        [_slimeView endRefresh];
    }];

}

- (void)reloadCoverFlow {
    if (!self.slideNews.count) {
        self.carouselShadow.hidden = true;
    } else {
        self.carouselShadow.hidden = NO;
    }
    self.pageControl.numberOfPages = self.slideNews.count-2;
    [self.coverFlow reloadData];
}

- (void)loadRecordsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
        // load list news
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"News"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", @"listshow"];
        request.predicate = predicate;
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
        self.news = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        // load slide news
        predicate = [NSPredicate predicateWithFormat:@"type = %@", @"slideshow"];
        request.predicate = predicate;
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
        self.slideNews = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (self.slideNews.count>=2) {
            // duplicate the last item and put it at first
            // duplicate the first item and put it at last
            id firstItem = [_slideNews firstObject];
            id lastItem = [_slideNews lastObject];
            NSMutableArray *workingArray = [_slideNews mutableCopy];
            [workingArray insertObject:lastItem atIndex:0];
            [workingArray addObject:firstItem];
            _slideNews = [NSArray arrayWithArray:workingArray];
        }
        
    }];
}


- (UITableView *)newsTableView {
    if (!_newsTableView) {
        _newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _newsTableView.tableHeaderView = self.coverFlowContainer;
        _newsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _newsTableView.backgroundColor = NEWSBGCOLOR;
        _newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _newsTableView.delegate = self;
        _newsTableView.dataSource = self;
        [_newsTableView addSubview:self.slimeView];
    }
    return _newsTableView;
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
        self.carouselShadow.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"carousel_bg1"]];
        self.carouselShadow.hidden = YES;
        [_coverFlowContainer addSubview:self.carouselShadow];
        
        self.coverTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.coverFlow.bounds)-25, viewWidth-70, 25)];
        self.coverTitle.textColor = [UIColor whiteColor];
        self.coverTitle.font = [UIFont systemFontOfSize:13];
        [_coverFlowContainer addSubview:self.coverTitle];
        
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(viewWidth-70, CGRectGetHeight(self.coverFlow.bounds)-20, 70, 20)];
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        self.pageControl.numberOfPages = self.slideNews.count;
        [_coverFlowContainer addSubview:self.pageControl];
    }
    return _coverFlowContainer;
}

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}


#pragma mark - utility method

- (void)changeCoverFlowPage:(id)sender {
    static int count = 0;
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:count++%self.slideNews.count inSection:0];
    [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.news.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NewsCell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NewsTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    News* news = self.news[indexPath.row];
    UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
    [cell.icon setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:news.photo.thumbnailURL]] placeholderImage:placeholderImage success:NULL failure:NULL];
    
    cell.title.text = news.title;
    cell.desc.text = news.subtitle;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = nil;
    
    UIImageView* separatorLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separatorLineView.image = [UIImage imageNamed:@"newsCellSeperator"];
    [cell.contentView addSubview:separatorLineView];
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
    return _slideNews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GXCoverFlowCollectionViewCell *cell = (GXCoverFlowCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CoverFlowCell" forIndexPath:indexPath];
    
    News *news = self.slideNews[indexPath.item];
    UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];

    [cell.imageView setImageWithURL:[NSURL URLWithString:news.photo.imageURL] placeholderImage:placeholderImage];
    
    return cell;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        // Calculate where the collection view should be at the right-hand end item
        float contentOffsetWhenFullyScrolledRight = self.coverFlow.frame.size.width * ([self.slideNews count] -1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            // user is scrolling to the right from the last item to the 'fake' item 1.
            // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            
            [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            // user is scrolling to the left from the first item to the fake 'item N'.
            // reposition offset to show the 'real' item N at the right end end of the collection view
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.slideNews count] -2) inSection:0];
            
            [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
        }
        
        NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
        if (page == 0) {
            page = self.slideNews.count-2;
        } else if (page == self.slideNews.count-1) {
            page = 0;
        } else {
            page--;
        }
        self.pageControl.currentPage = page;
        News* currentNew = self.slideNews[page];
        self.coverTitle.text = currentNew.title;
        
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
        if (page == 0) {
            page = self.slideNews.count-2;
        } else if (page == self.slideNews.count-1) {
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.newsTableView) {
        [self.slimeView scrollViewDidEndDraging];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.newsTableView) {
        [self.slimeView scrollViewDidScroll];
    }
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    if (refreshView == self.slimeView) {
        [[GXNewsEngine sharedEngine] startSync];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"资讯";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor redColor];
}

#pragma mark - action

- (void)changeCover {
    if (self.slideNews.count >= 2) {
        NSIndexPath* indexPath = (NSIndexPath*)[[self.coverFlow indexPathsForVisibleItems] firstObject];
        News* currentNews = self.slideNews[indexPath.item];
        self.coverTitle.text = currentNews.title;
        if (indexPath.item == self.slideNews.count-1) {
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.coverFlow scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:indexPath.item+1 inSection:indexPath.section];
        [self.coverFlow scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}


@end
