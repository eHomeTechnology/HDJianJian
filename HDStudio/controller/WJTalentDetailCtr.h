//
//  WJTalentDetailCtr.h
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDChatViewCtr.h"
@interface WJTalentDetailCtr : UIViewController<UITextViewDelegate, UIAlertViewDelegate>

- (id)initWithTalentId:(NSString *)sId isMeCheckResume:(BOOL)isMeCheckResume;

@property (strong) NSString *personalno;

@end
