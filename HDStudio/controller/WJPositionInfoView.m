//
//  WJPositionInfoView.m
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPositionInfoView.h"
#import "HDTableView.h"
#import "WJCheckPositionCell.h"
#import "WJCheckEmployer.h"
#import "HDChatViewCtr.h"
#import "WJBrokerDetailsCtr.h"
#import "WJSettingRewardCtr.h"


@interface WJPositionInfoView ()<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray  *dataArray;
    float           tv_height;
}

@end

@implementation WJPositionInfoView

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section== 0) {
        return 214;
    }else{
        return MAX(tv_height, 90);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *v  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.05;
    }
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


#pragma makr - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJCheckPositionCell";
        WJCheckPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJCheckPositionCell checkPositionCell];
        }
        cell.positionInfo = _info;
        [cell.btn_checkBroker addTarget:self action:@selector(checkBrokerDetails:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_chat addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_payAtention addTarget:self action:@selector(addAttention) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_setSalary addTarget:self action:@selector(setReward) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_company addTarget:self action:@selector(companyOnClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
   static NSString *cellIdentifier = @"WJCheckPositionCell1";
    WJCheckPositionCell1 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJCheckPositionCell1 checkPositionCell1];
    }
    cell.tv_content.delegate = self;
    cell.tv_content.text = [HDJJUtility flattenHTML:_info.sRemark string:@"\n"];
    tv_height = [HDUtility measureHeightOfUITextView:cell.tv_content];
    cell.tv_content.frame = CGRectMake(10, 0, HDDeviceSize.width-20, tv_height);
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            WJSettingRewardCtr *setting = [[WJSettingRewardCtr alloc] initWithInfo:_info];
            if ([self.eDelegate respondsToSelector:@selector(toCheckEmployerViewController:)]) {
                [self.eDelegate toCheckEmployerViewController:setting];
            }
        }
            break;
        default:
            break;
    }
}

- (void)companyOnClick{
    NSLog(@"查看雇主");
    WJCheckEmployer *employer = [[WJCheckEmployer alloc] initWithInfo:_info];
    if ([self.eDelegate respondsToSelector:@selector(toCheckEmployerViewController:)]) {
        [self.eDelegate toCheckEmployerViewController:employer];
    }
}

- (void)setReward{
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    if (![_info.brokerInfo.sHumanNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo]) {
        return;
    }
    if (_info.sReward.intValue > 0) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有对该职位设置悬赏金,设置后可以提高信誉度和招聘效率" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}

- (IBAction)chat{
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithHuman:self.info.brokerInfo];
    UIViewController *delegate = (UIViewController *)self.eDelegate;
    if (delegate) {
        [delegate.navigationController pushViewController:ctr animated:YES];
    }
}

- (void)addAttention{
    if (![HDGlobalInfo instance ].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self];
    [[HDHttpUtility sharedClient] attentionUser:[HDGlobalInfo instance].userInfo usernos:_info.brokerInfo.sHumanNo isfocus:@"1" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        WJCheckPositionCell *cell = (WJCheckPositionCell *)[self.tbv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.lc_attentionWidth.constant = 0.;
        cell.v_attention.hidden = YES;
        [cell setNeedsUpdateConstraints];
    }];

}

- (IBAction)checkBrokerDetails:(UIButton *)sender {
    WJBrokerDetailsCtr *detail = [[WJBrokerDetailsCtr alloc] initWithInfoID:_info.brokerInfo.sHumanNo];
    if ([self.eDelegate respondsToSelector:@selector(toCheckEmployerViewController:)]) {
        [self.eDelegate toCheckEmployerViewController:detail];
    }
}

#pragma mark - setter and getter

- (void)setInfo:(WJPositionInfo *)info{
    _info = info;
}

@end
