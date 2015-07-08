//
//  HDUserInfo.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDUserInfo.h"

@implementation HDMyJianJianInfo

@end

@implementation HDUserInfo
- (HDUserInfo *)initWithBrokerInfo:(WJBrokerInfo *)info{
    if (self) {
        self.sAreaKey           = info.sAreaKey.length > 0? info.sAreaKey: self.sAreaKey;
        self.sTradeKey          = info.sTradeKey.length > 0? info.sTradeKey: self.sTradeKey;
        self.sPostKey           = info.sPostKey.length > 0? info.sPostKey: self.sPostKey;
        self.sAreaText          = info.sAreaText.length > 0? info.sAreaText: self.sAreaText;
        self.sPostText          = info.sPostText.length > 0? info.sPostText: self.sPostText;
        self.sTradeText         = info.sTradeText.length > 0? info.sTradeText: self.sTradeText;
        self.sBackground        = info.sBackground.length > 0? info.sBackground: self.sBackground;
        self.sCreatedDT         = info.sCreatedDT.length > 0? info.sCreatedDT: self.sCreatedDT;
        self.sCurCompany        = info.sCurCompany.length > 0? info.sCurCompany: self.sCurCompany;
        self.sCurPosition       = info.sCurPosition.length > 0? info.sCurPosition: self.sCurPosition;
        self.sProperty          = info.sProperty.length > 0? info.sProperty: self.sProperty;
        self.sRemark            = info.sRemark.length > 0? info.sRemark: self.sRemark;
        self.sShopMPhone        = info.sShopMPhone.length > 0? info.sShopMPhone: self.sShopMPhone;
        self.sShopType          = info.sShopType.length > 0? info.sShopType: self.sShopType;
        self.sRoleType          = info.sRoleType.length > 0? info.sRoleType: self.sRoleType;
        self.sStartWorkDT       = info.sStartWorkDT.length > 0? info.sStartWorkDT: self.sStartWorkDT;
        self.sWorkYears         = info.sWorkYears.length > 0? info.sWorkYears: self.sWorkYears;
        self.sAnnounce          = info.sAnnounce.length > 0? info.sAnnounce: self.sAnnounce;
        self.sShopName          = info.sShopName.length > 0? info.sShopName: self.sShopName;
        self.sAuthenCompany     = info.sAuthenCompany.length > 0? info.sAuthenCompany: self.sAuthenCompany;
        self.sAuthenPosition    = info.sAuthenPosition.length > 0? info.sAuthenPosition: self.sAuthenPosition;
        self.sMemberLevel       = info.sMemberLevel.length > 0? info.sMemberLevel: self.sMemberLevel;
        self.isFocus            = info.isFocus;
        self.isAuthen           = info.isAuthen;
    }
    return self;
}

+ (NSString *)path{
    NSString * doc = HDDocumentPath;
    NSString * path = [doc stringByAppendingPathComponent:@"newsInfo.sqlite"];
    return path;
}

+ (BOOL)createTable{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self path]] == YES) {
        return YES;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[self path]];
    if (![db open]) {
        Dlog(@"Error:Create db failed, error when opened!");
        return NO;
    }
    NSString * sql = @"CREATE TABLE 'SubscribeInfo' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, 'sSubscriberID' VARCHAR(20), 'sSubscribeTick' VARCHAR(30), 'sSubscriberLogo' VARCHAR(100), 'sSubscriberName' VARCHAR(50), 'sCount' VARCHAR(5), 'sMsgID' VARCHAR(5), 'sContent' VARCHAR(1000), 'sTitle' VARCHAR(50), 'sImagePath' VARCHAR(50), 'sUrl' VARCHAR(100), 'formatType' INTEGER, 'bubbleType' INTEGER, 'sCreateTime' VARCHAR(50))";
    if (![db executeUpdate:sql]) {
        Dlog(@"error when creating db table");
        [db close];
        return NO;
    }
    [db close];
    return YES;
}

+ (HDUserInfo *)infoFromDB:(NSString *)sId{
    if (![HDUserInfo createTable]) {
        return nil;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:open db failed");
        return nil;
    }
    NSString * sql = @"select * from SubscribeInfo where sSubscriberID = ?";
    FMResultSet * rs = [db executeQuery:sql, sId];
    while ([rs next]) {
        NSString *s   = [rs stringForColumn:@"sSubscriberID"];
        if ([s isEqualToString:sId]) {
            HDUserInfo *info  = [HDUserInfo new];
//            info.sSubscriberID      = [rs stringForColumn:@"sSubscriberID"];
//            info.sSubscriberLogo    = [rs stringForColumn:@"sSubscriberLogo"];
//            info.sSubscriberName    = [rs stringForColumn:@"sSubscriberName"];
//            info.sCount             = [rs stringForColumn:@"sCount"];
//            info.sMsgID             = [rs stringForColumn:@"sMsgID"];
//            info.sContent           = [rs stringForColumn:@"sContent"];
//            info.sTitle             = [rs stringForColumn:@"sTitle"];
//            info.sImagePath         = [rs stringForColumn:@"sImagePath"];
//            info.sUrl               = [rs stringForColumn:@"sUrl"];
//            info.formatType         = [rs intForColumn:@"formatType"];
//            info.bubbleType         = [rs intForColumn:@"bubbleType"];
//            info.sCreateTime        = [rs stringForColumn:@"sCreateTime"];
//            info.sSubscribeTick     = [rs stringForColumn:@"sSubscribeTick"];
            [db close];
            return info;
        }
    }
    [db close];
    return nil;
}

