//
//  HDWebViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDWebViewCtr.h"

@interface HDWebViewCtr (){

    IBOutlet UIWebView  *wbv;
    NSString            *sUrl;
}

@end

@implementation HDWebViewCtr

- (id)initWithUrl:(NSString *)url{

    if ([super init]) {
        sUrl    = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [wbv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]]];
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
