//
//  HDAddFriendCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAddFriendCtr.h"

@interface HDAddFriendCtr ()

@end

@implementation HDAddFriendCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title   = LS(@"TXT_TITLE_ADD_FRIEND");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
