//
//  HDShareViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "HDContactViewCtr.h"

@interface HDShareViewCtr : UIViewController

@property (strong) WJPositionInfo   *positionInfo;
@property (strong) HDTalentInfo     *talentInfo;

- (id)initWithPosition:(WJPositionInfo *)position;
- (id)initWithTalent:(HDTalentInfo *)talent;
@end
