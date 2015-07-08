//
//  WJTradeInfo.h
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJTradeInfo : NSObject//交易信息子对象

@property (strong) NSString     * sTradeId;             //交易编号
@property (strong) NSString     * sServiceFees;         //悬赏金(荐币)
@property (strong) NSString     * sServiceType;         //服务要求编码
@property (strong) NSString     * sServiceTypeText;     //服务要求
@property (strong) NSString     * sDelayDay;            //上岗延迟天数
@property (strong) NSString     * sDeposit;             //保证金(荐币)
@property (strong) NSString     * sProperty;            //交易属性
@property (strong) NSString     * sTradeDesc;           //交易描述
@property (strong) NSString     * sRemark;              //补充条款

@end
