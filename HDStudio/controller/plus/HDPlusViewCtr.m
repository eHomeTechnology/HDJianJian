//
//  HDPlusViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPlusViewCtr.h"
#import "HDJJUtility.h"
#import "HDNewBlogCtr.h"
#import "WJAddPersonalCtr.h"

@interface HDPlusViewCtr ()

@end

@implementation HDPlusViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = self.navigationController.viewControllers.count > 1;
}

#pragma mark - event

- (IBAction)doIBAction:(UIButton *)sender{
    
    switch (sender.tag) {
        case 0:{//取消
            [self.navigationController.tabBarController setSelectedIndex:0];
            break;
        }
        case 1:{//发布职位
            [self.navigationController pushViewController:[HDNewPositionCtr new] animated:YES];
            break;
        }
        case 2:{//新增简历
            WJAddPersonalCtr *ctr = [[WJAddPersonalCtr alloc] initWithTalentInfo:nil type:WJPersonalTypeAdd];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 3:{//分享
            [self.navigationController pushViewController:[HDNewBlogCtr new] animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
