//
//  WJBuyServiceCell.h
//  JianJian
//
//  Created by liudu on 15/6/1.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBuyServiceCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lb_personalNo;
@property (strong, nonatomic) IBOutlet UILabel *lb_name;
@property (strong, nonatomic) IBOutlet UILabel *lb_money;

+ (WJBuyServiceCell *)getBuyServiceCell;
@end

@interface WJShowMoneyCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_select;
@property (strong, nonatomic) IBOutlet UILabel *lb_balance;
@property (strong, nonatomic) IBOutlet UILabel *lb_money;

+ (WJShowMoneyCell *)getMoneyCell;
@end