//
//  WJBrokerCell.m
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerCell.h"

@implementation WJBrokerCell

+ (WJBrokerCell *)getBrokerCell{
    WJBrokerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBrokerCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJBrokerCell class]]) {
            cell = (WJBrokerCell *)obj;
            break;
        }
    }
    return cell;
}

@end
