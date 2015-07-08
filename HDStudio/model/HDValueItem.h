//
//  HDValueInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDValueItem : NSObject

@property (strong) NSString *sCodeID;
@property (strong) NSString *sValue;
@property (strong) NSString *sKey;

+ (id)infoWithValue:(NSString *)value key:(NSString *)key code:(NSString *)code;
- (id)initWithValue:(NSString *)value key:(NSString *)key code:(NSString *)code;
+ (id)getValueInfoWithKey:(NSString *)key type:(HDExtendType)type;
+ (id)getValueInfoWithKey:(NSString *)key dataResource:(NSArray *)ar;
@end
@interface HDValueInfo : HDValueItem
@property (strong) NSMutableArray *mar_items;
@end


@interface HDEducationInfo : HDValueItem

+ (HDEducationInfo *)getEducationInfoWithKey:(NSString *)key;

@end

@interface HDSalaryInfo : HDValueItem

@end

@interface HDPropertyInfo : HDValueItem

@end

@interface HDWorkExpInfo : HDValueItem

/**
 @brief     根据工作年限key，返回工作年限名称
 @param     key workExp的key，非空
 @return    workExp的名称，错误的话返回nil
 */
+ (NSString *)getWorkExpValueWithKey:(NSString *)key;

/**
 @brief     根据key，返回对应HDWorkExpInfo
 @param     key workExp的key，非空
 @return    workExpInfo，错误的话返回nil
 */
+ (HDWorkExpInfo *)getWorkExpInfoWithKey:(NSString *)key;

/**
 @brief     根据StartWorkDT，返回对应HDWorkExpInfo
 @param     date 开始工作时间，格式应该为：“2015-03-21”，非空
 @return    workExpInfo，错误的话返回nil
 */
+ (HDWorkExpInfo *)getWorkInfoWithStartWorkDT:(NSString *)date;

/**
 @brief     根据起始工作时间，计算并返回工作了“多少年”字符串
 @param     date 时间，格式为“2010-02-12”，非空
 @return    工作时间段描述，秒速详情参考工程中workExp.plist文件
 */
+ (NSString *)getWorkExpValueWithStartWorkDT:(NSString *)date;

/**
 @brief     根据key，计算并返回工作了“多少年”字符串,即描述
 @param     key ，非空
 @return    工作时间段描述，描述详情参考工程中workExp.plist文件
 */
+ (NSString *)getWorkYearDescWithKey:(NSString *)key;
/**
 @brief     根据WorkExpCode，计算并返回工作时间，形式为：“2010-03-12”
 @param     yearDescribe 时间描述，格式为“2010-02-12”，非空
 @return    工作时间段描述，秒速详情参考工程中workExp.plist文件
 @discussion   该方法主要用途：125接口中的参数startWorkDT，
 */
+ (NSString *)getWorkStartDTWithWorkExpValue:(NSString *)yearDescribe;


//根据时间间隔（年数）与当前系统时间（2015-05-04）计算出之前的年月份。形式为（2013-03-04）
+ (NSString *)getWorkYearTimeDifference:(NSInteger)date;
@end

@interface HDAreaItem : HDValueItem

@property (strong) NSString *sParentID;     //该子区域的父区域标识

@end


@interface HDAreaInfo : HDValueInfo

/**
 @brief     根据地区key，返回地区item
 @param     key 地区key，非空
 @return    HDAreaItem实例，错误的话返回nil
 */
+ (HDAreaItem *)getAreaItemWithkey:(NSString *)key;

/**
 @brief     根据地区key，返回地区名称
 @param     key 地区key,非空
 @return    区域名称，错误的话返回nil
 */
+ (NSString *)getAreaValueWithKey:(NSString *)key;


@end


@interface HDTradeInfo : HDValueItem

/**
 @brief     根据tradeInfo的code，返回最多3个HDTradeInfo组成的数组
 @param     code tradeInfo的code,非空，最多3个值
 @return    HDTradeInfo组成的数组，错误的话返回nil
 */
+ (NSMutableArray *)getTradeInfosWithKeys:(NSArray *)codes;

/**
 @brief     根据tradeInfo的code，返回最多3个行业名称组合
 @param     code tradeInfo的code,非空，最多3个值
 @return    tradeInfo的名称组合，错误的话返回nil
 */
+ (NSString *)getTradeValueWithKeys:(NSArray *)codes;

@end


@interface HDPostItem : HDValueItem
@property (strong) NSString *sParentID;
@end

@interface HDPostInfo : HDValueInfo

/**
 @brief     根据postItem的code，返回postItem数组，
 @param     code postItem的code,非空，最多3个值
 @return    postItem数组，错误的话返回nil
 */
+ (NSMutableArray *)getPostItemsWithKeys:(NSArray *)codes;

/**
 @brief     根据postItem的code，返回行业名称
 @param     code postItem的code，非空，最多3个值
 @return    postItem的名称，错误的话返回nil
 */
+ (NSString *)getPostValuesWithKeys:(NSArray *)codes;

@end
