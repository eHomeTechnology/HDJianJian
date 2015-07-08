//
//  WJEmployerInfoView.h
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FONTNAME_HelveticaNeueMedium(siz) [UIFont systemFontOfSize:siz]

@interface WJEmployerInfoView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) WJPositionInfo *info;

@end
