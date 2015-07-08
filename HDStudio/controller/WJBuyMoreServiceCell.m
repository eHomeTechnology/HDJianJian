//
//  WJBuyMoreServiceCell.m
//  JianJian
//
//  Created by liudu on 15/6/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBuyMoreServiceCell.h"

@implementation WJBuyMoreServiceCell

+ (WJBuyMoreServiceCell *)getBuyMoreServiceCell{
    WJBuyMoreServiceCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBuyMoreServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJBuyMoreServiceCell class]]) {
            cell = (WJBuyMoreServiceCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@implementation WJServiceSuccessCell

+ (WJServiceSuccessCell *)getServiceSuccessCell{
    WJServiceSuccessCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJBuyMoreServiceCell" owner:self options:nil];
    for (NSString *obj in objects) {
        if ([obj isKindOfClass:[WJServiceSuccessCell class]]) {
            cell = (WJServiceSuccessCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)getServiceSuccessData:(WJServiceInfo*)info{
    self.lb_title.text       = info.sProgressText;
    self.lc_contentWithHeight.constant = [self viewWithHeight:self.lb_content.text uifont:14 ];
    [self updateConstraints];
}

-(CGFloat)viewWithHeight:(NSString*)str uifont:(int)font{
    CGSize constraint = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50,1000.0f);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName,nil];
    //ios7方法，获取文本需要的size，限制宽度
    CGSize  size =[str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    CGFloat height = MAX(30, size.height+1);
    return height;
}


@end