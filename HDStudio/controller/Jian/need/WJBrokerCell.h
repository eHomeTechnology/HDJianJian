//
//  WJBrokerCell.h
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBrokerCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView  *imv_head;
@property (strong, nonatomic) IBOutlet UILabel      *lb_name;
@property (strong, nonatomic) IBOutlet UILabel      *lb_industry;//行业
@property (strong, nonatomic) IBOutlet UILabel      *lb_position;//职位
@property (strong, nonatomic) IBOutlet UIImageView  *img_certification;
@property (strong, nonatomic) IBOutlet UIView       *v_add;
@property (strong, nonatomic) IBOutlet UIImageView  *img_add;
@property (strong, nonatomic) IBOutlet UILabel      *lb_add;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lc_nameWithWidth;
@property (strong, nonatomic) IBOutlet UILabel      *lb_place;
@property (strong, nonatomic) IBOutlet UIImageView  *img_location;
@property (strong, nonatomic) IBOutlet UIButton     *btn_addAttention;
+ (WJBrokerCell *)getBrokerCell;
@end
