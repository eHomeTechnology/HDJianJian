//
//  HDNewsInfo.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewsInfo.h"

@implementation HDMessageInfo

@end

@implementation HDSubscriberInfo

+ (void)subscriberInfoFromEmConversation:(EMConversation *)conversation block:(void(^)(HDSubscriberInfo *subInfo))block{
    Dlog(@"conversatino = %@", conversation.latestMessage);
    if (!conversation) {
        Dlog(@"Error:传入参数错误");
        block(nil);
        return ;
    }
    if (conversation.latestMessage.messageBodies.count == 0) {
        Dlog(@"警告：%@conversation没有消息记录",conversation.chatter);
        block(nil);
        return ;
    }
    HDSubscriberInfo *sub = [HDSubscriberInfo new];
    [[HDHttpUtility sharedClient] getBrokerInfo:[HDGlobalInfo instance].userInfo userno:conversation.chatter completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info) {
        if (!isSuccess) {
            Dlog(@"Error:124请求荐客详情错误");
            block(nil);
            return ;
        }
        sub.sSubscriberName     = info.sName;
        sub.sSubscriberLogo     = info.sAvatarUrl;
        sub.sSubscriberID       = info.sHumanNo;
        sub.sCount              = @(conversation.unreadMessagesCount).stringValue;
        sub.platformType        = HDMessagePlatformTypeEasMobe;
        sub.sCreateTime         = @(conversation.latestMessage.timestamp).stringValue;
        NSDictionary *ext       = conversation.latestMessage.ext;
        sub.formatType          = ((NSString *)ext[@"chat_formattype"]).intValue;
        id<IEMMessageBody> messageBody = conversation.latestMessage.messageBodies[0];
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:{
                sub.sContent    = ((EMTextMessageBody *)messageBody).text;
                break;
            }
            case eMessageBodyType_Image:{
                sub.sBodyImage  = ((EMImageMessageBody *)messageBody).image.localPath;
                sub.sContent    = @"[图片]";
                break;
            }
            default:
                break;
        }
        block(sub);
        return;
    }];
}

+ (NSString *)path{
    NSString * doc = HDDocumentPath;
    NSString * path = [doc stringByAppendingPathComponent:FORMAT(@"newsInfo_%@.sqlite", [HDGlobalInfo instance].userInfo.sHumanNo)];
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
    NSString * sql = @"CREATE TABLE 'SubscribeInfo' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, 'sSubscriberID' VARCHAR(20), 'sSubscribeTick' VARCHAR(30), 'sSubscriberLogo' VARCHAR(100), 'sSubscriberName' VARCHAR(50), 'sCount' VARCHAR(5), 'sMsgID' VARCHAR(5), 'sContent' VARCHAR(1000), 'sTitle' VARCHAR(50), 'sImagePath' VARCHAR(50), 'sAvatarUrl' VARCHAR(100), 'formatType' INTEGER, 'bubbleType' INTEGER, 'sCreateTime' VARCHAR(50))";
    if (![db executeUpdate:sql]) {
        Dlog(@"error when creating db table");
        [db close];
        return NO;
    }
    [db close];
    return YES;
}

