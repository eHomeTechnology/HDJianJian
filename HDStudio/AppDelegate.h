//
//  AppDelegate.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/10.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialControllerService.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 * @brief 在状态栏显示 一些Log
 *
 * @param string 需要显示的内容
 * @param duration  需要显示多长时间
 */
+ (void)showStatusWithText:(NSString *) string duration:(NSTimeInterval)duration;
@end

