//
//  GXCMArticleViewController.m
//  Demo
//
//  Created by appleseed on 1/20/15.
//  Copyright (c) 2015 chenlei. All rights reserved.
//

#import "GXCMArticleViewController.h"

@interface GXCMArticleViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation GXCMArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"新闻";
    
    [self loadWebContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:240/255.0 green:108/255.0 blue:30/255.0 alpha:1],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:240/255.0 green:108/255.0 blue:30/255.0 alpha:1]];
}

- (void)loadWebContent {
    NSString* htmlHead = [NSString stringWithFormat:@"<h3 style='text-align:center;margin-bottom:0'>%@</h3><h6 style='text-align:center;margin-bottom:0;margin-top:0'>作者:%@   %@ </h6>", self.article.title, self.article.author, self.article.createdDate];
    NSString* body = [NSString stringWithFormat:@"<body><font size='2'>%@</font></body>", self.article.body];
    NSString* html = [htmlHead stringByAppendingString:body];
    [self.webView loadHTMLString:html baseURL:nil];
}

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
