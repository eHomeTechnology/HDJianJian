//
//  SNNavigationController.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "HDNavigationController.h"


@interface HDNavigationController ()

@end

@implementation HDNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBack"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor],
                                                NSForegroundColorAttributeName,
                                                nil]];
}

- (void)viewWillAppear:(BOOL)animated{

    Dlog(@"...");
}

- (void)viewDidAppear:(BOOL)animated{

    Dlog(@"////");
}
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    for (int i = 0; i < self.viewControllers.count; i++) {
//        [self.viewControllers[i] viewWillAppear:animated];
//    }
//}
//- (void)viewDidAppear:(BOOL)animated{
//    
//    [super viewDidAppear:animated];
//    for (int i = 0; i < self.viewControllers.count; i++) {
//        [self.viewControllers[i] viewDidAppear:animated];
//    }
//}
//- (void)viewWillDisappear:(BOOL)animated{
//    
//    [super viewWillDisappear:animated];
//    for (int i = 0; i < self.viewControllers.count; i++) {
//        [self.viewControllers[i] viewWillDisappear:animated];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
