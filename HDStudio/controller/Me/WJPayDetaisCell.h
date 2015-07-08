//
//  WJPayDetaisCell.h
//  JianJian
//
//  Created by liudu on 15/5/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPayDetaisCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lb_transactType;
@property (strong, nonatomic) IBOutlet UILabel *lb_createdTime;
@property (strong, nonatomic) IBOutlet UILabel *lb_transactID;
@property (strong, nonatomic) IBOutlet UILabel *lb_otherNickName;
@property (strong, nonatomic) IBOutlet UILabel *lb_content;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_content;

@end
