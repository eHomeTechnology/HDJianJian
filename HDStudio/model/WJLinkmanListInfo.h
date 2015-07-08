//
//  WJLinkmanListInfo.h
//  JianJian
//
//  Created by liudu on 15/7/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJLinkmanListInfo : NSObject

@property (strong) NSString *sUserID;           //用户编号
@property (strong) NSString *sNickName;         //昵称
@property (strong) NSString *sLevel;            //会员级别
@property (strong) NSString *sApprove;
@property (assign) BOOL     IsPerfect;          //资料完善状态
@property (strong) NSString *sAvatar;
@property (strong) NSString *sShopName;
@property (strong) NSString *sToken;
@property (strong) NSString *sToken1;
@property (strong) NSString *sBackground;
@property (strong) NSString *sFunctionCode;
@property (strong) NSString *sBusinessCode;
@property (strong) NSString *sWorkPlaceCode;
@property (strong) NSString *sStartWorkDT;
@property (strong) NSString *sWorkYears;
@property (strong) NSString *CODE_WX;
@property (strong) NSString *CODE_QQ;
@property (strong) NSString *sMPhone;
@property (strong) NSString *sCurPosition;
@property (strong) NSString *sCurCompany;
@property (strong) NSString *sHXResStatus;      //环信注册状态
@property (strong) NSString *sAnnounce;         //荐客简介
@property (strong) NSString *sAuthenCompany;    //认证公司
@property (strong) NSString *sAuthenPosition;   //认证职位
@property (strong) NSString *sFunctionText;
@property (strong) NSString *sBusinessText;
@property (strong) NSString *sWorkPlaceText;
@property (strong) NSString *sRoleType;
@property (assign) BOOL     IsFocus;

@end
