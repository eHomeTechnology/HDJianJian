//
//  HDBlogPositionCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogPositionCell.h"

@implementation HDBlogPositionCell

+ (HDBlogPositionCell *)getBlogPositionCell{
    HDBlogPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDBlogPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDBlogPositionCell class]]) {
            cell = (HDBlogPositionCell *)obj;
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
