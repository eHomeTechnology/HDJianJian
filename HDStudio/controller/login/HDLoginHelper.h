//
//  HDLoginHelper.h
//  JianJian
//
//  Created by Hu Dennis on 15/7/2.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDCry.h"
#import "BaseFunc.h"
#import "UMSocial.h"
#import "HDJJUtility.h"
#import "EaseMob.h"
#import "NSData+Encryption.h"

@interface HDLoginHelper : NSObject

/**
 @brief     荐荐账户登陆
 @param     account     账户名，手机格式
 @param     pwd         密码，至少6位数
 @return    isSuccess   是否登陆成功
 @return    sCode       错误码
 @return    user        用户信息
 @return    sMessage    错误描述
 @discussion 主要网络接口那边调用和网络出错的时候需要调用本地plist文件的时候调用到该方法
 */
+ (void)loginJian:(NSString *)account pwd:(NSString *)pwd block:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage, NSString *encryptPwd))block;

/**
 @brief     环信账户登陆
 @param     account     账户名，手机格式
 @param     pwd         密码，至少6位数
 @return    isSuccess   是否登陆成功
 @return    error       错误信息
 @return    emUser      环信返回用户信息
 @discussion 主要网络接口那边调用和网络出错的时候需要调用本地plist文件的时候调用到该方法
 */
+ (void)loginEaseMobe:(NSString *)account pwd:(NSString *)pwd block:(void (^)(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser))block;

@end
