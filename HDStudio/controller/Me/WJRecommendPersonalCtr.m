//
//  WJRecommendPersonalCtr.m
//  JianJian
//
//  Created by liudu on 15/6/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecommendPersonalCtr.h"
#import "WJRecommendCell.h"
#import "HDTableView.h"
#import "WJBuytalentSuccessCtr.h"
#import "WJCheckPersonalDetailCtr.h"

@interface WJRecommendPersonalCtr (){
    WJBuyServiceListInfo *listInfo;
    HDTalentInfo *resumeInfo;
}

@property (strong) IBOutlet HDTableView  *tbv;
@property (strong) IBOutlet UIView       *v_foot1;
@property (strong) IBOutlet UIView       *v_foot;
@property (strong) IBOutlet NSLayoutConstraint   *lc_tbvBottom;
@property (strong) NSString *buyId;
@property (strong) NSString *email;
@property (strong) NSString *QQ;

@end

@implementation WJRecommendPersonalCtr

- (id)initWithBuyServiceListInfo:(WJBuyServiceListInfo *)info{
    if (self = [super init]) {
        listInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self checkPersonalRequest];
    [self setTableViewFooter];
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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


#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 44;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.v_foot1;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    return v;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return section == 1? 1: 4;
    if (section == 0) {
        return 4;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJRecommendCell";
        WJRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJRecommendCell getRecommendCell];
        }
        cell.btn_check.hidden = YES;
        if (indexPath.row == 0) {
            cell.btn_check.hidden = NO;
            [cell.btn_check addTarget:self action:@selector(doCheckResume) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.lb_title.text          = @[@"姓     名", @"联系手机", @"邮件地址", @"微信/QQ"][indexPath.row];
        cell.tf_content.delegate    = self;
        cell.tf_content.tag         = 100 + indexPath.row;
        cell.tf_content.placeholder = @[@"", @"",@"选填",@"选题"][indexPath.row];
        switch (indexPath.row) {
            case 0:
            {
                cell.btn_check.hidden = NO;
                cell.tf_content.text        = resumeInfo.sName;
            }
                break;
            case 1:
            {
                cell.tf_content.text        = resumeInfo.sPhone;
            }
                break;
            case 2:
            {
                cell.tf_content.text        = @"";
            }
                break;
            case 3:
            {
                cell.tf_content.text        = @"";
            }
                break;
            default:
                break;
        }
        
        return cell;
    }
    static NSString *cellIdentifier = @"WJRecommendCell0";
    WJRecommendCell0 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJRecommendCell0 getRecommendCell0];
    }
    cell.tv_content.delegate = self;
    cell.tv_content.tag = 999;
    return cell;
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UITextField *tf_name    = (UITextField *)[self.view viewWithTag:100];
    UITextField *tf_phone   = (UITextField *)[self.view viewWithTag:101];
    UITextField *tf_address = (UITextField *)[self.view viewWithTag:102];
   // UITextField *tf_QQ      = (UITextField *)[self.view viewWithTag:103];
    if (textField == tf_name) {
        resumeInfo.sName = textField.text;
    }else if (textField == tf_phone){
        resumeInfo.sPhone = textField.text;
    }else if (textField == tf_address){
        self.email = textField.text;
    }else{
        self.QQ = textField.text;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -- getter and setter
- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_RECOMMEND_PERSONAL");
}

- (void)setTableViewFooter{
     self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 60);
    [self.tbv setTableFooterView:self.v_foot];
}

#pragma mark -- HttpRequest
- (void)checkPersonalRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getResumeDetails:[HDGlobalInfo instance].userInfo personalno:listInfo.sPersonalNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDTalentInfo *resumeDetail) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        resumeInfo = resumeDetail;
        [self.tbv reloadData];
    }];
}

#pragma mark -- UIButtonOnClick
- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}

- (void)doCheckResume{
    Dlog(@"查看简历");
    WJCheckPersonalDetailCtr *check = [[WJCheckPersonalDetailCtr alloc] initWithPersonalno:listInfo.sPersonalNo isOpen:YES];
    [self.navigationController pushViewController:check animated:YES];
}

- (IBAction)doRecommend:(UIButton *)sender {
    Dlog(@"推荐");
    UITextView *tv_remark = (UITextView *)[self.view viewWithTag:999];
    if (resumeInfo.sName.length == 0) {
        [HDUtility mbSay:@"请输入姓名"];
        return;
    }
    if (resumeInfo.sPhone.length == 0) {
        [HDUtility mbSay:@"请输入手机号"];
        return;
    }
    if (self.email.length == 0) {
        [HDUtility mbSay:@"请输入邮件地址"];
        return;
    }
    if (self.QQ.length == 0) {
        [HDUtility mbSay:@"请输入微信/QQ"];
        return;
    }
    if (tv_remark.text.length == 0) {
        [HDUtility mbSay:@"请输入推荐信"];
        return;
    }
    
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:listInfo.sBuyId, @"buyId",
                                                                    resumeInfo.sName, @"name",
                                                                    resumeInfo.sPhone, @"mobile",
                                                                    self.email, @"email",
                                                                    self.QQ, @"qq",
                                                                    tv_remark.text, @"remark", nil];
    [[HDHttpUtility sharedClient] addRecommendLetter:[HDGlobalInfo instance].userInfo typeDic:dic completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *recommendID) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        WJBuytalentSuccessCtr *buy = [[WJBuytalentSuccessCtr alloc] initWithBuyId:recommendID userNo:resumeInfo.sUserNo isBuyResume:NO];
        [self.navigationController pushViewController:buy animated:YES];
    }];
}

@end
