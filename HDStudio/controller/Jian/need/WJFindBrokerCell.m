//
//  WJFindBrokerCell.m
//  JianJian
//
//  Created by liudu on 15/4/15.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJFindBrokerCell.h"


@implementation WJFindBrokerCell

- (void)awakeFromNib {
    // Initialization code
    self.lb_title.hidden = NO;
    self.tf_value.hidden = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
