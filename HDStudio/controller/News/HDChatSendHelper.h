//
//  HDChatSendHelper.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMob.h"
@interface HDChatSendHelper : NSObject

/**
 *  发送文字消息（包括系统表情）
 *
 *  @param str               发送的文字
 *  @param username          接收方
 *  @param isChatGroup       是否是群聊
 *  @param requireEncryption 是否加密
 *  @param ext               扩展信息
 *  @return 封装的消息体
 */
+(EMMessage *)sendTextMessageWithString:(NSString *)str
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
                               complete:(void (^)(EMMessage *message, EMError *error))block;



/**
 *  发送图片消息
 *
 *  @param image             发送的图片
 *  @param username          接收方
 *  @param isChatGroup       是否是群聊
 *  @param requireEncryption 是否加密
 *  @param ext               扩展信息
 *  @return 封装的消息体
 */
+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
                               complete:(void (^)(EMMessage *message, EMError *error))block;


// 发送消息
+(EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
                      ext:(NSDictionary *)ext
                 complete:(void (^)(EMMessage *message, EMError *error))block;
@end
