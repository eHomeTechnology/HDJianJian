//
//  WJBrokerCell1.h
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBrokerCell1 : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView  *img_head;
@property (strong, nonatomic) IBOutlet UIImageView  *img_certification;
@property (strong, nonatomic) IBOutlet UIImageView  *img_grade;
@property (strong, nonatomic) IBOutlet UILabel      *lb_name;
@property (strong, nonatomic) IBOutlet UILabel      *lb_curPosition;
@property (strong, nonatomic) IBOutlet UILabel      *lb_place;
@property (strong, nonatomic) IBOutlet UILabel      *lb_curCompany;
@property (strong, nonatomic) IBOutlet UILabel      *lb_business;       //擅长行业
@property (strong, nonatomic) IBOutlet UILabel      *lb_function;       //擅长职位
@property (strong, nonatomic) IBOutlet UIImageView  *img_location;
@property (strong, nonatomic) IBOutlet UIView       *img_line;
@property (strong, nonatomic) IBOutlet UIButton     *btn_addAttention;
@property (strong, nonatomic) IBOutlet UIButton     *btn_chat;
@property (strong, nonatomic) IBOutlet UIImageView  *img_add;
@property (strong, nonatomic) IBOutlet UILabel      *lb_addAttention;
@property (strong, nonatomic) IBOutlet UIImageView  *img_bgAttention;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_nameWithWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_curPositionWith;

+ (WJBrokerCell1 *)getBrokerCell1;

@end
