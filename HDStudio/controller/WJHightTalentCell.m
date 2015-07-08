//
//  WJHightTalentCell.m
//  JianJian
//
//  Created by liudu on 15/5/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJHightTalentCell.h"

@implementation WJHightTalentCell

+ (WJHightTalentCell *)getHightTalentCell{
    WJHightTalentCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJHightTalentCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJHightTalentCell class]]) {
            cell = (WJHightTalentCell *)obj;
            break;
        }
    }
    return cell;
}

@end
