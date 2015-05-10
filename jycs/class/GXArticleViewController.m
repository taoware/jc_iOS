//
//  GXArticleViewController.m
//  jycs
//
//  Created by appleseed on 5/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXArticleViewController.h"

@interface GXArticleViewController () <UIWebViewDelegate>
@property (nonatomic, strong)UIWebView* webView;
@property (nonatomic, strong)UIActivityIndicatorView* indicator;
@end

@implementation GXArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.indicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.indicator.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.indicator startAnimating];
    NSURL* url = [NSURL URLWithString:self.articleUrl];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - webviewdelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

@end
