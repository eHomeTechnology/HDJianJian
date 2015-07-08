//
//  HDValueInfo.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDValueItem.h"

@implementation HDValueItem

+ (id)infoWithValue:(NSString *)value key:(NSString *)key code:(NSString *)code{
    
    return [[self alloc] initWithValue:value key:key code:code];
}

- (id)initWithValue:(NSString *)value key:(NSString *)key code:(NSString *)code{
    if (value.length == 0 || key.length == 0) {
        Dlog(@"Error:初始化错误");
        return nil;
    }
    if (self = [super init]) {
        self.sValue     = value;
        self.sKey       = key;
        self.sCodeID    = code;
    }
    return self;
}

+ (id)getValueInfoWithKey:(NSString *)key type:(HDExtendType)type{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSArray *ar = nil;
    switch (type) {
        case HDExtendTypeEducation:{
            ar = [HDGlobalInfo instance].mar_education;
            break;
        }
        case HDExtendTypeArea:{
            NSMutableArray *mar = [NSMutableArray new];
            NSArray *ar_Infos = [HDGlobalInfo instance].mar_area;
            for (int n = 0; n < ar_Infos.count; n++) {
                HDAreaInfo *info = ar_Infos[n];
                for (int m = 0; m < info.mar_items.count; m++) {
                    HDPostItem *item = info.mar_items[m];
                    [mar addObject:item];
                }
            }
            ar = mar;
            break;
        }
        case HDExtendTypePost:{
            NSMutableArray *mar = [NSMutableArray new];
            NSArray *ar_postInfo = [HDGlobalInfo instance].mar_post;
            for (int n = 0; n < ar_postInfo.count; n++) {
                HDPostInfo *post = ar_postInfo[n];
                for (int m = 0; m < post.mar_items.count; m++) {
                    HDPostItem *item = post.mar_items[m];
                    [mar addObject:item];
                }
            }
            ar = mar;
            break;
        }
        case HDExtendTypeProperty:{
            ar = [HDGlobalInfo instance].mar_property;
            break;
        }
        case HDExtendTypeSalary:{
            ar = [HDGlobalInfo instance].mar_salary;
            break;
        }
        case HDExtendTypeTrade:{
            ar = [HDGlobalInfo instance].mar_trade;
            break;
        }
        case HDExtendTypeWorkExp:{
            ar = [HDGlobalInfo instance].mar_workExp;
            break;
        }
        default:
            break;
    }
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“Education数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDValueItem *value = ar[i];
        if ([key isEqualToString:value.sKey]) {
            return value;
        }
    }
    return nil;
}

+ (id)getValueInfoWithKey:(NSString *)key dataResource:(NSArray *)ar{
    if (key.length == 0) {
        Dlog(@"Error:传入参数key有误");
        return nil;
    }
    if (ar.count == 0) {
        Dlog(@"Error:传入参数ar有误！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDEducationInfo *edu = ar[i];
        if ([key isEqualToString:edu.sKey]) {
            return edu;
        }
    }
    return nil;
}

@end

@implementation HDValueInfo

@end

@implementation HDSalaryInfo
@end

@implementation HDEducationInfo
+ (HDEducationInfo *)getEducationInfoWithKey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSArray *ar = [HDGlobalInfo instance].mar_education;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“Education数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDEducationInfo *edu = ar[i];
        if ([key isEqualToString:edu.sKey]) {
            return edu;
        }
    }
    return nil;
}
@end

@implementation HDPropertyInfo
@end

@implementation HDWorkExpInfo

+ (NSString *)getWorkExpValueWithKey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSArray *ar = [HDGlobalInfo instance].mar_workExp;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“workExp数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDWorkExpInfo *workExp = ar[i];
        if ([key isEqualToString:workExp.sKey]) {
            return workExp.sValue;
        }
    }
    return nil;
}

+ (HDWorkExpInfo *)getWorkExpInfoWithKey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSArray *ar = [HDGlobalInfo instance].mar_workExp;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“workExp数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDWorkExpInfo *workExp = ar[i];
        if ([key isEqualToString:workExp.sKey]) {
            return workExp;
        }
    }
    return nil;
}

