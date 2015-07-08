//
//  HDJFriendInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDJFriendInfo : NSObject

@property (strong) NSString *sCreatedDt;        //推荐时间
@property (strong) NSString *sMatchCount;
@property (strong) NSString *sPCompany;
@property (strong) NSString *sPMPhone;
@property (strong) NSString *sPName;
@property (strong) NSString *sPPosition;        //人选当前职位
@property (strong) NSString *sPersonalNo;       //人选编号
@property (strong) NSString *sPositionName;     //推荐职位
@property (strong) NSString *sPositionNo;
@property (strong) NSString *sProgress;
@property (strong) NSString *sProgressText;
@property (strong) NSString *sRCompany;
@property (strong) NSString *sRCreatedDT;       //推荐人注册时间
@property (strong) NSString *sRMPhone;
@property (strong) NSString *sRName;
@property (strong) NSString *sRPosition;        //推荐人（小伙伴）的当前职位
@property (strong) NSString *sRecommendID;      //推荐编号，此类的唯一数
@property (strong) NSString *sReferee;
@property (strong) NSString *sStartWorkTime;    
@property (strong) NSString *sWorkYears;

@end