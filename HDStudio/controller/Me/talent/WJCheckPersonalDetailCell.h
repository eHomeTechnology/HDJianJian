//
//  WJCheckPersonalDetailCell.h
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCheckPersonalDetailCell : UITableViewCell

@property (strong) IBOutlet UILabel  *lb_name;
@property (strong) IBOutlet UILabel  *lb_workYears;
@property (strong) IBOutlet UILabel  *lb_education;
@property (strong) IBOutlet UILabel  *lb_sex;
@property (strong) IBOutlet UILabel  *lb_place;
@property (strong) IBOutlet UILabel  *lb_curPosition;
@property (strong) IBOutlet UILabel  *lb_curCompany;
@property (strong) IBOutlet UILabel  *lb_price;
@property (strong) IBOutlet UIButton *btn_service;
@property (strong) IBOutlet UIView   *v_service;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_priceWithWidth;

+ (WJCheckPersonalDetailCell *)getCheckPositionDetailCell;
@end
