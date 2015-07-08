//
//  WJCheckPositionCtr.h
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPositionInfoView.h"
#import "WJEmployerInfoView.h"
#import "WJServiceInfoView.h"

@interface WJCheckPositionCtr : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate, CheckEmployerDelegate>

- (id)initWithPositionId:(NSString *)sId;

@end
