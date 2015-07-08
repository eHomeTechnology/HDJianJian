//
//  HDTabbar.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+LoadFromNib.h"

@interface HDTabbar : UIView

@property (strong) IBOutlet UIButton *btn_JCircle_icon;
@property (strong) IBOutlet UIButton *btn_JCircle_txt;

@property (strong) IBOutlet UIButton *btn_discover_icon;
@property (strong) IBOutlet UIButton *btn_discover_txt;

@property (strong) IBOutlet UIButton *btn_plus;

@property (strong) IBOutlet UIButton *btn_chat_icon;
@property (strong) IBOutlet UIButton *btn_chat_txt;

@property (strong) IBOutlet UIButton *btn_me_icon;
@property (strong) IBOutlet UIButton *btn_me_txt;

@property (nonatomic, strong) UITabBarController *tabCtr;
- (void)setSelected:(NSInteger)index;
@end
