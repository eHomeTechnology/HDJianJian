//
//  WJPositionInfo.m
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPositionInfo.h"

@implementation WJPositionInfo
- (id)init{
    if (self = [super init]) {
        self.employerInfo   = [HDEmployerInfo new];
        self.brokerInfo     = [WJBrokerInfo new];
        self.tradeInfo      = [WJTradeInfo new];
    }
    return self;
}
- (NSString *)changeBr2n:(NSString *)s{
    if (s.length == 0) {
        Dlog(@"警告:传入参数为空");
        return s;
    }
    NSString *s1 = [s stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s1.length)];
    return s2;
}
@end
