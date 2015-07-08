//
//  HDApproveCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDApproveCell.h"

@implementation HDIndexTextField

@end

@implementation HDSimpleEnterCell

+ (HDSimpleEnterCell *)getCell{
    HDSimpleEnterCell *cell      = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"HDApproveCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDSimpleEnterCell class]]) {
            cell = (HDSimpleEnterCell *)obj;
            break;
        }
    }
    return cell;
}


@end

@implementation HDAddPictureCell

+ (HDAddPictureCell *)getCell{
    HDAddPictureCell *cell      = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"HDApproveCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDAddPictureCell class]]) {
            cell = (HDAddPictureCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)setMar_images:(NSMutableArray *)mar_images{
    NSArray *ar_imvs = @[self.imv0, self.imv1, self.imv2];
    for (UIImageView *imv in ar_imvs){
        [imv setImage:nil];
    }
    for (int i = 0; i < mar_images.count; i++) {
        UIImageView *imv    = ar_imvs[i];
        UIImage *img        = mar_images[i];
        imv.image           = img;
    }
    self.btn_delet0.hidden  = !self.imv0.image;
    self.btn_delet1.hidden  = !self.imv1.image;
    self.btn_delet2.hidden  = !self.imv2.image;
    self.btn_add.hidden     = mar_images.count == 3;
    self.lc_addLeadiing.constant = 105 * mar_images.count;
}

@end

@implementation HDApproveCell

+ (HDApproveCell *)getCell{
    HDApproveCell *cell      = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"HDApproveCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDApproveCell class]]) {
            cell = (HDApproveCell *)obj;
            break;
        }
    }
    cell.lb_status.adjustsFontSizeToFitWidth    = YES;
    cell.lb_subTitle.adjustsFontSizeToFitWidth  = YES;
    cell.lb_status.layer.cornerRadius           = 17.;
    cell.lb_status.layer.masksToBounds          = YES;
    return cell;
}

- (void)setApproveInfo:(HDApproveInfo *)approveInfo{
    HDApproveInfo *info     = approveInfo;
    self.lb_title.text      = FORMAT(@"%@", info.sCompanyName);
    BOOL isPersonal         = info.approveType == HDApproveTypePersonal;
    if (isPersonal) {
        self.lb_title.text  = FORMAT(@"%@ %@", info.sRealName, info.sPosition);
    }
    self.lb_subTitle.text   = FORMAT(@"%@  %@", isPersonal? @"个人认证": @"企业认证", info.sCreatedDT);
    self.lb_remark.text     = info.sRemark;
    switch (info.approveStatus) {
        case HDApproveStatusUnknown:{
            self.lb_status.text = @"待审核";
            self.lb_status.backgroundColor = [UIColor colorWithRed:28/255. green:155/255. blue:250/255. alpha:1.0];
            break;
        }
        case HDApproveStatusNotPassed:{
            self.lb_status.text = @"认证失败";
            self.lb_status.backgroundColor = HDCOLOR_RED;
            break;
        }
        case HDApproveStatusPassed:{
            self.lb_status.text = @"认证成功";
            self.lb_status.backgroundColor = [UIColor greenColor];
            break;
        }
        default:
            break;
    }
    if (self.lb_remark.text.length == 0 || info.approveStatus != HDApproveStatusNotPassed) {
        self.lb_remark.text = nil;
        self.lc_heightRemark.constant = 0.;
        [self updateConstraints];
    }
}

@end




