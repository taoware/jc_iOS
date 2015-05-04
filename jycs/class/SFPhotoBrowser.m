//
//  ERBigPhotoVC.m
//  Erbitux2
//
//  Created by Jagie on 13-2-21.
//  Copyright (c) 2013年 sagacity. All rights reserved.
//

#import "SFPhotoBrowser.h"
#import "UIImageView+AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#define kMaxScale 3;
#define kEnableCache YES
#define kDismissSFPhotoesBrowser @"kDismissSFPhotoesBrowser"
#define kAnimationDuration 0.4

#ifndef ccp
#define ccp(X,Y) CGPointMake((X),(Y))
#endif


typedef void (^ CompletionHandler )(void);

@interface SFPhotoPageView : UIScrollView<UIScrollViewDelegate>
@property(nonatomic,strong) NSString *photoURL;
@property(nonatomic,weak) UIImageView *iv;
@property(nonatomic) BOOL imageLoaded;

@property(nonatomic,strong) UIImage *thumbImage;


@end

@implementation SFPhotoPageView

-(instancetype)initWithFrame:(CGRect)frame thumbImage:(UIImage *)thumbImage{
    if (self = [super initWithFrame:frame ]) {
        _thumbImage = thumbImage;
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        iv.userInteractionEnabled = YES;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *g2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap2:)];
        g2.numberOfTapsRequired = 2;
        [iv addGestureRecognizer:g2];
        
        
        UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap1:)];
        g1.numberOfTapsRequired = 1;
        [g1 requireGestureRecognizerToFail:g2];
        [iv addGestureRecognizer:g1];
        
        iv.image = _thumbImage;
        
        
        [self addSubview:iv];
        _iv = iv;
        
        self.delegate = self;
        self.maximumZoomScale = kMaxScale;
        self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


-(void)onTap2:(UITapGestureRecognizer *)g{
    if (self.imageLoaded) {
        float newScale = 1;
        if (self.zoomScale <= 1) {
            newScale = kMaxScale;
        }
        
        
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[g locationInView:self]];
        [self zoomToRect:zoomRect animated:YES];
    }
    
    
    
}

-(void)onTap1:(UITapGestureRecognizer *)g{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDismissSFPhotoesBrowser object:nil];
}

static inline NSString *  md5(NSString * str){
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


-(NSString *)cacheFile{
    NSString *urlToKey = md5(_photoURL);
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
													  , NSUserDomainMask
													  , YES);
	NSString *dir = [path objectAtIndex:0];
    
    return [dir stringByAppendingPathComponent:urlToKey];
    
}


-(void)showLoading{
    [MBProgressHUD hideHUDForView:self animated:NO];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}

-(void)hideLoading{
    [MBProgressHUD hideHUDForView:self animated:NO];
}
-(void)free{
    self.imageLoaded = NO;
    self.iv.image =_thumbImage;
    [self resoreScale];
}
-(void)resoreScale{
    self.zoomScale = 1;
}
-(void)load{
    
    if ([self.photoURL hasPrefix:@"http"] || [self.photoURL hasPrefix:@"https"]) {
        NSString *cacheFile = [self cacheFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
            UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
            self.iv.image = image;
            self.imageLoaded = YES;
        }else{
            [self showLoading];
            [_iv setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.photoURL]] placeholderImage:_thumbImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                if (kEnableCache) {
                    [UIImageJPEGRepresentation(image, 0.8) writeToFile:cacheFile atomically:YES];
                }
                
                
                [self hideLoading];
                self.iv.image = image;
                self.imageLoaded = YES;
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [self hideLoading];
                
            }];
        }
        
        
        
    }else{
        NSString* photoName = [[self.photoURL componentsSeparatedByString:@"/"] lastObject];
        NSURL* documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL* photoURL = [documentDirectory URLByAppendingPathComponent:photoName];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
        
        self.iv.image = image;
        self.imageLoaded = YES;
    }
    
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageLoaded ? self.iv :nil;
}

@end


#define kGap 10

@interface SFPhotoBrowser ()
@property(nonatomic,strong) NSArray *allPhotoURLs;
@property(nonatomic,strong) NSArray *allThumbImageViews;
@property BOOL originalStatusBarHidden;
@property(nonatomic,weak) UIScrollView *scrollPageView;
@property(nonatomic) int originalIndex;
@property (nonatomic) int indexBeforeRotate;
@property(nonatomic,copy) CompletionHandler onDismissingHandler;
@property(nonatomic,copy) CompletionHandler onEndShowingHandler;
@property(nonatomic,strong) UIImage* snapshot;

