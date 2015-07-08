//
//  HDGlobleInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDSideMenu.h"
#import "HDUserInfo.h"
#import "HDShopInfo.h"
#import "HDAddressInfo.h"
#import "HDEmUserInfo.h"

@interface HDGlobalInfo : NSObject

@property (strong) JDSideMenu       *sideMenu;
@property (strong) HDShopInfo       *shopInfo;
@property (strong) NSMutableArray   *mar_positions;
@property (strong) NSMutableArray   *mar_recommend;
@property (assign) BOOL             hasLogined;
@property (strong) HDEmUserInfo     *emUserInfo;

//荐荐
@property (strong) HDUserInfo       *userInfo;      //用户信息
@property (strong) HDAddressInfo    *addressInfo;   //地址信息
@property (strong) NSMutableArray   *mar_feedback;  //反馈
@property (strong) NSMutableArray   *mar_trade;     //行业
@property (strong) NSMutableArray   *mar_post;      //职能
@property (strong) NSMutableArray   *mar_area;      //区域
@property (strong) NSMutableArray   *mar_workExp;   //工作年限
@property (strong) NSMutableArray   *mar_salary;    //年薪
@property (strong) NSMutableArray   *mar_education; //学历
@property (strong) NSMutableArray   *mar_property;  //公司性质
@property (strong) NSMutableArray   *mar_bank;      //银行
@property (strong) NSMutableArray   *mar_reward;    //赏金

@property (strong) NSMutableDictionary  *mdc_preset;//预设值，用户选择行业、城市、年限、职位的全局数据，

@property (strong) NSMutableArray   *mar_onPosition;
@property (strong) NSMutableArray   *mar_offPosition;
+ (HDGlobalInfo *)instance;

@end
