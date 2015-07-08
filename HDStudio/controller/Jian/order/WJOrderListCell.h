//
//  WJOrderListCell.h
//  JianJian
//
//  Created by liudu on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJOrderListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_position;
@property (strong, nonatomic) IBOutlet UILabel *lb_placeAndSalary;
@property (strong, nonatomic) IBOutlet UILabel *lb_company;
@property (strong, nonatomic) IBOutlet UILabel *lb_reward;
@property (strong, nonatomic) IBOutlet UIButton *btn_reward;
@property (strong, nonatomic) IBOutlet UIView   *v_ensure;//担保交易
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_placeAndSalaryWithWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_salaryWithWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_rewardWithWidth;
+ (WJOrderListCell *)getListCell;
@end
