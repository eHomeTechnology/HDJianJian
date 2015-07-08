//
//  WJSearchCtr.h
//  JianJian
//
//  Created by liudu on 15/5/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJFindBrokerView.h"
#import "WJFindTalentView.h"
#import "WJFindPositionView.h"

@interface WJSearchCtr : UIViewController<FindBrokerViewDelegate, FindTalentViewDelegate, FindPositionViewDelegate, UIScrollViewDelegate>

@end
