//
//  HDTabBarController.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDTabbar.h"
#import "HDBlogViewCtr.h"
#import "HDPlusViewCtr.h"
#import "HDDiscoverCtr.h"
#import "HDMeViewCtr.h"
#import "HDNewsViewCtr.h"

@interface HDTabBarController : UITabBarController

@property (strong) HDTabbar *tabbar;

@property (nonatomic, assign) BOOL hideTabbar;

@end
