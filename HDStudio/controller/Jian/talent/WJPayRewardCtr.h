//
//  WJPayRewardCtr.h
//  JianJian
//
//  Created by liudu on 15/5/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PayRewardDelegate <NSObject>

- (void)payRewardSuccess:(BOOL)isSuccess;

@end

@interface WJPayRewardCtr : UIViewController

@property (strong) NSString *recommendId;

@property (nonatomic,assign) id<PayRewardDelegate>delegate;
- (id)initWithInfo:(WJRewardMessageInfo *)info;
@end
