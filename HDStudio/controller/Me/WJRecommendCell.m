//
//  WJRecommendCell.m
//  JianJian
//
//  Created by liudu on 15/6/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecommendCell.h"

@implementation WJRecommendCell

+ (WJRecommendCell *)getRecommendCell{
    WJRecommendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJRecommendCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJRecommendCell class]]) {
            cell = (WJRecommendCell *)obj;
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


@implementation WJRecommendCell0

+ (WJRecommendCell0 *)getRecommendCell0{
    WJRecommendCell0 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJRecommendCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJRecommendCell0 class]]) {
            cell = (WJRecommendCell0 *)obj;
            break;
        }
    }
    return cell;
}

@end