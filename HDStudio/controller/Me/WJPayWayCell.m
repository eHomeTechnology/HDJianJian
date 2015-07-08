//
//  WJPayWayCell.m
//  JianJian
//
//  Created by liudu on 15/5/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPayWayCell.h"

@implementation WJPayWayCell

+ (WJPayWayCell *)getPayWayCell{
    WJPayWayCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPayWayCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJPayWayCell class]]) {
            cell = (WJPayWayCell *)obj;
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

@implementation WJGiveCell

+ (WJGiveCell *)getGiveCell{
    WJGiveCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPayWayCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJGiveCell class]]) {
            cell = (WJGiveCell *)obj;
            break;
        }
    }
    return cell;
}

@end