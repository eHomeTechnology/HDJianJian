//
//  WJBrokerCell2.m
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerCell2.h"

@implementation WJBrokerCell2

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (WJBrokerCell2 *)getBrokerCell2{
    WJBrokerCell2 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBrokerCell2" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJBrokerCell2 class]]) {
            cell = (WJBrokerCell2 *)obj;
            break;
        }
    }
    return cell;
}
@end
