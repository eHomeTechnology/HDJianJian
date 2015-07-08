//
//  WJCheckOrderCell.m
//  JianJian
//
//  Created by liudu on 15/4/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckOrderCell.h"

@implementation WJCheckOrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)getChechOrderData:(WJPositionInfo *)info{
    self.lb_salary.text = info.sSalaryText;
    [self.btn_company setTitle:info.employerInfo.sName forState:UIControlStateNormal];
    self.lc_companyWithWidth.constant = [self viewWidth:info.employerInfo.sName uifont:14];
    self.lb_place.text = info.sAreaText;
    self.lb_education.text = info.sEducationText;
    self.lb_reward.text = FORMAT(@"¥%0.2f",[info.sReward floatValue]/10);
    self.lb_workYears.text = info.sWorkExpText;
//    if (info.sEnterpriseName.length == 0){
//        self.lb_companyT.hidden = YES;
//        self.btn_company.hidden = YES;
//        self.lb_companyTWithHeight.constant = 0;
//        self.btn_companyWithHeight.constant = 0;
//    }
//    if (info.sAreaText.length == 0){
//        self.lb_placeT.hidden = YES;
//        self.lb_place.hidden = YES;
//        self.lb_workPlaceTWithHeight.constant = 0;
//        self.lb_workPlaceWithHeight.constant = 0;
//    }
//    if (info.sEducationText.length == 0){
//        self.lb_educationT.hidden = YES;
//        self.lb_education.hidden = YES;
//        self.lb_educationTWithHeight.constant = 0;
//        self.lb_educationWithHeight.constant = 0;
//    }
//    if (info.sWorkExpText.length == 0){
//        self.lb_workYearsT.hidden = YES;
//        self.lb_workYears.hidden = YES;
//        self.lb_workYearsTWithHeight.constant = 0;
//        self.lb_workYearsWithHeight.constant = 0;
//    }
//    if (info.sReward.length == 0) {
//        self.v_rewardWithHeight.hidden = YES;
//    }
}

//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(150, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width;
    return width;
}
@end
