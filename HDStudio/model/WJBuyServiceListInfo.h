//
//  WJBuyServiceListInfo.h
//  JianJian
//
//  Created by liudu on 15/6/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HDBuyServiceStatus) {
    HDBuyServiceStatusWaitingForPaying = 0,
    HDBuyServiceStatusPayed,
    HDBuyServiceStatusComplete,
    HDBuyServiceStatusCompleteWaitingForMoney,
    HDBuyServiceStatusCancel,
};

#import <Foundation/Foundation.h>

@interface WJBuyServiceListInfo : NSObject

@property (strong) NSString *sBuyId;        //服务编号
@property (strong) NSString *sBuyTime;      //购买时间
@property (strong) NSString *sBuyer;        //雇主名称
@property (strong) NSString *sEndTime;      //完成时间
@property (strong) NSString *sGold;         //订单费用(荐币)
@property (strong) NSString *sPersonalName; //人选名称
@property (strong) NSString *sPersonalNo;   //人选编号
@property (strong) NSString *sSeller;       //出售者昵称
@property (assign) HDBuyServiceStatus status;       //服务状态
@property (strong) NSString *sUserNoBuyer;  //购买者编号
@property (strong) NSString *sUserNoSeller; //出售者编号
@property (strong) NSString *sStatusText;   //服务状态

@end
