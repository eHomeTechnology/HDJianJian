//
//  HDResetPwdViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/13.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDResetPwdViewCtr.h"

@interface HDResetPwdViewCtr (){

    IBOutlet UIButton       *btn_resend;
    IBOutlet UIImageView    *imv_back;
    IBOutlet UITextField    *tf_verify;
    IBOutlet UITextField    *tf_pwd;
    NSTimer                 *tm_verify;
    int                     iCount;
}

@end

@implementation HDResetPwdViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重置密码";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doGetVerifyCode:(id)sender{
    iCount              = 30;
    btn_resend.enabled  = NO;
    tm_verify           = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                           target:self
                                                         selector:@selector(doCount:)
                                                         userInfo:nil repeats:YES];
    
}

- (void)doCount:(id)sender{
    iCount--;
    if (iCount == 0) {
        [tm_verify invalidate];
        tm_verify           = nil;
        btn_resend.enabled  = YES;
        [btn_resend setTitle:FORMAT(@"重发验证码") forState:UIControlStateNormal];
        return;
    }
    [btn_resend setTitle:FORMAT(@"%d", iCount) forState:UIControlStateNormal];
}
- (IBAction)doComplete:(id)sender{
    

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch      = [touches anyObject];
    UIView  *v_touch    = [touch view];
    if ([v_touch isEqual:imv_back]) {
        [tf_pwd     resignFirstResponder];
        [tf_verify  resignFirstResponder];
    }
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [tf_pwd     resignFirstResponder];
    [tf_verify  resignFirstResponder];
    return YES;
}

@end
