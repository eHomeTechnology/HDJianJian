//
//  WJRecommendPersonalCtr.h
//  JianJian
//
//  Created by liudu on 15/6/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJBuyServiceListInfo.h"

@interface WJRecommendPersonalCtr : UIViewController<UITextFieldDelegate,UITextViewDelegate>

- (id)initWithBuyServiceListInfo:(WJBuyServiceListInfo *)info;

@end
