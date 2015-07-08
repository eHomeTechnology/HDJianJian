//
//  HDLoginHelper.m
//  JianJian
//
//  Created by Hu Dennis on 15/7/2.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDLoginHelper.h"

@implementation HDLoginHelper

+ (void)loginJian:(NSString *)account pwd:(NSString *)pwd block:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage, NSString *encryptPwd))block{
    [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
        if (!isSuccess) {
            block(NO, nil, nil, message, nil);
            return;
        }
        NSString *sRealKey = [BaseFunc getRadomKey:key];
        if (sRealKey.length != 16) {
            NSString *str = LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY");
            block(NO, nil, nil, str, nil);
            return;
        }
        NSString *sEncryPwd = [LDCry encrypt:pwd password:sRealKey];
        [[HDHttpUtility sharedClient] loginWithPhone:account password:sEncryPwd CompletionBlock:^(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage) {
            if (!isSuccess) {
                block(NO, nil, nil, sMessage, nil);
                return ;
            }
            block(YES, @"0", user, @"登陆成功", sEncryPwd);
        }];
    }];
}

+ (void)loginEaseMobe:(NSString *)account pwd:(NSString *)pwd block:(void (^)(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser))block{
    if (account.length == 0) {
        Dlog(@"Error:传入参数有误！");
        block(NO, nil, nil);
        return;
    }
    BOOL hasLogin = [[EaseMob sharedInstance].chatManager isLoggedIn];
    if (hasLogin) {
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
        if (error) {
            Dlog(@"警告：环信注销失败，%@", error.description);
        }
    }
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:account password:pwd completion:^(NSDictionary *loginInfo, EMError *error) {
        HDEmUserInfo *emUser = [HDEmUserInfo infoWithDictionary:loginInfo];
        block((BOOL)loginInfo, error, emUser);
    } onQueue:nil];
}
@end
