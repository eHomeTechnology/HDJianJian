//
//  WJMyTalentCell.m
//  JianJian
//
//  Created by liudu on 15/6/10.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJMyTalentCell.h"

@implementation WJMyTalentCell

+ (WJMyTalentCell *)getMyTalentCell{
    WJMyTalentCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJMyTalentCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJMyTalentCell class]]) {
            cell = (WJMyTalentCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib {
    self.btn_progressState.layer.cornerRadius   = 15;
    self.btn_progressState.layer.masksToBounds  = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
