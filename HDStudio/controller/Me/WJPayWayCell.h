//
//  WJPayWayCell.h
//  JianJian
//
//  Created by liudu on 15/5/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPayWayCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *btn_select;
@property (strong, nonatomic) IBOutlet UIImageView *img_head;
@property (strong, nonatomic) IBOutlet UILabel *lb_card;
@property (strong, nonatomic) IBOutlet UILabel *lb_cardContent;

+ (WJPayWayCell *)getPayWayCell;
@end

@interface WJGiveCell : UITableViewCell

@property (strong) IBOutlet UIButton *btn_selectCombo;
@property (strong) IBOutlet UILabel     *lb_content;

+ (WJGiveCell *)getGiveCell;
@end