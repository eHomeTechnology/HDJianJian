//
//  WJRecommendResumeCell.m
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecommendResumeCell.h"

@implementation WJRecommendResumeCell

+ (WJRecommendResumeCell *)getRecommendResumeCell{
    WJRecommendResumeCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJRecommendResumeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJRecommendResumeCell class]]) {
            cell = (WJRecommendResumeCell *)obj;
            break;
        }
    }
    return cell;
}

@end
