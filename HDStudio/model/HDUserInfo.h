//
//  HDUserInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDbObject.h"
#import "WJBrokerInfo.h"
@interface HDMyJianJianInfo : NSObject

@property (strong) NSString *sBuyCount;         //购买服务数
@property (strong) NSString *sCBlogCount;       //收藏博客数
@property (strong) NSString *sCPersonalCount;   //收藏简历数,
@property (strong) NSString *sCPositionCount;   //分享数,收藏职位数
@property (strong) NSString *sDepositCount;     //保证金余额
@property (strong) NSString *sFanCount;         //粉丝数
@property (strong) NSString *sFocusCount;       //关注数
@property (strong) NSString *sGGold;            //获得收入余额,可提现余额(单位荐币)
@property (strong) NSString *sGold;             //充值余额(单位荐币)
@property (strong) NSString *sGoldCount;        //账户余额(单位荐币)
@property (strong) NSString *sMemberLevel;      //等级
@property (strong) NSString *sPGold;            //赠送余额(单位荐币)
@property (strong) NSString *sPersonalCount;    //发布人才数
@property (strong) NSString *sPositionCount;    //发布职位数
@property (strong) NSString *sRGold;            //获得悬赏总收入(单位荐币)
@property (strong) NSString *sRecommendCount;   //推荐人才数
@property (strong) NSString *sRecruiterCount;   //收到简历数
@property (strong) NSString *sSellCount;        //订单上门数
@property (strong) NSString *sUserNo;           //用户编号
@property (strong) NSString *sVisitCount;       //访客数
@property (strong) NSString *sXP;               //经验值

@end

@interface HDUserInfo : WJBrokerInfo

@property (strong) NSString *sPwd;          //密码
@property (strong) NSString *sAccount;      //账号，一般为电话号码
@property (strong) NSString *sSex;          //性别
@property (strong) NSString *sWeixin;       //微信
@property (strong) NSString *sQQ;           //qq
@property (strong) NSString *sTocken;       //服务器返回授权
@property (strong) NSString *sTocken1;      //登陆环信密码，需要解密
@property (assign) BOOL     isRememberPwd;  //是否记住密码
@property (assign) BOOL     isAutoLogin;    //是否自动登录
@property (assign) BOOL     isPerfect;      //是否设置完整
@property (strong) NSString *sApprove;      //认证，现在基本不用这个字段，详见sRoleType
@property (strong) NSString *sHXResStatus;  //环信注册状态 0：失败 1：成功

- (HDUserInfo *)initWithBrokerInfo:(WJBrokerInfo *)info;
@end

