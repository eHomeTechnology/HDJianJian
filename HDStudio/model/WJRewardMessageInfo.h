//
//  WJRewardMessageInfo.h
//  JianJian
//
//  Created by liudu on 15/5/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJRewardMessageInfo : NSObject

@property (strong) NSString *sPositionName;
@property (strong) NSString *sDelayDay;
@property (strong) NSString *sDeposit;          //保证金(单位分)
@property (strong) NSString *sReward;           //悬赏金
@property (strong) NSString *sRefereeId;        //推荐人编号
@property (strong) NSString *sRName;            //推荐人
@property (strong) NSString *sPersonalNo;       //人选编号
@property (strong) NSString *sTradeId;
@property (strong) NSString *sPName;            //人选姓名
@property (strong) NSString *sRecommendID;      //推荐编号
@property (strong) NSString *sRUserNo;          //推荐人用户编号
@property (strong) NSString *sUserNo;           //付款人用户编号
@property (strong) NSString *sPositionID;       //职位编号


@end