+ (HDWorkExpInfo *)getWorkInfoWithStartWorkDT:(NSString *)date{
    if (date.length == 0) {
        Dlog(@"Error:传入参数有误！");
        return nil;
    }
    NSArray *ar = [date componentsSeparatedByString:@"-"];
    if (ar.count != 3) {
        Dlog(@"Error:传入参数有误2！");
        return nil;
    }
    NSArray *ar_workExp = [HDGlobalInfo instance].mar_workExp;
    if (ar_workExp.count == 0) {
        Dlog(@"Error:全局参数“workExp数据”为空！");
        return nil;
    }
    NSString *today = [HDUtility readNowTimeWithFormate:@"yyyy-MM-dd"];
    NSString *toyear = [today substringToIndex:4];
    int iDef = [toyear intValue] - [ar[0] intValue];
    if (iDef < 0) {
        Dlog(@"Error:数据出错了!");
        return nil;
    }
    switch (iDef) {
        case 0:{
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"1年以下"]) {
                    return info;
                }
            }
        }
        case 1:
        case 2:{
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"1-2年"]) {
                    return info;
                }
            }
        }
        case 3:
        case 4:
        case 5:{
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"3-5年"]) {
                    return info;
                }
            }
        }
        case 6:
        case 7:{
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"6-7年"]) {
                    return info;
                }
            }
        }
        case 8:
        case 9:
        case 10:{
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"8-10年"]) {
                    return info;
                }
            }
        }
        default:
            for (HDWorkExpInfo *info in ar_workExp) {
                if ([info.sValue isEqualToString:@"10年以上"]) {
                    return info;
                }
            }
    }
    return nil;
}

+ (NSString *)getWorkExpValueWithStartWorkDT:(NSString *)date{
    if (date.length == 0) {
        return @"不限";
    }
    NSArray *ar = [date componentsSeparatedByString:@"-"];
    if (ar.count != 3) {
        Dlog(@"Error:传入参数有误2！");
        return nil;
    }
    NSString *today = [HDUtility readNowTimeWithFormate:@"yyyy-MM-dd"];
    NSString *toyear = [today substringToIndex:4];
    int iDef = [toyear intValue] - [ar[0] intValue];
    if (iDef < 0) {
        Dlog(@"Error:数据出错了!");
        return nil;
    }
    switch (iDef) {
        case 0:{
            return @"1年以下";
        }
        case 1:
        case 2:{
            return @"1-2年";
        }
        case 3:
        case 4:
        case 5:{
            return @"3-5年";
        }
        case 6:
        case 7:{
            return @"6-7年";
        }
        case 8:
        case 9:
        case 10:{
            return @"8-10年";
        }
        default:
            return @"10年以上";
    }
}

+ (NSString *)getWorkStartDTWithWorkExpValue:(NSString *)yearDescribe{
    if (yearDescribe.length == 0) {
        Dlog(@"Error:传入参数有误！");
        return nil;
    }
    if ([yearDescribe isEqualToString:@"不限"]) {
        return nil;
    }
    NSString *today = [HDUtility readNowTimeWithFormate:@"yyyy-MM-dd"];
    NSString *toyear = [today substringToIndex:4];
    NSString *sMMdd = [today substringFromIndex:4];
    Dlog(@"sMMdd = %@", sMMdd);
    if ([yearDescribe hasPrefix:@"10年"]) {
        NSString *sYear = FORMAT(@"%d", [toyear intValue] - 10);
        return  FORMAT(@"%@%@", sYear, sMMdd);
    }
    if ([yearDescribe hasPrefix:@"1年"]) {
        return [HDUtility readNowTimeWithFormate:@"yyyy-MM-dd"];
    }
    int theYear = [toyear intValue] - [[yearDescribe substringToIndex:1] intValue];
    return FORMAT(@"%d%@", theYear, sMMdd);
}

+ (NSString *)getWorkYearDescWithKey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    NSArray *ar_workExp = [HDGlobalInfo instance].mar_workExp;
    if (ar_workExp.count == 0) {
        Dlog(@"Error:全局参数“workExp数据”为空！");
        return nil;
    }
    for (HDWorkExpInfo *info in ar_workExp) {
        if ([info.sKey isEqualToString:key]) {
            return info.sValue;
        }
    }
    return nil;
}

+ (NSString *)getWorkYearTimeDifference:(NSInteger )date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:-date];
    [adcomps setMonth:0];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *locationString=[formatter stringFromDate: newdate];
    return locationString;
}

@end

@implementation HDAreaItem

@end

@implementation HDAreaInfo
- (id)init{
    if (self = [super init]) {
        self.mar_items = [NSMutableArray new];
    }
    return self;
}

+ (HDAreaItem *)getAreaItemWithkey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSArray *ar = [HDGlobalInfo instance].mar_area;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“地区数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDAreaInfo *area = ar[i];
        for (int j = 0; j < area.mar_items.count; j++) {
            HDAreaItem *item = area.mar_items[j];
            if ([key isEqualToString:item.sKey]) {
                return item;
            }
        }
    }
    return nil;
}

