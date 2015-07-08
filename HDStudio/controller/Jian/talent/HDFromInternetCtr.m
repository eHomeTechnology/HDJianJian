//
//  HDFromInternetCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDFromInternetCtr.h"

@interface HDFromInternetCtr ()

@property (strong) IBOutlet UIWebView *wbv;

@end

@implementation HDFromInternetCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_IMPORT_INTERNET");
    [self.wbv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.100.74:9000/oauth/Success"]]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    Dlog(@"request.url = %@", request.URL);
    return YES;
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
