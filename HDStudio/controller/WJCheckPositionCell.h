//
//  WJCheckPositionCell.h
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCheckPositionCell : UITableViewCell
@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UILabel     *lb_salary;
@property (strong) IBOutlet UILabel     *lb_deposit0;
@property (strong) IBOutlet UILabel     *lb_deposit1;
@property (strong) IBOutlet UILabel     *lb_address;
@property (strong) IBOutlet UILabel     *lb_education;
@property (strong) IBOutlet UILabel     *lb_workYear;
@property (strong) IBOutlet UILabel     *lb_company;
@property (strong) IBOutlet UILabel     *lb_recommend;
@property (strong) IBOutlet UIButton    *btn_company;
@property (strong) IBOutlet UIButton    *btn_setSalary;
@property (strong) IBOutlet UIView      *v_reward;
@property (strong) IBOutlet UIButton    *btn_checkBroker;
@property (strong) IBOutlet UILabel     *lb_brokerName;
@property (strong) IBOutlet UIButton    *btn_payAtention;
@property (strong) IBOutlet UIButton    *btn_chat;
@property (strong) IBOutlet UIView      *v_attention;
@property (strong) IBOutlet UIImageView *imv_v;
@property (strong) IBOutlet UIImageView *imv_level;
@property (strong) IBOutlet NSLayoutConstraint *lc_attentionWidth;
@property (strong) IBOutlet NSLayoutConstraint *lc_brokerNameWidth;

@property (strong, nonatomic) WJPositionInfo *positionInfo;

+ (WJCheckPositionCell *)checkPositionCell;
@end


@interface WJCheckPositionCell1 : UITableViewCell
@property (strong) IBOutlet UITextView *tv_content;
@property (strong) IBOutlet NSLayoutConstraint  *lc_lineHeight;
+ (WJCheckPositionCell1 *)checkPositionCell1;
@end

@interface WJServiceCell : UITableViewCell
@property (strong) IBOutlet UILabel *lb_reward;
@property (strong) IBOutlet UILabel *lb_rewardPay;
@property (strong) IBOutlet UILabel *lb_service;
@property (strong) IBOutlet UILabel *lb_description;
@property (strong) IBOutlet NSLayoutConstraint *lc_descriptionWithHeight;
+ (WJServiceCell *)serviceCell;
@end