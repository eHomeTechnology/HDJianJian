//
//  WJCheckPersonalDetailCell.m
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckPersonalDetailCell.h"

@implementation WJCheckPersonalDetailCell

+ (WJCheckPersonalDetailCell *)getCheckPositionDetailCell{
    WJCheckPersonalDetailCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckPersonalDetailCell" owner:self options:nil];
    for (NSString * obj in objects) {
        if ([obj isKindOfClass:[WJCheckPersonalDetailCell class]]) {
            cell = (WJCheckPersonalDetailCell *)obj;
            break;
        }
    }
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
