//
//  HDMyPositionCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/16.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDPositionListView.h"
#import "HDChatViewCtr.h"

@protocol HDHDMyPositionCtrDelegate <NSObject>
- (void)myPositionControllerDidSelectPosition:(WJPositionInfo *)info isMeAddTalent:(BOOL)isOn;
@end


@interface HDMyPositionCtr : UIViewController

- (id)initWithObject:(HDChatViewCtr *)obj;

@end
