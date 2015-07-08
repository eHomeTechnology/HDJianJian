//
//  HDChatSendHelper.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDChatSendHelper.h"

@implementation HDChatSendHelper

+(EMMessage *)sendTextMessageWithString:(NSString *)str
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
                               complete:(void (^)(EMMessage *message, EMError *error))block
{
    EMChatText *text = [[EMChatText alloc] initWithText:str];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext complete:block];
}

+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
                                  complete:(void (^)(EMMessage *message, EMError *error))block
{
    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:image displayName:@"image.jpg"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext           complete:block];
}


// 发送消息
+(EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
                      ext:(NSDictionary *)ext
                 complete:(void (^)(EMMessage *message, EMError *error))block
{
    EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:username bodies:[NSArray arrayWithObject:body]];
    retureMsg.requireEncryption = requireEncryption;
    retureMsg.isGroup = isChatGroup;
    retureMsg.ext = ext;
    EMMessage *message = [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil prepare:^(EMMessage *message, EMError *error) {

    } onQueue:nil completion:block onQueue:nil];
    return message;
}



@end
