//
//  WJPayListCell.h
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPayListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_name;
@property (strong, nonatomic) IBOutlet UILabel *lb_position;
@property (strong, nonatomic) IBOutlet UILabel *lb_price;
@property (strong, nonatomic) IBOutlet UILabel *lb_time;
@property (strong, nonatomic) IBOutlet UILabel *lb_reward;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_nameWithWidth;
@end
