//
//  WJOpenPersonalCtr.m
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJOpenPersonalCtr.h"
#import "WJOpenPersonalCell.h"
#import "HDExtendListCtr.h"

@interface WJOpenPersonalCtr ()<HDExtendListDelegate>

@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIView      *v_foot1;
@property (strong) IBOutlet UIView      *v_foot2;
@property (strong) IBOutlet UIView      *v_foot3;
@property (strong) IBOutlet NSLayoutConstraint *lc_tbvBottom;

//职位地区行业选择
@property (nonatomic,strong)NSString * sAreaKey;
@property (nonatomic,strong)NSString * sTradeKey;
@property (nonatomic,strong)NSString * sPostKey;
@property (nonatomic,strong)NSString * sAreaName;
@property (nonatomic,strong)NSString * sTradeName;
@property (nonatomic,strong)NSString * sPostName;

@property (strong) HDTalentInfo *resumeInfo;

@end

@implementation WJOpenPersonalCtr

- (id)initWithInfo:(HDTalentInfo *)resumeInfo{
    self = [super init];
    if (self) {
        _resumeInfo = resumeInfo;
    }
    return self;
}

#pragma mark -
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_CONFIRM_RELEASE");
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
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.v_foot1;
    }else if (section == 1){
        return self.v_foot2;
    }
    return self.v_foot3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:[@[@(HDExtendTypeTrade), @(HDExtendTypePost), @(HDExtendTypeArea)][indexPath.row] integerValue]  object:nil maxSelectCount:1];
        ctr.delegate = self;
        [self.navigationController pushViewController:ctr animated:YES];
        
    }
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJOpenPersonalCell0";
        WJOpenPersonalCell0 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJOpenPersonalCell0 getOpenPersonalCell0];
        }
        cell.selectionStyle     = UITableViewCellSelectionStyleNone;
        cell.lb_name.text       = _resumeInfo.sName;
        NSString *str = _resumeInfo.sAreaText.length > 0? _resumeInfo.sAreaText: @"";
        NSArray *ar = @[_resumeInfo.sEduLevel? _resumeInfo.sEduLevel: @"", _resumeInfo.sSexText? _resumeInfo.sSexText: @"", _resumeInfo.sWorkYears? _resumeInfo.sWorkYears: @""];
        for (int i = 0; i < ar.count; i++) {
            NSString *s = ar[i];
            str = [str stringByAppendingString:(s.length > 0? FORMAT(@" | %@", s): @"")];
        }
        if ([str hasPrefix:@" | "]) {
            str = [str substringFromIndex:3];
        }
        cell.lb_message.text    = str;
        cell.lb_position.text   = _resumeInfo.sCurPosition;
        return cell;
    }else if (indexPath.section == 1){
        static NSString *cellIdentifier = @"WJOpenPersonalCell";
        WJOpenPersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJOpenPersonalCell getOpenPersonalCell];
        }
        cell.selectionStyle     = UITableViewCellSelectionStyleNone;
        cell.tf_content.userInteractionEnabled = NO;
        cell.lb_money.hidden = YES;
        cell.img_down.hidden = NO;
        cell.lb_title.text   = @[@"推荐行业", @"推荐职位", @"推荐工作地点"][indexPath.row];
        cell.tf_content.text = @[self.sTradeName? self.sTradeName :@"", self.sPostName? self.sPostName: @"", self.sAreaName? self.sAreaName: @""][indexPath.row];
        return cell;
    }
    static NSString *cellIdentifier = @"WJOpenPersonalCell";
    WJOpenPersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJOpenPersonalCell getOpenPersonalCell];
        cell.tf_content.keyboardType = UIKeyboardTypeNumberPad;
    }
    cell.selectionStyle     = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = YES;
    cell.img_down.hidden    = YES;
    cell.lb_money.hidden    = NO;
    cell.lb_title.text      = @"服务费用";
    cell.tf_content.delegate = self;
    cell.tf_content.tag     = 999;
    return cell;
}

#pragma mark - 
#pragma mark - HDExtendListDelegate

- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error: 回调返回参数有误");
        return;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeArea:{
            self.sAreaName     = valueInfo.sValue;
            self.sAreaKey      = valueInfo.sKey;
            break;
        }
        case HDExtendTypeTrade:{
            self.sTradeName    = valueInfo.sValue;
            self.sTradeKey     = valueInfo.sKey;
            break;
        }
        case HDExtendTypePost:{
            self.sPostName     = valueInfo.sValue;
            self.sPostKey      = valueInfo.sKey;
            break;
        }
              default:
            break;
    }
    [_tbv reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark event response

- (IBAction)service:(UIButton *)sender {
     [HDJJUtility jjSay:@"雇主购买服务后,您需要为雇主在24小时内提供该人选的完整简历信息(包括联系方式)、以及人选评价信息,但不提供其他服务。如雇主需要更多定制服务,可能会与您协商。建议设置范围100-5000荐币。" delegate:self];
}

//确认发布
- (IBAction)confirmTheRelease:(UIButton *)sender {
        UITextField *textField = (UITextField *)[self.view viewWithTag:999];
    if (self.sTradeKey.length == 0) {
        [HDUtility mbSay:@"请输入推荐行业"];
        return;
    }
    if (self.sPostKey.length == 0) {
        [HDUtility mbSay:@"请输入推荐职位"];
        return;
    }
    if (self.sAreaKey.length == 0) {
        [HDUtility mbSay:@"请输入推荐工作地点"];
        return;
    }
    if (textField.text.length == 0) {
        [HDUtility mbSay:@"请输入服务费用"];
        return;
    }
    if (textField.text.integerValue > 5000) {
        [HDUtility mbSay:@"请输入服务费用1-5000荐币之间"];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:_resumeInfo.sHumanNo,@"personalno",
                                                                   self.sTradeKey, @"businesscode",
                                                                   self.sPostKey, @"fuctioncode",
                                                                   self.sAreaKey, @"workPlace",
                                                                   textField.text, @"serviceFee",nil];
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] openResume:[HDGlobalInfo instance].userInfo dic:dic completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [HDUtility mbSay:sMessage];
        Dlog("发布成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_OPEN_RESUME object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}

@end
