//
//  HDEvaluateInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDEvaluateInfo : NSObject

@property (strong) NSString     *sEvalueId;         //评价编号
@property (strong) NSString     *sPersonalNo;       //人选编号，被评价人
@property (strong) NSString     *sRecommendId;      //推荐编号，该类附属于HDRecommendInfo,此ID即为HDRecommednInfo Id
@property (strong) NSString     *sRefereeId;        //推荐人ID，小伙伴
@property (strong) NSString     *sMatchPoint1;      //评价1
@property (strong) NSString     *sMatchPoint2;      //评价2
@property (strong) NSString     *sMatchPoint3;      //评价3
@property (strong) NSString     *sMatchPoint4;      //评价4
@property (strong) NSString     *sMatchPoint5;      //评价5
@property (strong) NSString     *sCreateTime;       //评价时间
@property (strong) NSString     *sRemark;           //总体评价，评价内容
@property (strong) NSString     *sStatus;           //未知，接口文档未描述，且当预留
@property (strong) NSString     *sProperty;         //未知，接口文档未描述，且当预留


@end
