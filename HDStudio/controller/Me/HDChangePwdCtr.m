//
//  HDModifyPwdCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDChangePwdCtr.h"
#import "HDTableView.h"
#import "HDTalentCell.h"
#import "BaseFunc.h"
#import "LDCry.h"

@interface HDChangePwdCtr (){
    UITextField *tf_0;
    UITextField *tf_1;
    UITextField *tf_2;
    UIButton    *btn_confirm;
}
@property (strong) AFHTTPRequestOperation *op;
@property (strong) IBOutlet HDTableView *tbv;
@end

@implementation HDChangePwdCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}
- (void)viewWillLayoutSubviews{
    [self setTableFooter];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITextField *tf = @[@[tf_0], @[tf_1, tf_2]][indexPath.section][indexPath.row];
    [tf becomeFirstResponder];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 1) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"talentview";
    HDTalentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [HDTalentViewCell getTalentViewCell];
        cell.lb_accesory.hidden = YES;
        cell.tf_value.secureTextEntry = YES;
    }
    switch (indexPath.section) {
        case 0:{
            tf_0 = cell.tf_value;
            cell.lb_title.text = LS(@"TXT_ME_OLD_PASSWORD");
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    tf_1 = cell.tf_value;
                    cell.lb_title.text = LS(@"TXT_ME_NEW_PASSWORD");
                    break;
                }
                case 1:{
                    tf_2 = cell.tf_value;
                    cell.lb_title.text = LS(@"TXT_ME_NEW_PASSWORD_AGAIN");
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (int i = 0; i < 5; i++) {
        HDTalentViewCell *cell = (HDTalentViewCell *)[self.tbv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        if ([cell.tf_value isFirstResponder]) {
            [cell.tf_value resignFirstResponder];
        }
    }
}

#pragma mark - Event && Action
- (void)httpChangePassword{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
        if (!isSuccess) {
            [hud hiden];
            [HDUtility say:message];
            return;
        }
        NSString *sRealKey = [BaseFunc getRadomKey:key];
        if (sRealKey.length != 16) {
            [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
            [hud hiden];
            return;
        }
        NSString *sEncryOld = [LDCry encrypt:tf_0.text password:sRealKey];
        NSString *sEncryNew = [LDCry encrypt:tf_1.text password:sRealKey];
        _op = [[HDHttpUtility sharedClient] changePassword:[HDGlobalInfo instance].userInfo old:sEncryOld new:sEncryNew completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            [HDUtility say:LS(@"TXT_CHANGE_PWD_SUCCEED_PLEASE_RELOGIN")];
            [HDGlobalInfo instance].userInfo = nil;
            [HDGlobalInfo instance].hasLogined = NO;
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:LOGIN_PWD];
            [[NSUserDefaults standardUserDefaults] synchronize];
            EMError *error = nil;
            [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
            if (error) {
                Dlog(@"警告：环信注销失败，%@", error.description);
            }
            [self.navigationController.tabBarController setSelectedIndex:0];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }];
}
- (void)doConfirm:(UIButton *)sender{
    if (tf_0.text.length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_OLD_PASSWORD")];
        return;
    }
    if (tf_1.text.length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_NEW_PASSWORD")];
        return;
    }
    if (![tf_2.text isEqualToString:tf_1.text]) {
        [HDUtility mbSay:LS(@"TXT_TOW_NEW_PASSWORD_IS_DIFFERENT")];
        return;
    }
    if (tf_1.text.length < 6) {
        [HDUtility mbSay:LS(@"TXT_ENTER_LEAST_6_PASSWORD")];
        return;
    }
    [self httpChangePassword];
}

#pragma mark - getter setter
- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_CHANGE_PASSWORD");
}

- (void)setTableFooter{
    if (!btn_confirm) {
        btn_confirm = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, HDDeviceSize.width - 40, 55)];
        btn_confirm.backgroundColor = HDCOLOR_RED;
        [btn_confirm setTitle:LS(@"TXT_ME_CHANGE_PASSWORD_CONFIRM") forState:UIControlStateNormal];
        [btn_confirm addTarget:self action:@selector(doConfirm:) forControlEvents:UIControlEventTouchUpInside];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 60)];
        v.backgroundColor = [UIColor clearColor];
        [v addSubview:btn_confirm];
        [self.tbv setTableFooterView:v];
    }
}

@end