- (BOOL)insert_update2DB{
    if ([self isExistInDB]) {
        return [self update2DB];
    }
    return [self insert2DB];
}
- (BOOL)update2DB{
    if (![HDUserInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return NO;
    }
//    NSString * sql = @"UPDATE SubscribeInfo SET sSubscribeTick = ?, sSubscriberLogo = ?, sSubscriberName = ?, sCount = ?, sMsgID = ?, sContent = ?, sTitle = ?, sImagePath = ?, sUrl = ?, formatType = ?, bubbleType = ?, sCreateTime = ? WHERE sSubscriberID = ?";
//    BOOL res = [db executeUpdate:sql, self.sSubscribeTick, self.sSubscriberLogo, self.sSubscriberName, self.sCount, self.sMsgID, self.sContent, self.sTitle, self.sImagePath, self.sUrl, @(self.formatType), @(self.bubbleType), self.sCreateTime, self.sSubscriberID];
//    if (!res) {
//        Dlog(@"ERROR:error to insert data");
//        [db class];
//        return NO;
//    }
    [db close];
    return YES;
}
- (BOOL)insert2DB{
    if (![HDUserInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return NO;
    }
//    NSString * sql = @"insert into SubscribeInfo (sSubscriberID, sSubscribeTick, sSubscriberLogo, sSubscriberName, sCount, sMsgID, sContent, sTitle, sImagePath, sUrl, formatType, bubbleType, sCreateTime) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
//    BOOL res = [db executeUpdate:sql, self.sSubscriberID, self.sSubscribeTick, self.sSubscriberLogo, self.sSubscriberName, self.sCount, self.sMsgID, self.sContent, self.sTitle, self.sImagePath, self.sUrl, @(self.formatType), @(self.bubbleType), self.sCreateTime];
//    if (!res) {
//        Dlog(@"ERROR:error to insert data");
//        [db class];
//        return NO;
//    }
    [db close];
    return YES;
}
- (BOOL)isExistInDB{
    if (![HDUserInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:open db failed");
        return NO;
    }
//   NSString * sql = @"select * from SubscribeInfo where sSubscriberID = ?";
//    FMResultSet * rs = [db executeQuery:sql, self.sSubscriberID];
//    while ([rs next]) {
//        NSString *sId   = [rs stringForColumn:@"sSubscriberID"];
//        if ([sId isEqualToString:self.sSubscriberID]) {
//            [db close];
//            return YES;
//        }
//    }
    [db close];
    return NO;
}

+ (NSArray *)allFromDB{
    if (![HDUserInfo createTable]) {
        return nil;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return nil;
    }
    NSString * sql = @"select * from SubscribeInfo";
    FMResultSet * rs = [db executeQuery:sql];
    NSMutableArray *mar = [NSMutableArray new];
    while ([rs next]) {
//        HDSubscriberInfo *info  = [HDSubscriberInfo new];
//        info.sSubscriberID      = [rs stringForColumn:@"sSubscriberID"];
//        info.sSubscriberLogo    = [rs stringForColumn:@"sSubscriberLogo"];
//        info.sSubscriberName    = [rs stringForColumn:@"sSubscriberName"];
//        info.sCount             = [rs stringForColumn:@"sCount"];
//        info.sMsgID             = [rs stringForColumn:@"sMsgID"];
//        info.sContent           = [rs stringForColumn:@"sContent"];
//        info.sTitle             = [rs stringForColumn:@"sTitle"];
//        info.sImagePath         = [rs stringForColumn:@"sImagePath"];
//        info.sUrl               = [rs stringForColumn:@"sUrl"];
//        info.sCreateTime        = [rs stringForColumn:@"sCreateTime"];
//        info.sSubscribeTick     = [rs stringForColumn:@"sSubscribeTick"];
//        info.bubbleType         = [rs intForColumn:@"bubbleType"];
//        info.formatType         = [rs intForColumn:@"formatType"];
//        [mar addObject:info];
    }
    [db close];
    return mar;
}

+ (BOOL)clearAllFromDB{
    FMDatabase * db = [FMDatabase databaseWithPath:[HDUserInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return NO;
    }
    NSString * sql = @"delete from SubscribeInfo";
    if (![db executeUpdate:sql]) {
        Dlog(@"error to delete db data");
        [db close];
        return NO;
    }
    [db close];
    return YES;
}

@end
