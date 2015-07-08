//
//  WJEmployerCell.h
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJEmployerCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_company;
@property (strong, nonatomic) IBOutlet UILabel *lb_industry;
@property (strong, nonatomic) IBOutlet UILabel *lb_property;

+ (WJEmployerCell *)getEmployerCell;
@end

@interface HDEmployerImageCell : UITableViewCell

@property (strong) IBOutlet UIImageView *imv;
+ (HDEmployerImageCell *)getCell;

@end