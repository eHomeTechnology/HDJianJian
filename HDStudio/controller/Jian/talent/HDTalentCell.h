//
//  HDTalentCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDTalentCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_title;
@property (strong) IBOutlet UILabel *lb_curCompany;
@property (strong) IBOutlet UILabel *lb_curPosition;
@property (strong) IBOutlet UILabel *lb_workYear;
@property (strong) IBOutlet UILabel *lb_MPhone;
@property (strong) IBOutlet UILabel *lb_createTime;
@property (strong, nonatomic) IBOutlet UIButton *btn_suitable;
@property (strong, nonatomic) IBOutlet UILabel *lb_suitable;
@property (strong, nonatomic) IBOutlet UIButton *btn_call;

@end

@interface HDTalentViewCell : UITableViewCell;

@property IBOutlet UILabel          *lb_title;
@property IBOutlet UITextField      *tf_value;
@property IBOutlet UILabel          *lb_accesory;
@property IBOutlet NSLayoutConstraint *lc_width;

+ (HDTalentViewCell *)getTalentViewCell;
@end