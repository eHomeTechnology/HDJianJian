//
//  WJSellOrderCell.m
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSellOrderCell.h"

@implementation WJSellOrderCell

+ (WJSellOrderCell *)getSellOrderCell{
    WJSellOrderCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJSellOrderCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJSellOrderCell class]]) {
            cell = (WJSellOrderCell *)obj;
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
