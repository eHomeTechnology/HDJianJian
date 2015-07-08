//
//  WJCheckOrderCell.h
//  JianJian
//
//  Created by liudu on 15/4/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCheckOrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_salary;
/**
 *  雇主
 */
@property (strong, nonatomic) IBOutlet UILabel *lb_companyT;
@property (strong, nonatomic) IBOutlet UIButton *btn_company;
/**
 *  工作地点
 */
@property (strong, nonatomic) IBOutlet UILabel *lb_placeT;
@property (strong, nonatomic) IBOutlet UILabel *lb_place;
/**
 *  学历
 */
@property (strong, nonatomic) IBOutlet UILabel *lb_educationT;
@property (strong, nonatomic) IBOutlet UILabel *lb_education;
/**
 *  工作年限
 */
@property (strong, nonatomic) IBOutlet UILabel *lb_workYearsT;
@property (strong, nonatomic) IBOutlet UILabel *lb_workYears;
/**
 *  悬赏金额
 */
@property (strong, nonatomic) IBOutlet UILabel *lb_reward;

/**
 *  label和button的高度
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_companyWithWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_companyTWithHeight;//雇主标题
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btn_companyWithHeight;//雇主信息

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_workPlaceTWithHeight;//工作地点标题
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_workPlaceWithHeight;//工作地点信息

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_educationTWithHeight;//学历标题
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_educationWithHeight;//学历信息

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_workYearsTWithHeight;//工作年限标题
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lb_workYearsWithHeight;//工作年限信息

@property (strong, nonatomic) IBOutlet UIView *v_rewardWithHeight;//悬赏背景
- (void)getChechOrderData:(WJPositionInfo*)info;
@end
