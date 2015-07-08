//
//  HDMayPositionCell_v3.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CELLButtonStyle) {
    
    CELLButtonStylePreview = 0,
    CELLButtonStyleBonus,
    CELLButtonStyleDeposit,
    CELLButtonStyleShare,
    CELLButtonStyleUnshelve,
    CELLButtonStyleReshelve,
    CELLButtonStyleRecommend,
};

@interface CELLButton : UIButton

@property (assign) CELLButtonStyle buttonStyle;

@end

@interface HDOnPstList_v3Cell : UITableViewCell
@property (strong) IBOutlet UILabel  *lb_title;
@property (strong) IBOutlet UILabel  *lb_date;
@property (strong) IBOutlet UILabel  *lb_company;
@property (strong) IBOutlet UILabel  *lb_hit;
@property (strong) IBOutlet UILabel  *lb_upCount;
@property (strong) IBOutlet UILabel  *lb_deposit;
@property (strong) IBOutlet UILabel  *lb_salary;
@property (strong) IBOutlet CELLButton  *btn_bonus;
@property (strong) IBOutlet CELLButton  *btn_deposit;
@property (strong) IBOutlet CELLButton  *btn_preview;
@property (strong) IBOutlet CELLButton  *btn_share;
@property (strong) IBOutlet CELLButton  *btn_shelve;
@property (strong) IBOutlet CELLButton  *btn_ShowRecmmend;

@property (strong) IBOutlet NSLayoutConstraint *lc_shareWidth;
@property (strong) IBOutlet NSLayoutConstraint *lc_share2shelve;
@property (strong) IBOutlet NSLayoutConstraint *lc_rewardWidth;
@property (strong) IBOutlet NSLayoutConstraint *lc_salaryWidth;
+ (HDOnPstList_v3Cell *)getOnCell;
@end