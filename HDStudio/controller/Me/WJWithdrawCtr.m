//
//  WJWithdrawCtr.m
//  JianJian
//
//  Created by liudu on 15/6/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJWithdrawCtr.h"
#import "WJOpenPersonalCell.h"
#import "HDExtendListCtr.h"
#import "BaseFunc.h"
#import "LDCry.h"
#import "HDTableView.h"

@interface WJWithdrawCtr ()<HDExtendListDelegate>

@property (strong) IBOutlet HDTableView *tbv;
@property (strong) IBOutlet UIView      *v_head;
@property (strong) IBOutlet UIView      *v_foot;
@property (strong) IBOutlet UILabel     *lb_banlance;//荐币余额
@property (strong) IBOutlet UILabel     *lb_withDraw;//可提现荐币
@property (strong) IBOutlet UILabel     *lb_money;//等于。。。元
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;


//开户行选择
@property (strong) NSString *sBankKey;
@property (strong) NSString *sBankName;

@property (strong)  WJBalanceInfo       *balanceInfo;
@property (strong) WJBankInfo           *bankInfo;
@end

@implementation WJWithdrawCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self  getBalanceRequest];
    [self  getBankCardMessageRequest];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_WITHDRAW");
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)handleKeyboardWillShow:(NSNotification *)notification{
    [self scrollBottom];
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view updateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view updateConstraints];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.v_head;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.v_foot;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 1) {
        HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeBank object:nil maxSelectCount:1];
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJOpenPersonalCell";
    WJOpenPersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJOpenPersonalCell getOpenPersonalCell];
    }
    cell.img_down.hidden                   = YES;
    cell.lb_money.hidden                   = YES;
    cell.tf_content.userInteractionEnabled = YES;
    cell.tf_content.delegate = self;
    cell.tf_content.tag                    = 100+indexPath.row;
    cell.lb_title.text = @[@"银行卡号", @"开户行", @"支行名称", @"开户行姓名", @"提现荐币", @"登录密码"][indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            cell.tf_content.text = _bankInfo.sBankAccount;
        }
            break;
        case 1:
        {
            cell.img_down.hidden                     = NO;
            cell.tf_content.userInteractionEnabled   = NO;
            cell.tf_content.text = self.sBankName? self.sBankName: _bankInfo.sBankName;
            self.sBankKey = _bankInfo.sBanktype;
        }
            break;
        case 2:
        {
            cell.tf_content.text = _bankInfo.sBankBranch;
        }
            break;
        case 3:
        {
            cell.tf_content.text = _bankInfo.sName;
        }
            break;
        case 4:
        {
            cell.lb_money.hidden        = NO;
            cell.tf_content.placeholder = @"提取金额不能少于500荐币";
        }
            break;
        case 5:
        {
            
        }
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark -- 
#pragma mark -- HDExtendListDelegate
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error:回调返回参数有误");
        return;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeBank:
        {
            self.sBankName      = valueInfo.sValue;
            self.sBankKey       = valueInfo.sKey;
        }
            break;
            
        default:
            break;
    }
    [_tbv reloadData];
}


#pragma mark -- 
#pragma mark -- UITextFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//该方法为点击虚拟键盘Return，要调用的代理方法：隐藏虚拟键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- 
#pragma mark -- HttpRequest
- (void)getBalanceRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getBalance:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _balanceInfo = balance;
        self.lb_banlance.text = [HDJJUtility countNumAndChangeformat:_balanceInfo.sGoldCount];
        self.lb_withDraw.text = [HDJJUtility countNumAndChangeformat:_balanceInfo.sGoldCount];
        self.lb_money.text    = FORMAT(@"等于%0.1f元",[_balanceInfo.sGoldCount floatValue]/10);
    }];
}

- (void)getBankCardMessageRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getBankCardMessage:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBankInfo *bank) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _bankInfo = bank;
        [_tbv reloadData];
    }];
}

#pragma mark -- 
#pragma mark - Event and Respond
//提现
- (IBAction)withDraw:(UIButton *)sender {
    Dlog(@"提现");
    UITextField *tf_bankAccount = (UITextField *)[self.view viewWithTag:100]; //银行账户
    UITextField *tf_bankBranch  = (UITextField *)[self.view viewWithTag:102]; //分行
    UITextField *tf_name        = (UITextField *)[self.view viewWithTag:103]; //账户名
    UITextField *tf_gold        = (UITextField *)[self.view viewWithTag:104]; //提现荐币
    UITextField *tf_password    = (UITextField *)[self.view viewWithTag:105]; //密码
    

    if (tf_bankAccount.text.length == 0){
        [HDUtility mbSay:@"请输入银行卡号"];
        return;
    }
    if (self.sBankKey.length == 0) {
        [HDUtility mbSay:@"请选择开户行"];
        return;
    }
    if (tf_bankBranch.text.length == 0) {
        [HDUtility mbSay:@"请输入支行名称"];
        return;
    }
    if (tf_name.text.length == 0) {
        [HDUtility mbSay:@"请输入开户行姓名"];
        return;
    }
    if (tf_gold.text.length == 0 ) {
        [HDUtility mbSay:@"请输入提现荐币"];
        return;
    }
    if (tf_gold.text.integerValue < 500 ) {
        [HDUtility mbSay:@"提取金额不能少于500荐币"];
        return;
    }
    if (tf_gold.text.integerValue % 100 != 0) {
        [HDUtility mbSay:@"目前仅支持整百提取"];
        return;
    }
    if (tf_password.text.length == 0){
        [HDUtility mbSay:@"请输入登录密码"];
        return;
    }
    if (![tf_password.text isEqualToString:[HDGlobalInfo instance].userInfo.sPwd]) {
        [HDUtility mbSay:@"密码错误"];
        return;
    }
    
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
        if (!isSuccess) {
          [HDUtility mbSay:message];
            return ;
        }
        NSString *sRealKey = [BaseFunc getRadomKey:key];
        if (sRealKey.length != 16) {
            [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
            return;
        }
        NSString * sEncryUserId = [LDCry encrypt:tf_password.text password:sRealKey];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.sBankKey,@"bankType",
                             tf_bankAccount.text, @"bankAccount",
                             tf_bankBranch.text, @"bankBranch",
                             tf_name.text, @"name",
                             tf_gold.text, @"gold",
                             sEncryUserId, @"password",nil];

        
        [[HDHttpUtility sharedClient] moneyWithDraw:[HDGlobalInfo instance].userInfo dic:dic completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            [HDUtility mbSay:@"您已申请成功。申请提现的金额将次日到账,每逢节假日顺延。"];
            [self.navigationController popViewControllerAnimated:YES];
        }];

    }];
    
    
}

- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}

@end
