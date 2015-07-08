//
//  WJBuyServiceCtr.m
//  JianJian
//
//  Created by liudu on 15/6/1.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBuyServiceCtr.h"
#import "WJBuyServiceCell.h"
#import "WJOnlinePayCtr.h"
#import "WJBuytalentSuccessCtr.h"

@interface WJBuyServiceCtr ()
@property (strong, nonatomic) IBOutlet UITableView *tbv;
@property (strong, nonatomic) IBOutlet UIView *v_foot;
@property (strong) HDTalentInfo   *resumeInfo;
@property (strong) WJBalanceInfo        *balanceInfo;
@property (strong, nonatomic) IBOutlet UIButton *btn_payment;

@end

@implementation WJBuyServiceCtr

- (id)initWithResumeInfo:(HDTalentInfo *)info{
    if (!info) {
        Dlog(@"传入参数错误！");
        return nil;
    }
    if (self = [super init]) {
        _resumeInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"WJ_TITLE_BUY_TALENT_SERVICE");
    [self httpRequest];
}

- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] getBalance:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _balanceInfo = balance;
        [self.tbv reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 75;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return self.v_foot;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJBuyServiceCell";
        WJBuyServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJBuyServiceCell getBuyServiceCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lb_personalNo.text = _resumeInfo.sUserNo;
        cell.lb_name.text       = _resumeInfo.sNickName;
        cell.lb_money.text      = [HDJJUtility isNull:_resumeInfo.sServiceFee]? @"": FORMAT(@"%@荐币",_resumeInfo.sServiceFee);
        if (_resumeInfo.sServiceFee == nil) {
            cell.lb_money.text = @"";
        }
        return cell;
    }else if (indexPath.section == 1){
       static NSString *cellIdentifier = @"WJShowMoneyCell";
        WJShowMoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJShowMoneyCell getMoneyCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.img_select.tag = 888;
        cell.lb_money.tag = 100;
        cell.lb_money.text = FORMAT(@"%@荐币",_balanceInfo.sGoldCount);
        return cell;
    }
    static NSString *cellIdentifier = @"WJShowMoneyCell";
    WJShowMoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJShowMoneyCell getMoneyCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.img_select.tag = 999;
    cell.lb_money.tag = 101;
    cell.img_select.hidden = YES;
    cell.lb_balance.text = @"在线支付";
    if ([_resumeInfo.sServiceFee integerValue] >= [_balanceInfo.sGoldCount integerValue]) {
        cell.lb_money.text = FORMAT(@"%d荐币(%0.1f元)",(int)([_resumeInfo.sServiceFee integerValue] - [_balanceInfo.sGoldCount integerValue]),(([_resumeInfo.sServiceFee floatValue] - [_balanceInfo.sGoldCount floatValue])/10));
    }else{
        cell.lb_money.text = 0;
    }
    return cell;
}

- (IBAction)payment:(UIButton *)sender {
    if ([_resumeInfo.sServiceFee integerValue] > [_balanceInfo.sGoldCount integerValue]) {
        WJOnlinePayCtr *pay = [[WJOnlinePayCtr alloc] initWithTradeid:_resumeInfo.sHumanNo shopPrice:FORMAT(@"%d",(int)([_resumeInfo.sServiceFee integerValue] - [_balanceInfo.sGoldCount integerValue])) payType:WJPayBuyServiceType nickNo:_resumeInfo.sUserNo];
        [self.navigationController pushViewController:pay animated:YES];
    }else{
        HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
        [[HDHttpUtility sharedClient] buyResumeService:[HDGlobalInfo instance].userInfo personalNo:_resumeInfo.sHumanNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *buyId) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            WJBuytalentSuccessCtr *success = [[WJBuytalentSuccessCtr alloc] initWithBuyId:buyId userNo:_resumeInfo.sUserNo isBuyResume:YES];
            Dlog(@"buyID-----%@",buyId);
            [self.navigationController pushViewController:success animated:YES];
        }];
    }
    //测试使用
    
//    WJBuytalentSuccessCtr *success = [[WJBuytalentSuccessCtr alloc] init];
//    success.buyId = @"100113";
//    success.isBuyResume = YES;
//    [self.navigationController pushViewController:success animated:YES];
}



@end
