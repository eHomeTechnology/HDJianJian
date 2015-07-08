//
//  WJRecommendSuccess.m
//  JianJian
//
//  Created by liudu on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecommendSucCtr.h"
#import "WJOrderListCtr.h"
#import "HDMyTalentCtr.h"
#import "WJCheckPositionCtr.h"
#import "WJMyRecommendPersonalCtr.h"

@interface WJRecommendSucCtr ()
@property (strong, nonatomic) IBOutlet UIButton *btn_recommendAgain;
- (IBAction)recommendAgain:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *btn_recommendPeople;
- (IBAction)recommendPeople:(UIButton *)sender;
@end

@implementation WJRecommendSucCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_JJ_RECOMMEND_SUCCESS");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recommendAgain:(UIButton *)sender {
    for (UIViewController *ctr in self.navigationController.viewControllers) {
        if ([ctr isKindOfClass:[WJCheckPositionCtr class]]) {
            [self.navigationController popToViewController:ctr animated:YES];
        }
    }
}

- (IBAction)recommendPeople:(UIButton *)sender {
    [self.navigationController pushViewController:[WJMyRecommendPersonalCtr new] animated:YES];
}

@end