+ (NSString *)getAreaValueWithKey:(NSString *)key{
    if (key.length == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    if (key.intValue < 0) {
        return @"不限";
    }
    NSArray *ar = [HDGlobalInfo instance].mar_area;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“地区数据”为空！");
        return nil;
    }
    for (int i = 0; i < ar.count; i++) {
        HDAreaInfo *area = ar[i];
        for (int j = 0; j < area.mar_items.count; j++) {
            HDAreaItem *item = area.mar_items[j];
            if ([key isEqualToString:item.sKey]) {
                return item.sValue;
            }
        }
    }
    return nil;
}
@end

@implementation HDTradeInfo

+ (NSMutableArray *)getTradeInfosWithKeys:(NSArray *)keys{
    if (!keys) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (keys.count == 0 || keys.count > 3) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    NSArray *ar = [HDGlobalInfo instance].mar_trade;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“trade数据”为空!");
        return nil;
    }
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < keys.count; i++) {
        NSString *sCode = keys[i];
        for (int n = 0; n < ar.count; n++) {
            HDTradeInfo *trade = ar[n];
            if ([sCode isEqualToString:trade.sKey]) {
                [mar addObject:trade];
                break;
            }
        }
    }
    return mar;
}

+ (NSString *)getTradeValueWithKeys:(NSArray *)keys{
    if (!keys) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (keys.count == 0 || keys.count > 3) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (((NSString *)keys[0]).integerValue < 0) {
        return @"不限";
    }
    NSArray *ar = [HDGlobalInfo instance].mar_trade;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“trade数据”为空!");
        return nil;
    }
    NSString *sValue = @"";
    for (int i = 0; i < keys.count; i++) {
        NSString *sCode = keys[i];
        for (int n = 0; n < ar.count; n++) {
            HDTradeInfo *trade = ar[n];
            if ([sCode isEqualToString:trade.sKey]) {
                sValue = FORMAT(@"%@+%@", sValue, trade.sValue);
                break;
            }
        }
    }
    if ([sValue hasPrefix:@"+"]) {
        sValue = [sValue substringFromIndex:1];
    }
    return sValue;
    
}

@end



@implementation HDPostItem


@end

@implementation HDPostInfo

- (id)init{
    
    if (self = [super init]) {
        if (!self.mar_items) {
            self.mar_items = [NSMutableArray new];
        }
    }
    return self;
}

+ (NSMutableArray *)getPostItemsWithKeys:(NSArray *)keys{
    if (!keys) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (keys.count == 0 || keys.count > 3) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (((NSString *)keys[0]).intValue < 0) {
        HDPostItem *item = [HDPostItem infoWithValue:@"不限" key:@"0" code:nil];
        return [[NSMutableArray alloc] initWithArray:@[item]];
    }
    NSArray *ar = [HDGlobalInfo instance].mar_post;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“post数据”为空!");
        return nil;
    }
    
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < keys.count; i++) {
        NSString *sCode = keys[i];
        for (int n = 0; n < ar.count; n++) {
            HDPostInfo *post = ar[n];
            for (int m = 0; m < post.mar_items.count; m++) {
                HDPostItem *item = post.mar_items[m];
                if ([sCode isEqualToString:item.sKey]) {
                    [mar addObject:item];
                    n = (int)ar.count;
                    break;
                }
            }
        }
    }
    return mar;
}

+ (NSString *)getPostValuesWithKeys:(NSArray *)keys{
    if (!keys) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (keys.count == 0 || keys.count > 3) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    if (((NSString *)keys[0]).intValue < 0) {
        return @"不限";
    }
    NSArray *ar = [HDGlobalInfo instance].mar_post;
    if (ar.count == 0) {
        Dlog(@"Error:全局参数“post数据”为空!");
        return nil;
    }
    NSString *sValue = @"";
    for (int i = 0; i < keys.count; i++) {
        NSString *sCode = keys[i];
        for (int n = 0; n < ar.count; n++) {
            HDPostInfo *post = ar[n];
            for (int m = 0; m < post.mar_items.count; m++) {
                HDPostItem *item = post.mar_items[m];
                if ([sCode isEqualToString:item.sKey]) {
                    sValue = FORMAT(@"%@+%@", sValue, item.sValue);
                    n = (int)ar.count;
                    break;
                }
            }
        }
    }
    if ([sValue hasPrefix:@"+"]) {
        sValue = [sValue substringFromIndex:1];
    }
    return sValue;
}

@end

