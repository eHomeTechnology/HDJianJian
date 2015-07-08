//
//  HDCompleteViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDCompleteViewCtr.h"
#import "HDNavigationController.h"
#import "HDMenuViewCtr.h"
#import "JDSideMenu.h"

@interface HDCompleteViewCtr ()

@end

@implementation HDCompleteViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = @"才铺创建成功";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doOpenShop:(id)sender{

    HDMainViewCtr *ctr                      = [[HDMainViewCtr alloc] init];
    HDNavigationController *nav             = [[HDNavigationController alloc] initWithRootViewController:ctr];
    HDMenuViewCtr *leftMenuctr              = [[HDMenuViewCtr alloc] init];
    JDSideMenu *sideMenuCtr                 = [[JDSideMenu alloc] initWithContentController:nav menuController:leftMenuctr];
    [HDGlobalInfo instance].sideMenu        = sideMenuCtr;
    [self.navigationController presentViewController:sideMenuCtr animated:YES completion:nil];
}
@end
