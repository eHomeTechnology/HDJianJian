//
//  WJTalentRecommendCell.m
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJTalentRecommendCell.h"

@implementation WJTalentRecommendCell

+ (WJTalentRecommendCell *)getTalentRecommendCell{
    WJTalentRecommendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJTalentRecommendCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJTalentRecommendCell class]]) {
            cell = (WJTalentRecommendCell *)obj;
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
