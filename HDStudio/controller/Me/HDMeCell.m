//
//  HDMeCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMeCell.h"
#import "WJBrokerDetailsCtr.h"

@interface HDMeCell(){

    NSIndexPath *_indexPath;
}

@end

@implementation HDMeCell
@synthesize indexPath   = _indexPath;
+ (HDMeCell *)getCell{
    HDMeCell *cell      = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"HDMeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDMeCell class]]) {
            cell = (HDMeCell *)obj;
            break;
        }
    }
    cell.lb_number2.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath              = indexPath;
    self.imv_icon.image     = @[HDIMAGE(@"icon_meTalent"), HDIMAGE(@"icon_mePosition"), HDIMAGE(@"icon_meWallet")][indexPath.section];
    self.lb_title.text      = @[@"我的人才服务", @"我的招聘", @"我的钱包"][indexPath.section];
    self.lb_text0.text      = @[@"发布简历", @"发布职位", @"余额(荐币)"][indexPath.section];
    self.lb_text1.text      = @[@"推荐人才", @"收到简历", @"保证金金额(荐币)"][indexPath.section];
    self.lb_text2.text      = @[@"领取赏金", @"", @""][indexPath.section];
    self.lb_text3.text      = @[@"订单上门", @"我购买的服务", @""][indexPath.section];
    self.lb_subTitle.text   = @[@"我的人才", @"职位管理", @"充值、收支明细等"][indexPath.section];
    self.btn_0.indexPath    = indexPath;
    self.btn_1.indexPath    = indexPath;
    self.btn_2.indexPath    = indexPath;
    self.btn_3.indexPath    = indexPath;
    self.btn_subTitle.indexPath = indexPath;
    
    self.selectionStyle                 = UITableViewCellSelectionStyleNone;
    self.lc_widthTextLabel2.priority    = indexPath.section > 0? 900: 760;
    self.lc_widthTextLabel2.constant    = indexPath.section > 0? 0: 90;
    self.v_line1.hidden                 = indexPath.section > 0;
    self.imv_reward.hidden              = indexPath.section > 0;
    self.lb_number2.hidden              = indexPath.section > 0;
    self.lb_text2.hidden                = indexPath.section > 0;

    self.lc_widthTextLabel3.priority    = indexPath.section > 1? 900: 760;
    self.lc_widthTextLabel3.constant    = indexPath.section > 1? 0: 90;
    self.v_line2.hidden                 = indexPath.section > 1;
    self.lb_number3.hidden              = indexPath.section > 1;
    self.lb_text3.hidden                = indexPath.section > 1;
    [self updateConstraints];
}

- (void)setMyJianJianInfo:(HDMyJianJianInfo *)myJianJianInfo{
    switch (_indexPath.section) {
        case 0:{
            self.lb_number0.text = myJianJianInfo.sPersonalCount;
            self.lb_number1.text = myJianJianInfo.sRecommendCount;
            self.lb_number2.text = myJianJianInfo.sRGold;
            self.lb_number3.text = myJianJianInfo.sSellCount;
            break;
        }
        case 1:{
            self.lb_number0.text = myJianJianInfo.sPositionCount;
            self.lb_number1.text = myJianJianInfo.sRecruiterCount;
            self.lb_number3.text = myJianJianInfo.sBuyCount;
            break;
        }
        case 2:{
            self.lb_number0.text = myJianJianInfo.sGoldCount;
            self.lb_number1.text = myJianJianInfo.sDepositCount;
            break;
        }
        default:
            break;
    }
    self.lc_widthNumber2.constant = [HDJJUtility withOfString:self.lb_number2.text font:[UIFont systemFontOfSize:17] widthMax:80];
    [self updateConstraints];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation HDOpinionCell

+ (HDOpinionCell *)getOpinionCell{
    HDOpinionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDMeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDOpinionCell class]]) {
            cell = (HDOpinionCell *)obj;
            break;
        }
    }
    return cell;
}

@end