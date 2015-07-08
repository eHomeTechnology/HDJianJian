//
//  WJTalentDetailCell.m
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJTalentDetailCell.h"

@implementation WJTalentDetailCell

+ (WJTalentDetailCell *)getTalentDetailCell{
    WJTalentDetailCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJTalentDetailCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJTalentDetailCell class]]) {
            cell = (WJTalentDetailCell *)obj;
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