@property(nonatomic,weak) UIImageView *snapshotBg;
@property(nonatomic) UIInterfaceOrientation originalInterfaceOrientation;

@end



@implementation SFPhotoBrowser

-(instancetype)initWithIndex:(int)index allPhotoURLs:(NSArray *)allURLs allThumbImageViews:(NSArray *)allThumbImageViews{
    
    if (self = [super init]) {
        self.wantsFullScreenLayout = YES;
        _allPhotoURLs = allURLs;
        _allThumbImageViews = allThumbImageViews;
        _originalIndex = index;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss:) name:kDismissSFPhotoesBrowser object:nil];
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll; // etc
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _indexBeforeRotate = [self currentPageIndex];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    for (int i = 0;i < self.scrollPageView.subviews.count; i++) {
        SFPhotoPageView *pageView = _scrollPageView.subviews[i];
        CGRect frame = CGRectMake(_scrollPageView.bounds.size.width * i + kGap, 0, _scrollPageView.bounds.size.width - kGap * 2, _scrollPageView.bounds.size.height);
        
        pageView.frame = frame;
        [pageView setZoomScale:1 animated:NO];
    }
    
    _scrollPageView.contentSize = CGSizeMake(_scrollPageView.bounds.size.width * self.allPhotoURLs.count  , _scrollPageView.bounds.size.height);
    int current = _indexBeforeRotate;
    _scrollPageView.contentOffset = ccp(_scrollPageView.bounds.size.width *current, 0);
    
    
    
}

-(int)currentPageIndex{
    return (int) ((_scrollPageView.contentOffset.x + _scrollPageView.bounds.size.width / 2) / _scrollPageView.bounds.size.width);
}



-(void)setupPageView{
    UIScrollView * imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-kGap, 0, self.view.bounds.size.width + kGap * 2, self.view.bounds.size.height)];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsVerticalScrollIndicator = imageScrollView.showsHorizontalScrollIndicator = NO;
    
    imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    for (int i = 0; i < self.allPhotoURLs.count; i++) {
        CGRect frame = CGRectMake(imageScrollView.bounds.size.width * i + kGap, 0, imageScrollView.bounds.size.width - kGap * 2, imageScrollView.bounds.size.height);
        
        UIImageView *thumbImageView = _allThumbImageViews[i];
        
        SFPhotoPageView *pageView = [[SFPhotoPageView alloc] initWithFrame:frame thumbImage:thumbImageView.image];
        pageView.photoURL = self.allPhotoURLs[i];
        [imageScrollView addSubview:pageView];
    }
    imageScrollView.contentSize = CGSizeMake(imageScrollView.bounds.size.width * _allPhotoURLs.count, imageScrollView.bounds.size.height);
    
    [self.view addSubview:imageScrollView];
    self.scrollPageView = imageScrollView;
    
    [self.scrollPageView setContentOffset:ccp(self.originalIndex * self.scrollPageView.bounds.size.width, 0) animated:NO];
    
    [self scrollViewDidEndDecelerating:_scrollPageView];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_snapshotBg == nil) {
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:self.snapshot];
        
        bgImageView.frame = CGRectMake(0, self.view.bounds.size.height - _snapshot.size.height, _snapshot.size.width, _snapshot.size.height);
        
        
        [self.view addSubview:bgImageView];
        _snapshotBg = bgImageView;
        
        
        
        UIView *parentView = self.presentingViewController.view;

        UIImageView *thisThumbView = _allThumbImageViews[_originalIndex];
        UIImageView *av  = [[UIImageView alloc] initWithImage:thisThumbView.image];
        av.contentMode = thisThumbView.contentMode;
        av.clipsToBounds = thisThumbView.clipsToBounds;
        
        CGPoint contentOffset = CGPointZero;
        if ([self.presentingViewController.view isKindOfClass:[UITableView class]]) {
            UITableView* presentingTableView = (UITableView*)self.presentingViewController.view;
            contentOffset = presentingTableView.contentOffset;
        }
        av.frame = [self.presentingViewController.view convertRect:thisThumbView.bounds fromView:thisThumbView];

        av.center = ccp(av.center.x, av.center.y + (self.view.bounds.size.height - _snapshot.size.height ) - contentOffset.y + 20);
        
        [self.view addSubview:av];
        
        CGSize thisSize = [self getImageAspectFitSize:av.image];
        CGRect thisFrame = CGRectMake((self.view.bounds.size.width - thisSize.width) / 2, (self.view.bounds.size.height - thisSize.height) / 2, thisSize.width,thisSize.height);
        CGRect targetFrame = thisFrame;
        
        _snapshotBg.hidden = YES;
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            av.frame = targetFrame;
//            _snapshotBg.alpha = 0;
        } completion:^(BOOL finished) {
            [av removeFromSuperview];
            _snapshotBg.hidden = YES;
            _originalInterfaceOrientation = self.interfaceOrientation;
            [self setupPageView];
            
            if (_onEndShowingHandler) {
                _onEndShowingHandler();
            }
        }];
    }
    
}




