//
//  HDForgetPwdViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDForgetPwdViewCtr.h"
#import "HDResetPwdViewCtr.h"

@interface HDForgetPwdViewCtr (){

    IBOutlet UITextField *tf_account;
    IBOutlet UIImageView *imv_back;
    IBOutlet UIImageView *imv_cellBack;
}

@end

@implementation HDForgetPwdViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"忘记密码";
    [HDUtility setShadow:imv_cellBack];
    [tf_account becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doNext:(id)sender{
    if (![HDUtility isValidateMobile:tf_account.text]) {
        [HDUtility say:@"请输入正确的手机号码！"];
        return;
    }
    [self.navigationController pushViewController:[HDResetPwdViewCtr new] animated:YES];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch      = [touches anyObject];
    UIView  *v_touch    = [touch view];
    if ([v_touch isEqual:imv_back]) {
        [tf_account resignFirstResponder];
    }
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [tf_account resignFirstResponder];
    return YES;
}

@end
