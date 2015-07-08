//
//  WJDiscoverCell.m
//  JianJian
//
//  Created by liudu on 15/5/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJDiscoverCell.h"

@implementation WJDiscoverCell

+ (WJDiscoverCell *)getDiscoverCell{
    WJDiscoverCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJDiscoverCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJDiscoverCell class]]) {
            cell = (WJDiscoverCell *)obj;
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
