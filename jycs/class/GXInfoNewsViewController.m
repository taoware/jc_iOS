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
#import "GXArticleViewController.h"
#import "GXNewsCarouselView.h"

@interface GXInfoNewsViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, XLPagerTabStripChildItem, SRRefreshDelegate>

@property (nonatomic, strong) UITableView* newsTableView;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) GXNewsCarouselView* carouselView;
@property (strong, nonatomic) NSArray* news;
@property (nonatomic, strong) NSArray* slideNews;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation GXInfoNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.newsTableView];
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] newManagedObjectContext];
    
    [self updateUI];
    [self.slimeView setLoadingWithExpansion];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_NEWSSYNCCOMPLETED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self updateUI];
        
        [_slimeView endRefresh];
    }];

}

- (void)updateUI {
    [self loadRecordsFromCoreData];
    
    [self.newsTableView reloadData];
    self.carouselView.news = self.slideNews;
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
    }];
}


- (UITableView *)newsTableView {
    if (!_newsTableView) {
        _newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _newsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _newsTableView.tableHeaderView = self.carouselView;
        _newsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _newsTableView.backgroundColor = NEWSBGCOLOR;
        _newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _newsTableView.delegate = self;
        _newsTableView.dataSource = self;
        [_newsTableView addSubview:self.slimeView];
    }
    return _newsTableView;
}

- (GXNewsCarouselView *)carouselView {
    if (!_carouselView) {
        _carouselView = [[GXNewsCarouselView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        __block GXInfoNewsViewController* weakSelf = self;
        [_carouselView setDidSelectBlock:^(GXCarouselItem *item, NSInteger index) {
            News* news = weakSelf.slideNews[index];
            GXArticleViewController* articleVC = [[GXArticleViewController alloc]init];
            articleVC.articleUrl = news.url;
            [weakSelf.navigationController pushViewController:articleVC animated:YES];
        }];
    }
    return _carouselView;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    News* news = self.news[indexPath.row];
    
    GXArticleViewController* articleVC = [[GXArticleViewController alloc]init];
    articleVC.articleUrl = news.url;
    [self.navigationController pushViewController:articleVC animated:YES];
}


#pragma mark - UIScrollViewDelegate

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


@end