-(CGSize)getImageAspectFitSize:(UIImage *)image{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = self.view.bounds.size.width / self.view.bounds.size.height;
    if (imageRatio > viewRatio) {
        return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width * image.size.height / image.size.width);
    }else if(imageRatio < viewRatio){
        return CGSizeMake(self.view.bounds.size.height * image.size.width / image.size.height, self.view.bounds.size.height);
    }else{
        return self.view.bounds.size;
    }
}




-(void)dismiss:(NSNotification *)noti{
    
    if (self.interfaceOrientation == _originalInterfaceOrientation) {
        [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusBarHidden withAnimation:UIStatusBarAnimationFade];
        
        int index = [self currentPageIndex];
        [_scrollPageView removeFromSuperview];
        
        _snapshotBg.alpha = 1;
        _snapshotBg.hidden = NO;
        
        UIImageView *thumbImageView = self.allThumbImageViews[index];
        UIImageView *av  = [[UIImageView alloc] initWithImage:thumbImageView.image];
        av.contentMode = thumbImageView.contentMode;
        av.clipsToBounds = YES;
        
        CGSize thisSize = [self getImageAspectFitSize:av.image];
        CGRect thisFrame = CGRectMake((self.view.bounds.size.width - thisSize.width) / 2, (self.view.bounds.size.height - thisSize.height) / 2, thisSize.width,thisSize.height);
        av.frame = thisFrame;
        [self.view addSubview:av];
        
        CGPoint contentOffset = CGPointZero;
        if ([self.presentingViewController.view isKindOfClass:[UITableView class]]) {
            UITableView* presentingTableView = (UITableView*)self.presentingViewController.view;
            contentOffset = presentingTableView.contentOffset;
        }
        
        CGRect targetFrame = [self.presentingViewController.view convertRect:thumbImageView.bounds fromView:thumbImageView];
        
        targetFrame = CGRectMake(targetFrame.origin.x, targetFrame.origin.y + (self.view.bounds.size.height - _snapshot.size.height ) - contentOffset.y + 20, targetFrame.size.width, targetFrame.size.height);
        
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            av.frame = targetFrame;
//            _snapshotBg.alpha = 1;
        } completion:^(BOOL finished) {
            CompletionHandler handler = self.onDismissingHandler;
            [self dismissViewControllerAnimated:NO completion:nil];
            
            if(handler){
                handler();
            }
        }];
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusBarHidden withAnimation:UIStatusBarAnimationFade];
        
        __weak SFPhotoBrowser* this = self;
        
        [this dismissViewControllerAnimated:YES completion:^{
            if (this.onDismissingHandler) {
                this.onDismissingHandler();
            }
        }];
        
        
    }
    
    
    
}



#pragma mark UIScrollViewDelegate methods
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int index = [self currentPageIndex];
    for (int i = 0 ;i < self.scrollPageView.subviews.count;i++  ) {
        SFPhotoPageView *pageView = self.scrollPageView.subviews[i];
        if (i == index - 1 || i == index || i == index + 1) {
            if (!pageView.imageLoaded) {
                [pageView load];
            }
            
            if (i != index) {
                [pageView resoreScale];
            }
        }else{
            [pageView free];
        }
    }
}




-(void)dealloc{

}


+(UIImage *)snapshot{
    UIWindow *window = [UIApplication sharedApplication].keyWindow.subviews[0];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    UIImage *imageCaptureRect = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCaptureRect;
    
}


+(void)animateShowBigPhotosFromThumbImageViews:(NSArray *)thumbImageViews fromViewController:(UIViewController *)fromViewController bigPhotoesURL:(NSArray *)bigPhotoesURLS curIndex:(int)index didEndShowing:(void (^)(void))didEndShowing didEndDismissing:(void (^)(void))didEndDismissing{
    
    UIImage *snapshot = [self snapshot];
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    
    SFPhotoBrowser *vc = [[SFPhotoBrowser alloc] initWithIndex:index allPhotoURLs:bigPhotoesURLS allThumbImageViews:thumbImageViews];
    vc.originalStatusBarHidden = statusBarHidden;
    vc.onDismissingHandler = didEndDismissing;
    vc.onEndShowingHandler = didEndShowing;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.snapshot = snapshot;
    [fromViewController presentViewController:vc animated:NO completion:nil];
    
    
    
}






@end
