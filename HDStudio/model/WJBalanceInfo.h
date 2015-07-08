//
//  WJBalanceInfo.h
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJBalanceInfo : NSObject

@property (strong) NSString *sUserNo;
@property (strong) NSString *sGoldCount;//余额
@property (strong) NSString *sDeposit;//保证金余额
@property (strong) NSString *sTotalIn;//总收入
@property (strong) NSString *sTotalOut;//总支出
@property (strong) NSString *sGGold;
@property (strong) NSString *sGold;

@end
