//
//  WJOrderListCell.m
//  JianJian
//
//  Created by liudu on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJOrderListCell.h"

@implementation WJOrderListCell

+ (WJOrderListCell *)getListCell{
    WJOrderListCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJOrderListCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJOrderListCell class]]) {
            cell = (WJOrderListCell *)obj;
            break;
        }
    }
    return cell;
}

@end
