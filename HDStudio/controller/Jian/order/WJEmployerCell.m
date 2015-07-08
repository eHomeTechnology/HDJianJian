//
//  WJEmployerCell.m
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJEmployerCell.h"

@implementation WJEmployerCell

+ (WJEmployerCell *)getEmployerCell{
    WJEmployerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJEmployerCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJEmployerCell class]]) {
            cell = (WJEmployerCell *)obj;
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


@implementation HDEmployerImageCell

+ (HDEmployerImageCell *)getCell{
    HDEmployerImageCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJEmployerCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDEmployerImageCell class]]) {
            cell = (HDEmployerImageCell *)obj;
            break;
        }
    }
    return cell;
}
@end
