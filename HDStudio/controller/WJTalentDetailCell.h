//
//  WJTalentDetailCell.h
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJTalentDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_workYears;
@property (strong, nonatomic) IBOutlet UILabel *lb_education;
@property (strong, nonatomic) IBOutlet UILabel *lb_sex;
@property (strong, nonatomic) IBOutlet UILabel *lb_place;
@property (strong, nonatomic) IBOutlet UILabel *lb_curPosition;
@property (strong, nonatomic) IBOutlet UILabel *lb_curCompany;
@property (strong, nonatomic) IBOutlet UILabel *lb_price;
@property (strong, nonatomic) IBOutlet UIButton *btn_service;

@property (strong) IBOutlet UIButton    *btn_checkBroker;
@property (strong) IBOutlet UILabel     *lb_brokerName;
@property (strong) IBOutlet UIButton    *btn_payAtention;
@property (strong) IBOutlet UIButton    *btn_chat;
@property (strong) IBOutlet UIView      *v_attention;
@property (strong) IBOutlet UIImageView *imv_v;
@property (strong) IBOutlet UIImageView *imv_level;
@property (strong) IBOutlet NSLayoutConstraint *lc_attentionWidth;
@property (strong) IBOutlet NSLayoutConstraint *lc_brokerNameWidth;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_priceWithWidth;

+ (WJTalentDetailCell *)getTalentDetailCell;
@end
