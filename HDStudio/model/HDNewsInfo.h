//
//  HDNewsInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "EaseMob.h"
#import "HDTalentInfo.h"
#import "WJPositionInfo.h"

typedef NS_ENUM(NSInteger, HDNewsFormatType) {
    HDNewsFormatTypeText        = 1,
    HDNewsFormatTypeImage       = 2,
    HDNewsFormatTypeResume      = 7,
    HDNewsFormatTypePosition    = 8,
};

typedef NS_ENUM(NSInteger, HDSendingNewsStatus) {
    HDSendingNewsStatusBegin = 0,
    HDSendingNewsStatusSending,
    HDSendingNewsStatusSuccess,
    HDSendingNewsStatusFalse,
};

typedef NS_ENUM(NSInteger, HDMessagePlatformType) {//会话界面消息类型，
    HDMessagePlatformTypeJianJian = 0,    //来自荐荐服务器的订阅消息
    HDMessagePlatformTypeEasMobe,         //来自环信的消息
};

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface HDMessageInfo : NSObject

@property (strong) NSString *sMsgID;        //消息唯一标志位
@property (strong) NSString *sTitle;        //对方的名称
@property (strong) NSString *sAvatarUrl;    //头像URL
@property (strong) UIImage  *img_avata;     //头像图片
@property (strong) NSString *sCreateTime;   //消息创建时间
@property (strong) NSString *sMessageTick;  //时间标记
@property (strong) NSString                 *sContent;      //消息文字
@property (strong) NSString                 *sBodyImage;    //消息图片本地路径
@property (strong) WJPositionInfo           *position;      //消息职位
@property (strong) HDTalentInfo             *talent;        //消息简历
@property (assign) HDNewsFormatType         formatType;     //消息体类型
@property (assign) NSBubbleType             bubbleType;     //消息所属类型，对方消息还是我自己的消息
@property (assign) HDMessagePlatformType    platformType;   //消息平台类型，环信还是来自荐荐服务器的订阅消息
@end

@interface HDSubscriberInfo : HDMessageInfo

@property (strong) NSString *sSubscriberID;     //如果是和人对话的，该ID为对方对话人的HumanNo
@property (strong) NSString *sSubscriberLogo;   //订阅号的头像url
@property (strong) NSString *sSubscriberName;   //对方名称，如果是人，即为人名，否则订阅号名称
@property (strong) NSString *sCount;            //未读数
@property (strong) NSString *sSubscribeTick;    //时间标记

+ (void)subscriberInfoFromEmConversation:(EMConversation *)conversation block:(void(^)(HDSubscriberInfo *subInfo))block;

+ (NSArray *)allFromDB;
+ (HDSubscriberInfo *)infoFromDB:(NSString *)sId;
+ (BOOL)clearAllFromDB;
- (BOOL)insert_update2DB;
- (BOOL)update2DB;
- (BOOL)insert2DB;
- (BOOL)isExistInDB;

@end

