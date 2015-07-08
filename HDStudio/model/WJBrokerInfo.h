//
//  WJJJSearchInfo.h
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDTalentInfo.h"

@interface WJBrokerInfo : HDHumanInfo

@property (strong) NSString *sAreaKey;      //工作地点
@property (strong) NSString *sTradeKey;     //行业
@property (strong) NSString *sPostKey;      //职能
@property (strong) NSString *sAreaText;     //工作地点文本
@property (strong) NSString *sPostText;     //职能描述
@property (strong) NSString *sTradeText;    //行业描述
@property (strong) NSString *sBackground;   //店铺背景
@property (strong) NSString *sCreatedDT;    //创建时间
@property (strong) NSString *sCurCompany;   //当前公司
@property (strong) NSString *sCurPosition;  //当前职位
@property (strong) NSString *sProperty;     //属性，具体干嘛，未知
@property (strong) NSString *sRemark;       //荐客简介，和sAnnounce值一致
@property (strong) NSString *sShopMPhone;   //商店联系电话
@property (strong) NSString *sShopType;     //荐客类型
@property (strong) NSString *sRoleType;     //认证类型 0未认证  100企业认证 200荐客 204猎头 203企业HR 202企业高管  201Boss
@property (strong) NSString *sStartWorkDT;  //工作日期
@property (strong) NSString *sWorkYears;    //工作年限
@property (assign) BOOL     isFocus;        //是否关注
@property (assign) BOOL     isAuthen;
@property (strong) NSString *sAnnounce;         //荐客简介，和sRemark值一致
@property (strong) NSString *sShopName;         //店铺名称
@property (strong) NSString *sAuthenCompany;    //认证公司
@property (strong) NSString *sAuthenPosition;   //认证职位
@property (strong) NSString *sMemberLevel;      //会员级别，会员级别 1,注册会员 2,铜牌会员 3,银牌会员 4,金牌会员 5,钻石会员 6,皇冠会员

+ (WJBrokerInfo *)infoWithContactInfo:(HDHumanInfo *)info;

@end


