//
//  WJCheckServiceCell.m
//  JianJian
//
//  Created by liudu on 15/6/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckServiceCell.h"

@implementation WJCheckServiceCell

+ (WJCheckServiceCell *)getCheckServiceCell{
    WJCheckServiceCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJCheckServiceCell class]]) {
            cell = (WJCheckServiceCell *)obj;
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


@implementation WJBrokersMessageCell

+ (WJBrokersMessageCell *)getBrokerMessageCell{
    WJBrokersMessageCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJBrokersMessageCell class]]) {
            cell = (WJBrokersMessageCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@implementation WJPersonalMessageCell

+ (WJPersonalMessageCell *)getPersonalMessageCell{
    WJPersonalMessageCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJPersonalMessageCell class]]) {
            cell = (WJPersonalMessageCell *)obj;
            break;
        }
    }
    return cell;
}

@end