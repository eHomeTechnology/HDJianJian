//
//  HDRepostPositionCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDRepostPositionCtr.h"

@interface HDRepostPositionCtr ()

@end

@implementation HDRepostPositionCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_REPOST_POSITION");
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
