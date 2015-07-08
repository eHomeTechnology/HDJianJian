//
//  WJBrokerMessageCell.m
//  JianJian
//
//  Created by liudu on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerMessageCell.h"

@implementation WJBrokerMessageCell

+ (WJBrokerMessageCell *)getBrokerMessageCell{
    WJBrokerMessageCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBrokerMessageCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJBrokerMessageCell class]]) {
            cell = (WJBrokerMessageCell *)obj;
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

@implementation WJBrokerMessageCell0

+ (WJBrokerMessageCell0 *)getBrokerMessageCell0{
    WJBrokerMessageCell0 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBrokerMessageCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJBrokerMessageCell0 class]]) {
            cell = (WJBrokerMessageCell0 *)obj;
            break;
        }
    }
    return cell;
}

@end