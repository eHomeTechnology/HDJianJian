//
//  WJBuyServiceCell.m
//  JianJian
//
//  Created by liudu on 15/6/1.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBuyServiceCell.h"

@implementation WJShowMoneyCell

+ (WJShowMoneyCell *)getMoneyCell{
    WJShowMoneyCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBuyServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJShowMoneyCell class]]) {
            cell= (WJShowMoneyCell *)obj;
            break;
        }
    }
    return cell;
}

@end


@implementation WJBuyServiceCell

+ (WJBuyServiceCell *)getBuyServiceCell{
    WJBuyServiceCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBuyServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJBuyServiceCell class]]) {
            cell = (WJBuyServiceCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//@implementation WJBalanceCell
//
//+ (WJBalanceCell *)getBalanceCells{
//    WJBalanceCell *cell = nil;
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBalanceCell" owner:self options:nil];
//    for (NSString *obj in objects) {
//        if ([obj isKindOfClass:[WJBalanceCell class]]) {
//            cell = (WJBalanceCell *)obj;
//            break;
//        }
//    }
//    return cell;
//}
//
//@end