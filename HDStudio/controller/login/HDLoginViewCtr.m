//
//  HDLoginViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDLoginViewCtr.h"
#import "HDMenuViewCtr.h"
#import "LDCry.h"
#import "BaseFunc.h"
#import "AFImageRequestOperation.h"
#import "UMSocial.h"
#import "HDNewsViewCtr.h"
#import "HDContactViewCtr.h"
#import "HDMeViewCtr.h"
#import "HDJJUtility.h"
#import "EaseMob.h"
#import "HDSendCodeViewCtr.h"
#import "HDSetAccountViewCtr.h"
#import "HDBlogViewCtr.h"
#import "WJSetBrokerMessageCtr.h"
#import "NSData+Encryption.h"
#import "HDLoginHelper.h"

@interface HDLoginViewCtr ()<EMChatManagerDelegate>{
    IBOutlet UITextField    *tf_phone;
    IBOutlet UITextField    *tf_pwd;
    NSString                *sKey;
    NSString                *sEncryPwd;
}
@property (strong) HDHUD    *hud;
@end

@implementation HDLoginViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated{
    [self autoEnterUserInformation];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([[touch view] isEqual:self.view]) {
        [tf_phone resignFirstResponder];
        [tf_pwd resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Event and Respond
- (void)goRegisterController:(id)sender{
    HDSendCodeViewCtr *send = [[HDSendCodeViewCtr alloc] init];
    send.isRegister = YES;
    [self.navigationController pushViewController:send animated:YES];
}
- (void)doCancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doLogin:(id)sender{
    [self.view endEditing:YES];
    if (![HDUtility isValidatePassword:tf_pwd.text]) {
        [HDUtility say:LS(@"TXT_PROMPT_WRONG_PASSWORD")];
        return;
    }
    _hud = [HDHUD showLoading:LS(@"TXT_LODING_LOGIN") on:self.navigationController.view];
    [HDLoginHelper loginJian:tf_phone.text pwd:tf_pwd.text block:^(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage, NSString *encryptPwd){
        if (!isSuccess) {
            [_hud hiden];
            [HDUtility mbSay:sMessage];
            return ;
        }
        NSString *str       = FORMAT(@"%@%@_jj&", tf_pwd.text, user.sHumanNo);
        NSString *cryPwd    = [LDCry getMd5_32Bit_String:str];
        [HDLoginHelper loginEaseMobe:user.sHumanNo pwd:cryPwd block:^(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser) {
            [_hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:error.description];
                return ;
            }
            user.sAccount       = tf_phone.text;
            user.sPwd           = tf_pwd.text;
            [HDGlobalInfo instance].userInfo = user;
            [[NSUserDefaults standardUserDefaults] setObject:tf_phone.text    forKey:LOGIN_USER];
            [[NSUserDefaults standardUserDefaults] setObject:tf_pwd.text      forKey:LOGIN_PWD];
            [HDGlobalInfo instance].hasLogined = YES;
            [HDGlobalInfo instance].emUserInfo = emUser;
            [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

- (IBAction)doWeixinLogin:(id)sender {
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatSession];
            Dlog(@"username = %@, uid = %@, token = %@, url = %@", snsAccount.userName, snsAccount.usid, snsAccount.accessToken, snsAccount.iconURL);
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                Dlog(@"response = %@",response);
                NSLog(@"SnsInformation is %@",response.data);
            }];
            _hud = [HDHUD showLoading:@"努力加载中..." on:self.view];
            [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
                if (!isSuccess) {
                    [_hud hiden];
                    [HDUtility say:message];
                    return ;
                }
                NSString *sRealKey = [BaseFunc getRadomKey:key];
                Dlog(@"sRealKet = %@", sRealKey);
                if (sRealKey.length != 16) {
                    [_hud hiden];
                    [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
                    return;
                }
                NSString *sEncryUserId = [LDCry encrypt:snsAccount.usid password:sRealKey];
                [[HDHttpUtility sharedClient] getThirdPartLogin:@"4" openUserID:sEncryUserId openToken:snsAccount.accessToken completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDUserInfo *user) {
                    Dlog(@"user = %@", user.sName);
                    if (!isSuccess){
                        [_hud hiden];
                        Dlog(@"第三方登录失败");
                        HDSendCodeViewCtr *send = [[HDSendCodeViewCtr alloc] init];
                        send.isRegister = NO;
                        if (![HDGlobalInfo instance].userInfo) {
                            [HDGlobalInfo instance].userInfo = [HDUserInfo new];
                        }
                        [HDGlobalInfo instance].userInfo.sTocken     = snsAccount.accessToken;
                        [HDGlobalInfo instance].userInfo.sHumanNo    = snsAccount.usid;
                        [HDGlobalInfo instance].userInfo.sName       = snsAccount.userName;
                        [HDGlobalInfo instance].userInfo.sAvatarUrl  = snsAccount.iconURL;
                        Dlog(@"token:%@",snsAccount.accessToken);
                        Dlog(@"权限:%@", [HDGlobalInfo instance].userInfo.sTocken);
                        [self.navigationController pushViewController:send animated:YES];
                        return ;
                    }
                    Dlog(@"token1 = %@", user.sTocken1);
                    NSString *sPwd = [LDCry decrypt:user.sTocken1 key:sRealKey];
                    Dlog(@"sPwd = %@", sPwd);
                    NSString *str       = FORMAT(@"%@%@_jj&", sPwd, user.sHumanNo);
                    NSString *cryPwd    = [LDCry getMd5_32Bit_String:str];
                    [HDLoginHelper loginEaseMobe:user.sHumanNo pwd:cryPwd block:^(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser) {
                        [_hud hiden];
                        if (!isSuccess) {
                            [HDUtility mbSay:error.description];
                            return ;
                        }
                        user.sAccount       = user.sPhone;
                        user.sPwd           = sPwd;
                        [HDGlobalInfo instance].userInfo = user;
                        [[NSUserDefaults standardUserDefaults] setObject:user.sAccount  forKey:LOGIN_USER];
                        [[NSUserDefaults standardUserDefaults] setObject:user.sPwd      forKey:LOGIN_PWD];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [HDGlobalInfo instance].hasLogined = YES;
                        [HDGlobalInfo instance].emUserInfo = emUser;
                        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }];
                }];

            }];
        }else{
            [HDUtility mbSay:@"微信登录失败"];
            Dlog(@"微信登录失败");
        }
    });
}

#pragma mark - getter and setter
- (void)setup{
    self.navigationItem.title   = LS(@"TXT_TITLE_LOGIN");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    UIButton *btn_register = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_register.frame = CGRectMake(0, 0, 70, 30);
    [btn_register setTitle:@"注册" forState:UIControlStateNormal];
    [btn_register setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_register.layer.cornerRadius     = 15.;
    btn_register.layer.masksToBounds    = YES;
    btn_register.layer.borderColor      = [UIColor whiteColor].CGColor;
    btn_register.layer.borderWidth      = 0.5;
    [btn_register addTarget:self action:@selector(goRegisterController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_register];
}

- (void)autoEnterUserInformation{
    NSString *sAccount = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER];
    tf_phone.text      = sAccount;
}

@end
