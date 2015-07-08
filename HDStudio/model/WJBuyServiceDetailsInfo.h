//
//  WJBuyServiceDetailsInfo.h
//  JianJian
//
//  Created by liudu on 15/6/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJPersonalInfo : NSObject //人选信息

@property (strong) NSString *sSex;
@property (strong) NSString *sSexText;
@property (strong) NSString *sWorkYears;
@property (strong) NSString *sEduLevelText;
@property (strong) NSString *sAreaText;
@property (strong) NSString *sLastCompanyName;
@property (strong) NSString *sLastPosition;

@end

@interface WJAppraiseInfo : NSObject //推荐信信息(可为空)

@property (strong) NSString *sAppraiseTime; //推荐时间
@property (strong) NSString *sEmail;
@property (strong) NSString *sMPhone;
@property (strong) NSString *sName;
@property (strong) NSString *sPersonalNo;
@property (strong) NSString *sRemark;       //推荐信
@property (strong) NSString *sWX_QQ;

@end

@interface WJBuyServiceDetailsInfo : NSObject

@property (strong) NSString *sBuyId;
@property (strong) NSString *sBuyTime;
@property (strong) NSString *sPayTime;
@property (strong) NSString *sAppriseTime;  //评价时间(yyyy.MM.dd HH:mm)
@property (strong) NSString *sBuyer;
@property (strong) NSString *sEndTime;
@property (strong) NSString *sGold;         //订单费用(荐币)
@property (strong) NSString *sPersonalName;
@property (strong) NSString *sPersonalNo;   //人选编号
@property (strong) NSString *sSeller;
@property (strong) NSString *sStatus;       //服务状态
@property (strong) NSString *sUserNoBuyer;  //购买者编号
@property (strong) NSString *sUserNoSeller; //出售者编号
@property (strong) NSString *sStatusText;
@property (strong) NSString *sAvatarBuyer;
@property (strong) NSString *sAvatarSeller;

@property (strong) WJPersonalInfo *sPerson;     //人选信息
@property (strong) WJAppraiseInfo *sAppraise;   //推荐信信息(可为空)

@end

