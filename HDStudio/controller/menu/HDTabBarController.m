//
//  HDTabBarController.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDTabBarController.h"
#import "HDNavigationController.h"
#import "HDLoginViewCtr.h"

@interface HDTabBarController ()

@end

@implementation HDTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self addTabbar];
    [self setControllers];
}

- (void)setHideTabbar:(BOOL)hideTabbar{
    _tabbar.hidden = hideTabbar;
}

- (void)viewWillAppear:(BOOL)animated{
//    [self.view bringSubviewToFront:self.tabbar];
//    if (self.viewControllers.count > 0) {
//        [self.viewControllers[0] viewWillAppear:animated];
//    }
    HDNavigationController *nav = (HDNavigationController *)self.selectedViewController;
    self.hideTabbar = nav.viewControllers.count > 1;
}

- (void)viewDidAppear:(BOOL)animated{
//    [self.view bringSubviewToFront:self.tabbar];
//    if (self.viewControllers.count > 0) {
//        [self.viewControllers[0] viewDidAppear:animated];
//    }
}

//- (void)viewWillDisappear:(BOOL)animated{
//    if (self.viewControllers.count > 0) {
//        [self.viewControllers[0] viewWillDisappear:animated];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - setter and getter
- (void)setControllers{
    HDBlogViewCtr       *blogCtr            = [[HDBlogViewCtr       alloc] init];
    HDDiscoverCtr       *discoverCtr        = [[HDDiscoverCtr       alloc] init];
    HDMeViewCtr         *meCtr              = [[HDMeViewCtr         alloc] init];
    HDNewsViewCtr       *newsCtr            = [[HDNewsViewCtr       alloc] init];
    HDNavigationController  *nav_blog       = [[HDNavigationController   alloc] initWithRootViewController:blogCtr];
    HDNavigationController  *nav_discover   = [[HDNavigationController   alloc] initWithRootViewController:discoverCtr];
    HDNavigationController  *nav_news       = [[HDNavigationController   alloc] initWithRootViewController:newsCtr];
    HDNavigationController  *nav_me         = [[HDNavigationController   alloc] initWithRootViewController:meCtr];
    [self setViewControllers:@[nav_blog, nav_discover, nav_news, nav_me]];
}

- (void)addTabbar{
    self.tabBar.hidden = YES;
    if (!self.tabbar) {
        self.tabbar = [HDTabbar loadFromNib];
        [self.view addSubview:_tabbar];
    }
    _tabbar.tabCtr = self;
    [_tabbar setSelected:0];
    _tabbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tabbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tabbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabbar(49)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tabbar)]];
}

@end
