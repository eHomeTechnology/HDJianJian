//
//  HDNewPositionCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewPositionCell.h"

@implementation HDNewPositionCell
+ (HDNewPositionCell *)getNewPositionCell{
    HDNewPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDNewPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDNewPositionCell class]]) {
            cell = (HDNewPositionCell *)obj;
            break;
        }
    }
    return cell;
}
@end

@implementation HDPositionDescCell

+ (HDPositionDescCell *)getPositionDescCell{
    HDPositionDescCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDNewPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionDescCell class]]) {
            cell = (HDPositionDescCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@implementation HDPositionPhotoCell
+ (HDPositionPhotoCell *)getPhotoDescCell{
    HDPositionPhotoCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDNewPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionPhotoCell class]]) {
            cell = (HDPositionPhotoCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@implementation HDEmployeeListCell

+ (HDEmployeeListCell *)getEmployeeCell{
    HDEmployeeListCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDNewPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDEmployeeListCell class]]) {
            cell = (HDEmployeeListCell *)obj;
            cell.btn_choose.layer.cornerRadius  = 5.;
            cell.btn_choose.layer.masksToBounds = YES;
            break;
        }
    }
    return cell;
}

- (void)setEmployerInfo:(HDEmployerInfo *)employerInfo{
    self.lb_name.text       = employerInfo.sName;
    self.lb_business.text   = employerInfo.sTradeText;
    self.lb_property.text   = employerInfo.sPropertyText;
}

@end
