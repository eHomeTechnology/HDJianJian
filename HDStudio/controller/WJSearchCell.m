//
//  WJSearchCell.m
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSearchCell.h"

@implementation WJSearchCell

+ (WJSearchCell *)getJianCell{
    WJSearchCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJSearchCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJSearchCell class]]) {
            cell = (WJSearchCell *)obj;
            break;
        }
    }
    return cell;
}
@end
