//
//  WJPositionCell.m
//  JianJian
//
//  Created by liudu on 15/4/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPositionCell.h"

@implementation WJPositionCell

+ (WJPositionCell *)getPositionCell{
    WJPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJPositionCell class]]) {
            cell = (WJPositionCell *)obj;
            break;
        }
    }
    return cell;
}
@end
