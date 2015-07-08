//
//  HDMayPositionCell_v3.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyPositionCell_v3.h"

@implementation CELLButton
@end

@implementation HDOnPstList_v3Cell
+ (HDOnPstList_v3Cell *)getOnCell{
    HDOnPstList_v3Cell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDMyPositionCell_v3" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDOnPstList_v3Cell class]]) {
            cell = (HDOnPstList_v3Cell *)obj;
            break;
        }
    }
    return cell;
}
@end
