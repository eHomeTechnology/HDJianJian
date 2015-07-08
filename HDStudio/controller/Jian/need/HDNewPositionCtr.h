//
//  HDNewPositionCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSelectDescCtr.h"

@interface HDNewPositionCtr : UIViewController<HDSelectDescDelegate>
- (id)initWithPosition:(WJPositionInfo *)position;
@end
