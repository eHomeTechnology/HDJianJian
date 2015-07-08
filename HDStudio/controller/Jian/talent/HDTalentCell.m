//
//  HDTalentCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDTalentCell.h"

@implementation HDTalentCell

- (void)awakeFromNib {
    self.btn_suitable.layer.cornerRadius    = 17;
    self.btn_suitable.layer.masksToBounds   = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end



@implementation HDTalentViewCell

+ (HDTalentViewCell *)getTalentViewCell{
    HDTalentViewCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDTalentCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDTalentViewCell class]]) {
            cell = (HDTalentViewCell *)obj;
            break;
        }
    }
    return cell;
}

@end