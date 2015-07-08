//
//  HDApproveSucceeCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDApproveSucceeCtr.h"
#import "HDAskForApproveCtr.h"
#import "HDPersonalApproveCtr.h"
#import "HDPersonalApproveCtr.h"
#import "HDAskForApproveCtr.h"

@interface HDApproveSucceeCtr ()

@end

@implementation HDApproveSucceeCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (int i = 0; i < mar.count; i++) {
        UIViewController *ctr = mar[i];
        if ([ctr isKindOfClass:[HDPersonalApproveCtr class]] || [ctr isKindOfClass:[HDAskForApproveCtr class]]) {
            [mar removeObject:ctr];
            i = 0;
        }
    }
    self.navigationController.viewControllers = mar;
    self.navigationItem.title = @"提交成功";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Event Responde
- (IBAction)doConfirm:(UIButton *)sender{
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (int i = 0; i < mar.count; i++) {
        UIViewController *ctr = mar[i];
        if ([ctr isKindOfClass:[HDAskForApproveCtr class]] || [ctr isKindOfClass:[HDPersonalApproveCtr class]]) {
            [mar removeObject:ctr];
            i = 0;
        }
    }
    self.navigationController.viewControllers = mar;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
