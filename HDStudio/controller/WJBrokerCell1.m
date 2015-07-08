//
//  WJBrokerCell1.m
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerCell1.h"

@implementation WJBrokerCell1

+ (WJBrokerCell1 *)getBrokerCell1{
    WJBrokerCell1 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:@"WJBrokerCell1" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJBrokerCell1 class]]) {
            cell = (WJBrokerCell1 *)obj;
            break;
        }
    }
    return cell;
}

@end
