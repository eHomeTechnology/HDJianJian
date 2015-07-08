//
//  HDImportPositionCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDImportPositionCell.h"

@implementation HDImportPositionCell

+ (HDImportPositionCell *)getImportPositionCell{
    HDImportPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDImportPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDImportPositionCell class]]) {
            cell = (HDImportPositionCell *)obj;
            break;
        }
    }
    return cell;
}
@end