+ (HDSubscriberInfo *)infoFromDB:(NSString *)sId{
    if (![HDSubscriberInfo createTable]) {
        return nil;
    }
    FMDatabase *db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
    if (![db open]) {
        Dlog(@"Error:open db failed");
        return nil;
    }
    NSString *sql = @"select * from SubscribeInfo where sSubscriberID = ?";
    FMResultSet *rs = [db executeQuery:sql, sId];
    while ([rs next]) {
        NSString *s   = [rs stringForColumn:@"sSubscriberID"];
        if ([s isEqualToString:sId]) {
            HDSubscriberInfo *info  = [HDSubscriberInfo new];
            info.sSubscriberID      = [rs stringForColumn:@"sSubscriberID"];
            info.sSubscriberLogo    = [rs stringForColumn:@"sSubscriberLogo"];
            info.sSubscriberName    = [rs stringForColumn:@"sSubscriberName"];
            info.sCount             = [rs stringForColumn:@"sCount"];
            info.sMsgID             = [rs stringForColumn:@"sMsgID"];
            info.sContent           = [rs stringForColumn:@"sContent"];
            info.sTitle             = [rs stringForColumn:@"sTitle"];
            info.sAvatarUrl         = [rs stringForColumn:@"sAvatarUrl"];
            info.formatType         = [rs intForColumn:@"formatType"];
            info.bubbleType         = [rs intForColumn:@"bubbleType"];
            info.sCreateTime        = [rs stringForColumn:@"sCreateTime"];
            info.sSubscribeTick     = [rs stringForColumn:@"sSubscribeTick"];
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
    if (![HDSubscriberInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return NO;
    }
    NSString * sql = @"UPDATE SubscribeInfo SET sSubscribeTick = ?, sSubscriberLogo = ?, sSubscriberName = ?, sCount = ?, sMsgID = ?, sContent = ?, sTitle = ?, sAvatarUrl = ?, formatType = ?, bubbleType = ?, sCreateTime = ? WHERE sSubscriberID = ?";
    BOOL res = [db executeUpdate:sql, self.sSubscribeTick, self.sSubscriberLogo, self.sSubscriberName, self.sCount, self.sMsgID, self.sContent, self.sTitle, self.sAvatarUrl, @(self.formatType), @(self.bubbleType), self.sCreateTime, self.sSubscriberID];
    if (!res) {
        Dlog(@"ERROR:error to insert data");
        [db class];
        return NO;
    }
    [db close];
    return YES;
}
- (BOOL)insert2DB{
    if (![HDSubscriberInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return NO;
    }
    NSString * sql = @"insert into SubscribeInfo (sSubscriberID, sSubscribeTick, sSubscriberLogo, sSubscriberName, sCount, sMsgID, sContent, sTitle, sAvatarUrl, formatType, bubbleType, sCreateTime) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
    BOOL res = [db executeUpdate:sql, self.sSubscriberID, self.sSubscribeTick, self.sSubscriberLogo, self.sSubscriberName, self.sCount, self.sMsgID, self.sContent, self.sTitle, self.sAvatarUrl, @(self.formatType), @(self.bubbleType), self.sCreateTime];
    if (!res) {
        Dlog(@"ERROR:error to insert data");
        [db class];
        return NO;
    }
    [db close];
    return YES;
}
- (BOOL)isExistInDB{
    if (![HDSubscriberInfo createTable]) {
        return NO;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
    if (![db open]) {
        Dlog(@"Error:open db failed");
        return NO;
    }
    NSString * sql = @"select * from SubscribeInfo where sSubscriberID = ?";
    FMResultSet * rs = [db executeQuery:sql, self.sSubscriberID];
    while ([rs next]) {
        NSString *sId   = [rs stringForColumn:@"sSubscriberID"];
        if ([sId isEqualToString:self.sSubscriberID]) {
            [db close];
            return YES;
        }
    }
    [db close];
    return NO;
}

+ (NSArray *)allFromDB{
    if (![HDSubscriberInfo createTable]) {
        return nil;
    }
    FMDatabase * db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
    if (![db open]) {
        Dlog(@"Error:faile open db");
        return nil;
    }
    NSString * sql = @"select * from SubscribeInfo";
    FMResultSet * rs = [db executeQuery:sql];
    NSMutableArray *mar = [NSMutableArray new];
    while ([rs next]) {
        HDSubscriberInfo *info  = [HDSubscriberInfo new];
        info.sSubscriberID      = [rs stringForColumn:@"sSubscriberID"];
        info.sSubscriberLogo    = [rs stringForColumn:@"sSubscriberLogo"];
        info.sSubscriberName    = [rs stringForColumn:@"sSubscriberName"];
        info.sCount             = [rs stringForColumn:@"sCount"];
        info.sMsgID             = [rs stringForColumn:@"sMsgID"];
        info.sContent           = [rs stringForColumn:@"sContent"];
        info.sTitle             = [rs stringForColumn:@"sTitle"];
        info.sAvatarUrl         = [rs stringForColumn:@"sAvatarUrl"];
        info.sCreateTime        = [rs stringForColumn:@"sCreateTime"];
        info.sSubscribeTick     = [rs stringForColumn:@"sSubscribeTick"];
        info.bubbleType         = [rs intForColumn:@"bubbleType"];
        info.formatType         = [rs intForColumn:@"formatType"];
        [mar addObject:info];
    }
    [db close];
    return mar;
}

+ (BOOL)clearAllFromDB{
    FMDatabase * db = [FMDatabase databaseWithPath:[HDSubscriberInfo path]];
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
