//
//  WJAddPersonalCell.m
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJAddPersonalCell.h"

@implementation WJAddPersonalCell

+ (WJAddPersonalCell *)getAddPersonalCell{
    WJAddPersonalCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJAddPersonalCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJAddPersonalCell class]]) {
            cell = (WJAddPersonalCell *)obj;
            break;
        }
    }
    cell.lc_downWith_width.constant = 0;
    cell.lc_yearWithWidth.constant  = 0;
    cell.v_boy.hidden       = YES;
    cell.v_girl.hidden      = YES;
    cell.img_down.hidden    = YES;
    cell.lb_year.hidden     = YES;
    cell.v_line.hidden      = NO;
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
