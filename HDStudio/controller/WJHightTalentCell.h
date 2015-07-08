//
//  WJHightTalentCell.h
//  JianJian
//
//  Created by liudu on 15/5/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJHightTalentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *img_head;
@property (strong, nonatomic) IBOutlet UILabel *lb_position;
@property (strong, nonatomic) IBOutlet UILabel *lb_message;
@property (strong, nonatomic) IBOutlet UILabel *lb_company;
@property (strong, nonatomic) IBOutlet UILabel *lb_price;
@property (strong, nonatomic) IBOutlet UILabel *lb_name;
@property (strong, nonatomic) IBOutlet UIImageView *img_certification;//认证
@property (strong, nonatomic) IBOutlet UIImageView *img_grade;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_name;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_price;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_silver;
+ (WJHightTalentCell *)getHightTalentCell;
@end
