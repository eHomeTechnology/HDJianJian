//
//  WJOpenPersonalCell.m
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJOpenPersonalCell.h"

@implementation WJOpenPersonalCell

+ (WJOpenPersonalCell *)getOpenPersonalCell{
    WJOpenPersonalCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJOpenPersonalCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJOpenPersonalCell class]]) {
            cell = (WJOpenPersonalCell *)obj;
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


@implementation WJOpenPersonalCell0

+ (WJOpenPersonalCell0 *)getOpenPersonalCell0{
    WJOpenPersonalCell0 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJOpenPersonalCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJOpenPersonalCell0 class]]) {
            cell = (WJOpenPersonalCell0 *)obj;
            break;
        }
    }
    return cell;
}

@end