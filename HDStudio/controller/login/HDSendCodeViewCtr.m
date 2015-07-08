//
//  HDVerifyCodeViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/5.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDSendCodeViewCtr.h"
#import "HDHttpUtility.h"
#import "HDVerifyCodeViewCtr.h"
#import "HDHUD.h"

@interface HDSendCodeViewCtr (){

    IBOutlet UITextField *tf_phone;
    BOOL isAgree;
}

@property (strong) HDHUD *hud;
@end

@implementation HDSendCodeViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isRegister) {
         self.navigationItem.title   = LS(@"TXT_TITLE_REGISTER");
    }else{
        self.navigationItem.title   = LS(@"WJ_TITLE_BINDING_PHONE");
    }
   // isAgree = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)doReadAndAgree:(UIButton *)sender{
//    if (isAgree) {
//        isAgree = NO;
//        [sender setImage:[UIImage imageNamed:@"iconRead"] forState:UIControlStateNormal];
//    }else{
//        isAgree = YES;
//        [sender setImage:[UIImage imageNamed:@"iconReadHi"] forState:UIControlStateNormal];
//    }
//    
//}
//
//- (IBAction)doShowTreaty:(id)sender{
//
//    HDBackViewCtr *ctr          = [HDBackViewCtr new];
//    ctr.navigationItem.title    = @"荐荐注册使用协议";
//    UIWebView       *wbv        = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height)];
//    [wbv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
//    [ctr.view addSubview:wbv];
//    [self.navigationController pushViewController:ctr animated:YES];
//}

- (IBAction)doNext:(id)sender{
//    isAgree = YES;
//    if (!isAgree) {
//        [HDUtility say:@"请阅读并同意荐荐注册使用协议"];
//        return;
//    }
        if (![HDUtility isValidateMobile:tf_phone.text]) {
            [HDUtility say:@"手机号码输入有误"];
            return;
        }
    NSString *isReg = nil;
    if (_isRegister) {
        isReg = @"true";
    }else{
        isReg = @"false";
    }
        self.hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.navigationController.view];
        [[HDHttpUtility sharedClient] sendMessage:tf_phone.text isReg:isReg CompletionBlock:^(BOOL isSuccess, NSString *msgCode, NSString *sMessage) {
            [self.hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            
            HDVerifyCodeViewCtr *verifyCode = [[HDVerifyCodeViewCtr alloc] initWithPhone:tf_phone.text isRegister:_isRegister];
            [self.navigationController pushViewController:verifyCode animated:YES];
        }];
}

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [tf_phone resignFirstResponder];
    [self doNext:nil];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [tf_phone resignFirstResponder];
}
@end
