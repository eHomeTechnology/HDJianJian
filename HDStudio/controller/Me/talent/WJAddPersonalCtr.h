//
//  WJAddPersonalCtr.h
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDJJUtility.h"

@interface WJAddPersonalCtr : UIViewController<UITextFieldDelegate, UITextViewDelegate>

- (id)initWithTalentInfo:(HDTalentInfo *)talent type:(WJPersonalType)type;

@end
