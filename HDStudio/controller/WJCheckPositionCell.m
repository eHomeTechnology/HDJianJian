//
//  WJCheckPositionCell.m
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckPositionCell.h"
@implementation WJCheckPositionCell

+ (WJCheckPositionCell *)checkPositionCell{
    WJCheckPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckPositionCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJCheckPositionCell class]]) {
            cell = (WJCheckPositionCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)setPositionInfo:(WJPositionInfo *)positionInfo{
    _positionInfo = positionInfo;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lb_title.text      = positionInfo.sPositionName;
    self.lb_company.text    = [HDJJUtility isNull:positionInfo.employerInfo.sName]? @"": FORMAT(@"%@ ＞",positionInfo.employerInfo.sName);
    self.lb_address.text    = positionInfo.sAreaText;
    self.lb_education.text  = positionInfo.sEducationText;
    self.lb_workYear.text   = positionInfo.sWorkExpText;
    self.lb_recommend.text  = positionInfo.tradeInfo.sServiceTypeText;
    self.lb_salary.text     = positionInfo.sSalaryText;
    self.lb_brokerName.text = positionInfo.brokerInfo.sName;
    self.lc_attentionWidth.constant     = positionInfo.brokerInfo.isFocus? 0: 70;
    self.v_attention.hidden             = positionInfo.brokerInfo.isFocus;
    self.lc_brokerNameWidth.constant    = [HDJJUtility withOfString:positionInfo.brokerInfo.sName font:[UIFont systemFontOfSize:14] widthMax:1000];
    [self updateConstraints];
    NSArray *ar = @[HDIMAGE(@"v_copper"), HDIMAGE(@"v_silver"), HDIMAGE(@"v_gold"), HDIMAGE(@"v_diamond")];
    int iLevel = positionInfo.brokerInfo.sMemberLevel.intValue;
    UIImage *image = nil;
    if (iLevel >= 2 && iLevel <= 5) {
        image = ar[iLevel - 2];
    }
    if (iLevel == 1) {
        self.imv_level.hidden = YES;
    }
    self.imv_level.image = image;
    self.imv_v.hidden = !positionInfo.brokerInfo.sRoleType.boolValue;
    BOOL isOthersPosition = ![positionInfo.brokerInfo.sHumanNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
    if (isOthersPosition && positionInfo.sReward.floatValue == 0) {
        self.v_reward.hidden = YES;
    }
    if (positionInfo.isBonus){
        self.lb_deposit0.text = @"悬赏(荐币)";
        self.lb_deposit1.text = positionInfo.sReward;
    }else{
        self.lb_deposit0.text = @"设置";
        self.lb_deposit1.text = @"悬赏金";
    }
}

@end

@implementation WJCheckPositionCell1
+ (WJCheckPositionCell1 *)checkPositionCell1{
    WJCheckPositionCell1 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckPositionCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJCheckPositionCell1 class]]) {
            cell = (WJCheckPositionCell1 *)obj;
            break;
        }
    }
    cell.lc_lineHeight.constant = 0.1;
    [cell updateConstraints];
    return cell;
}
@end

@implementation WJServiceCell

+ (WJServiceCell *)serviceCell{
    WJServiceCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckPositionCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJServiceCell class]]) {
            cell = (WJServiceCell *)obj;
            break;
        }
    }
    return cell;
}

@end