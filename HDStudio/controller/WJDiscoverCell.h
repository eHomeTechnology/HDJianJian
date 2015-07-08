//
//  WJDiscoverCell.h
//  JianJian
//
//  Created by liudu on 15/5/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJDiscoverCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_head;
@property (strong, nonatomic) IBOutlet UILabel *lb_title;
@property (strong, nonatomic) IBOutlet UILabel *lb_content;
@property (strong, nonatomic) IBOutlet UIView *v_price;
@property (strong, nonatomic) IBOutlet UILabel *lb_certification;
@property (strong, nonatomic) IBOutlet UILabel *lb_message;
@property (strong, nonatomic) IBOutlet UILabel *lb_reward;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_priceview;
+ (WJDiscoverCell *)getDiscoverCell;
@end
