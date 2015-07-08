//
//  WJServiceInfoView.m
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJServiceInfoView.h"
#import "WJCheckPositionCell.h"

@interface WJServiceInfoView ()
{
    
}
@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIView      *v_foot;

@end

@implementation WJServiceInfoView

- (id)initWithFrame:(CGRect)frame{
    self = [[NSBundle mainBundle]loadNibNamed:@"WJServiceInfoView" owner:self options:nil][0];
    if (!self) {
        return nil;
    }
    self.frame = frame;
    return self;
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.v_foot;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJServiceCell";
    WJServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJServiceCell serviceCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lb_reward.text         = FORMAT(@"%@荐币(相当于%0.1f元)",[HDJJUtility countNumAndChangeformat:_info.tradeInfo.sServiceFees],[_info.tradeInfo.sServiceFees floatValue]/10 );
    cell.lb_rewardPay.text      = _info.tradeInfo.sTradeDesc;
    cell.lb_service.text        = _info.tradeInfo.sServiceTypeText;
    cell.lb_description.text    = _info.tradeInfo.sRemark;
    return cell;
}

@end
