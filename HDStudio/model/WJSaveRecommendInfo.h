//
//  WJSaveRecommendInfo.h
//  JianJian
//
//  Created by liudu on 15/5/4.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJSaveRecommendInfo : NSObject

@property (strong) NSString *matchid;//评价编号
@property (strong) NSString *recommendId;//推荐编号
@property (strong) NSString *personalno;//人选编号
@property (strong) NSString *name;
@property (strong) NSString *mobile;//电话
@property (strong) NSString *currentEnterprise;//当前公司
@property (strong) NSString *currentposition;//当前职位
@property (strong) NSString *ishide ;//是否匿名

@end
