//
//  WJJJSearchInfo.m
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerInfo.h"

@implementation WJBrokerInfo

+ (WJBrokerInfo *)infoWithContactInfo:(HDHumanInfo *)info{
    WJBrokerInfo *brokerInfo = [WJBrokerInfo new];
    brokerInfo.sName    = info.sName;
    return brokerInfo;
}

@end
