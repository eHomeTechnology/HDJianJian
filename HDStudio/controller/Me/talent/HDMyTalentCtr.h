//
//  HDMyTalentCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDHttpUtility.h"

typedef NS_ENUM(NSInteger, HDWhoseTalent) {
    
    HDWhoseTalentMe = 1,
    HDWhoseTalentFriend,
};

@protocol HDMyTalentDelegate <NSObject>
- (void)myTalentDidSelectTalent:(HDTalentInfo *)info isMeAddTalent:(BOOL)isOn;
@end

@interface HDMyTalentCtr : UIViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<HDMyTalentDelegate>myDelegate;
@property (strong) WJPositionInfo *positionInfo;
- (id)initWithType:(HDWhoseTalent)type;//判断是发布的简历还是收到的简历
- (id)initWithPosition:(WJPositionInfo *)position;
@end
