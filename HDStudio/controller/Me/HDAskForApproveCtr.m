//
//  HDAskForApproveCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAskForApproveCtr.h"
#import "HDPersonalApproveCtr.h"

@interface HDAskForApproveCtr ()

@end

@implementation HDAskForApproveCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"申请认证";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)doAskForApprove:(UIButton *)sender{
    switch (sender.tag) {
        case 0:{//个人
            [self.navigationController pushViewController:[[HDPersonalApproveCtr alloc] initWithApproveType:HDApproveTypePersonal] animated:YES];
            break;
        }
        case 1:{//企业
            [self.navigationController pushViewController:[[HDPersonalApproveCtr alloc] initWithApproveType:HDApproveTypeEnterprise] animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
