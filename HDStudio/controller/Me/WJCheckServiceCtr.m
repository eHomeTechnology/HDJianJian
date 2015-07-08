//
//  WJCheckService.m
//  JianJian
//
//  Created by liudu on 15/6/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckServiceCtr.h"
#import "WJCheckServiceCell.h"
#import "WJTalentDetailCtr.h"
#import "HDChatViewCtr.h"

@interface WJCheckServiceCtr ()

@property (strong) IBOutlet UITableView    *tbv;
@property (strong) WJBuyServiceDetailsInfo *detailsInfo;
@property (strong) WJBrokerInfo      *brokerInfo;
@property (strong) NSString                *buyId;
@property (strong) NSString                *status;
@property (strong) NSString                *personal;

@end

@implementation WJCheckServiceCtr

- (id)initWithBuyId:(NSString *)buyId status:(NSString *)status personal:(NSString *)personal{
    self = [super init];
    if (self) {
        _buyId      = buyId;
        _status     = status;
        _personal   = personal;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self getBrokerDetailsRequest];
    [self getServiceDetailsRequest];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_CHECK_SERVICE");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 130;
    }
    if (indexPath.section == 1){
        return 44;
    }
    if ([_status isEqualToString:@"服务完成"]) {
        if (indexPath.section == 2) {
            return 130;
        }
    }
    return 160;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([_status isEqualToString:@"服务完成"]){
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJCheckServiceCell";
        WJCheckServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJCheckServiceCell getCheckServiceCell];
        }
        cell.lb_buyId.text      = _detailsInfo.sBuyId;
        cell.lb_buyTime.text    = _detailsInfo.sBuyTime;
        cell.lb_endTime.text    = _detailsInfo.sEndTime;
        cell.lb_money.text      = _detailsInfo.sGold;
        cell.lb_name.text       = _detailsInfo.sSeller;
        [cell.btn_chat addTarget:self action:@selector(chatOnClick) forControlEvents:UIControlEventTouchUpInside];
        cell.lc_nameWithWidth.constant = [HDJJUtility withOfString:_detailsInfo.sSeller font:[UIFont systemFontOfSize:14] widthMax:1000];
        [cell updateConstraints];
        cell.img_certification.hidden  = !_brokerInfo.sRoleType.boolValue;
        switch ([_brokerInfo.sMemberLevel integerValue]) {
            case 1://注册会员
            {
                
            }
                break;
            case 2://铜牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_copper");
            }
                break;
            case 3://银牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_silver");
            }
                break;
            case 4://金牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_gold");
            }
                break;
            case 5://钻石会员
            {
                cell.img_grade.image = HDIMAGE(@"v_diamond");
            }
                break;
            case 6://皇冠会员
            {
                
            }
                break;
                
            default:
                break;
        }
        return cell;
    }
    if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (_detailsInfo.sStatusText.length == 0){
            cell.textLabel.text = @"服务状态:";
        }else{
            cell.textLabel.text = FORMAT(@"服务状态:%@",_detailsInfo.sStatusText);
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    if ([_status isEqualToString:@"服务完成"]) {
        if (indexPath.section == 2) {
            static NSString *cellIdentifier = @"WJBrokersMessageCell";
            WJBrokersMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [WJBrokersMessageCell getBrokerMessageCell];
            }
            cell.lb_name.text       = _detailsInfo.sAppraise.sName;
            cell.lb_mobile.text     = _detailsInfo.sAppraise.sMPhone;
            cell.lb_email.text      = _detailsInfo.sAppraise.sEmail;
            cell.lb_QQ.text         = _detailsInfo.sAppraise.sWX_QQ;
            cell.lb_recomend.text   = _detailsInfo.sAppraise.sRemark;
            return cell;
        }

    }
    static NSString *cellIdentifier = @"WJPersonalMessageCell";
    WJPersonalMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJPersonalMessageCell getPersonalMessageCell];
    }
    cell.lb_workYears.text      = _detailsInfo.sPerson.sWorkYears;
    cell.lb_area.text           = _detailsInfo.sPerson.sAreaText;
    cell.lb_sex.text            = _detailsInfo.sPerson.sSexText;
    cell.lb_education.text      = _detailsInfo.sPerson.sEduLevelText;
    cell.lb_curPosition.text    = _detailsInfo.sPerson.sLastPosition;
    cell.lb_curCompany.text     = _detailsInfo.sPerson.sLastCompanyName;
    [cell.btn_checkResume addTarget:self action:@selector(checkResume) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark -- 
#pragma mark -- HttpRequest
- (void)getBrokerDetailsRequest{//Act124荐客信息
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getBrokerInfo:[HDGlobalInfo instance].userInfo userno:_personal completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _brokerInfo = info;
        [self.tbv reloadData];
    }];
}

- (void)getServiceDetailsRequest{//Act414服务详情
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getBuyServiceDetail:[HDGlobalInfo instance].userInfo buyId:_buyId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBuyServiceDetailsInfo *detailsInfo) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _detailsInfo = detailsInfo;
        [self.tbv reloadData];
    }];
}

#pragma mark -- 
#pragma mark -- UIButtonOnClick
- (void)chatOnClick{
    HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithChatterId:_detailsInfo.sUserNoSeller];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)checkResume{
    WJTalentDetailCtr *talent = [[WJTalentDetailCtr alloc] initWithTalentId:_detailsInfo.sPersonalNo isMeCheckResume:YES];
    [self.navigationController pushViewController:talent animated:YES];
}

@end
