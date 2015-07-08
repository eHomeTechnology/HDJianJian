//
//  HDJianCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDJianCell.h"

@implementation HDJianCell

- (void)awakeFromNib {
    self.imv_value.hidden               = YES;
    self.v_redDot.hidden                = YES;
    self.v_redDot.layer.cornerRadius    = 4;
    self.v_redDot.layer.masksToBounds   = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
