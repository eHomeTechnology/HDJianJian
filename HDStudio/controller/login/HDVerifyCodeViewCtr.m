//
//  HDVerifyCodeViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/5.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDVerifyCodeViewCtr.h"
#import "HDSetAccountViewCtr.h"
#import "HDHUD.h"
#import "LDCry.h"
#import "BaseFunc.h"
#import "NSData+Encryption.h"
#import "HDLoginHelper.h"

@interface HDVerifyCodeViewCtr (){
    IBOutlet UILabel        *lb_phone;
    IBOutlet UITextField    *tf_code;
    IBOutlet UIButton       *btn_resend;
    IBOutlet UILabel        *lb_timer;
    NSString                *sPhone;
    int                     iCount;
    NSTimer                 *timer;
    BOOL                    _isRegister;
}
@end

@implementation HDVerifyCodeViewCtr

- (id)initWithPhone:(NSString *)phone isRegister:(BOOL)isRegister{
    if (![HDUtility isValidateMobile:phone]) {
        Dlog(@"传入参数错误,请核对代码");
        return nil;
    }
    if (self = [super init]) {
        sPhone = phone;
        _isRegister = isRegister;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title   = @"请填写验证码";
    lb_phone.text               = FORMAT(@"+86 %@", sPhone);
    iCount                      = 60;
    btn_resend.enabled          = NO;
    [tf_code becomeFirstResponder];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(count:) userInfo:nil repeats:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)count:(UIButton *)sender{
    iCount --;
    lb_timer.text = FORMAT(@"%d(重新发送验证码)", iCount);
    lb_timer.backgroundColor = [UIColor grayColor];
    if (iCount == 0) {
        [timer invalidate];
        lb_timer.hidden     = YES;
        btn_resend.enabled  = YES;
        [btn_resend setTitle:@"重新发送验证码" forState:UIControlStateNormal];
    }
}
- (IBAction)doVerify:(id)sender{
    
    if (tf_code.text.length < 4) {
        HDHUD *hud_ = [HDHUD showLoading:@"正在发送验证码..." on:self.navigationController.view];
        NSString *isReg = nil;
        if (_isRegister) {
            isReg = @"true";
        }else{
            isReg = @"false";
        }
        [[HDHttpUtility sharedClient] sendMessage:sPhone isReg:isReg CompletionBlock:^(BOOL isSuccess, NSString *msgCode, NSString *sMessage) {
            [HDUtility mbSay:sMessage];
            [hud_ hiden];
            if (!isSuccess) {
                return ;
            }
            lb_timer.hidden     = NO;
            btn_resend.enabled  = NO;
            iCount              = 60;
            lb_timer.text       = FORMAT(@"%d", iCount);
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(count:) userInfo:nil repeats:YES];
        }];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:@"检验验证码..." on:self.navigationController.view];
    [[HDHttpUtility sharedClient] verifyMessageCode:sPhone code:tf_code.text CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:FORMAT(@"%@", sMessage)];
            return ;
        }
        if (_isRegister) {
            HDSetAccountViewCtr *ctr = [[HDSetAccountViewCtr alloc] initWithPhone:sPhone code:tf_code.text isRegister:_isRegister];
            [self.navigationController pushViewController:ctr animated:YES];
        }else{
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.navigationController.view];
            [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
                if (!isSuccess) {
                    [hud hiden];
                    [HDUtility say:message];
                    return ;
                }
                NSString *sRealKey = [BaseFunc getRadomKey:key];
                Dlog(@"sRealKey = %@", sRealKey);
                if (sRealKey.length != 16) {
                    [hud hiden];
                    [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
                    return;
                }
                NSString *sName     = [HDGlobalInfo instance].userInfo.sName;
                NSString *sTocken   = [HDGlobalInfo instance].userInfo.sTocken;
                NSString *sNo       = [HDGlobalInfo instance].userInfo.sHumanNo;
                NSString *sEncryUserId = [LDCry encrypt:sNo password:sRealKey];
                [[HDHttpUtility sharedClient] thirdPartyRegisterWithMobile:sPhone openUserId:sEncryUserId openToken:sTocken nickName:sName validCode:tf_code.text openAuth:@"4" CompletionBlock:^(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage) {
                    [hud hiden];
                    if (!isSuccess) {
                        Dlog(@"第三方注册失败");
                        [HDUtility mbSay:sMessage];
                        return ;
                    }
                    Dlog(@"token1 = %@", user.sTocken1);
                    NSString *sPwd = [LDCry decrypt:user.sTocken1 key:sRealKey];
                    Dlog(@"sPwd = %@", sPwd);
                    NSString *str       = FORMAT(@"%@%@_jj&", sPwd, user.sHumanNo);
                    NSString *cryPwd    = [LDCry getMd5_32Bit_String:str];
                    [HDLoginHelper loginEaseMobe:user.sHumanNo pwd:cryPwd block:^(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser) {
                        if (!isSuccess) {
                            [HDUtility mbSay:error.description];
                            return ;
                        }
                        user.sAccount       = user.sPhone;
                        user.sPwd           = sPwd;
                        [HDGlobalInfo instance].userInfo = user;
                        [[NSUserDefaults standardUserDefaults] setObject:user.sAccount  forKey:LOGIN_USER];
                        [[NSUserDefaults standardUserDefaults] setObject:user.sPwd      forKey:LOGIN_PWD];
                        [HDGlobalInfo instance].hasLogined = YES;
                        [HDGlobalInfo instance].emUserInfo = emUser;
                        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_THIRD_REGISTER_SUCCESS object:@(YES)];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
        }
    }];
}

#pragma mark -
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    Dlog(@"%d, %@", (int)textField.text.length, textField.text);
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    Dlog(@"%d, %d", (int)range.location, (int)range.length);
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];//得到输入框的内容
    if (toBeString.length == 4) {
        lb_timer.hidden     = YES;
        btn_resend.enabled  = YES;
        [btn_resend setTitle:@"下一步" forState:UIControlStateNormal];
    }else{
        if (iCount > 0) {
            lb_timer.hidden     = NO;
            btn_resend.enabled  = NO;
        }else{
            lb_timer.hidden = YES;
            [btn_resend setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        }
    }
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_code resignFirstResponder];
}
@end
