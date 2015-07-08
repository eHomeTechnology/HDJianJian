//
//  WJCheckPersonalDetailCtr.h
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCheckPersonalDetailCtr : UIViewController<UITextViewDelegate, UIAlertViewDelegate>

- (id)initWithPersonalno:(NSString *)personalno isOpen:(BOOL)isOpen;
@end
