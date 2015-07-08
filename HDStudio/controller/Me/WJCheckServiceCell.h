//
//  WJCheckServiceCell.h
//  JianJian
//
//  Created by liudu on 15/6/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCheckServiceCell : UITableViewCell

@property (strong) IBOutlet UILabel         *lb_buyId;
@property (strong) IBOutlet UILabel         *lb_buyTime;
@property (strong) IBOutlet UILabel         *lb_endTime;
@property (strong) IBOutlet UILabel         *lb_money;
@property (strong) IBOutlet UILabel         *lb_name;
@property (strong) IBOutlet UIImageView     *img_certification;
@property (strong) IBOutlet UIImageView     *img_grade;//等级
@property (strong) IBOutlet UIButton        *btn_chat;
@property (strong) IBOutlet NSLayoutConstraint *lc_nameWithWidth;

+ (WJCheckServiceCell *)getCheckServiceCell;
@end


@interface WJBrokersMessageCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_name;
@property (strong) IBOutlet UILabel *lb_mobile;
@property (strong) IBOutlet UILabel *lb_email;
@property (strong) IBOutlet UILabel *lb_QQ;
@property (strong) IBOutlet UILabel *lb_recomend;

+ (WJBrokersMessageCell *)getBrokerMessageCell;
@end

@interface WJPersonalMessageCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_workYears;
@property (strong) IBOutlet UILabel *lb_area;
@property (strong) IBOutlet UILabel *lb_sex;
@property (strong) IBOutlet UILabel *lb_education;
@property (strong) IBOutlet UILabel *lb_curPosition;
@property (strong) IBOutlet UILabel *lb_curCompany;
@property (strong) IBOutlet UIButton *btn_checkResume;

+ (WJPersonalMessageCell *)getPersonalMessageCell;
@end