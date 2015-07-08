//
//  WJSellOrderCell.h
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJSellOrderCell : UITableViewCell


@property (strong) IBOutlet UILabel     *lb_buyId;
@property (strong) IBOutlet UILabel     *lb_status;

@property (strong) IBOutlet UILabel *lb_personalName;
@property (strong) IBOutlet UILabel *lb_buyer;
@property (strong) IBOutlet UILabel *lb_buyTime;
@property (strong) IBOutlet UILabel *lb_endTime;
@property (strong) IBOutlet UILabel *lb_gold;

+ (WJSellOrderCell *)getSellOrderCell;

@end
