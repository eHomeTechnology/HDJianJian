//
//  WJPositionCell.h
//  JianJian
//
//  Created by liudu on 15/4/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPositionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lb_position;
@property (strong, nonatomic) IBOutlet UILabel *lb_date;
@property (strong, nonatomic) IBOutlet UILabel *lb_company;
@property (strong, nonatomic) IBOutlet UILabel *lb_reward;
@property (strong, nonatomic) IBOutlet UILabel *lb_salary;
@property (strong, nonatomic) IBOutlet UIButton *btn_reward;

+ (WJPositionCell *)getPositionCell;
@end
