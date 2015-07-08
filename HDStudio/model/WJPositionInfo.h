//
//  WJPositionInfo.h
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJTradeInfo.h"
#import "HDCompanyInfo.h"

@interface WJPositionInfo : NSObject

@property (strong) NSString *sPositionNo;       //职位编号
@property (strong) NSString *sPositionName;     //职位名称
@property (strong) NSString *sRemark;           //职位描述
@property (strong) NSString *sArea;             //所在地
@property (strong) NSString *sAreaText;         //所在地
@property (strong) NSString *sCompanyNo;        //公司编号
@property (strong) NSString *sCompnayName;      //公司名称
@property (strong) NSString *sPublishTime;      //发布时间
@property (assign) BOOL     isBonus;            //是否悬赏
@property (assign) BOOL     isDeposit;          //是否缴纳保证金
@property (assign) BOOL     isCollect;          //是否收藏  收藏标志(0,1)
@property (strong) NSString *sFunctionCode;     //职能编号
@property (strong) NSString *sFunctionText;     //职能
@property (strong) NSString *sTradeKey;         //行业key
@property (strong) NSString *sEducationCode;    //职位要求教育程度编码
@property (strong) NSString *sEducationText;    //职位要求教育程度描述
@property (strong) NSString *sWorkExpCode;      //职位要求工作年限编码
@property (strong) NSString *sWorkExpText;      //职位要求工作年限描述
@property (strong) NSString *sSalaryCode;       //职位工资编号
@property (strong) NSString *sSalaryText;       //职位工资描述
@property (strong) NSString *sProperty;         //属性
@property (strong) NSString *sReward;           //悬赏金(荐币)
@property (strong) NSString *sUrl;              //职位的预览网络地址
@property (strong) NSString *sHit;              //职位访问量
@property (strong) NSString *sUpCount;          //职位推荐量
@property (strong) NSString *sDivisionName;     //部门名称
@property (strong) NSString *sDelayDay;         //

@property (strong) HDEmployerInfo   *employerInfo;  //公司子对象
@property (strong) WJBrokerInfo     *brokerInfo;    //招聘者信息子对象
@property (strong) WJTradeInfo      *tradeInfo;     //交易信息子对象

- (NSString *)changeBr2n:(NSString *)s;

@end
