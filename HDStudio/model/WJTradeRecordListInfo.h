//
//  WJTradeRecordListInfo.h
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJTradeRecordListInfo : NSObject

@property (strong) NSString *sTradeRecordID;//交易流水编号
@property (strong) NSString *sTradeType;//收支类型
@property (strong) NSString *sTradeTypeText;
@property (strong) NSString *sAmount;//金额(分)
@property (strong) NSString *sBalance;//余额(分)
@property (strong) NSString *sContent;//交易标题
@property (strong) NSString *sRemark;//交易内容
@property (strong) NSString *sCreatedTime;//交易时间
@property (strong) NSString *sOtherUserNo;//支付人或收款人
@property (strong) NSString *sOtherNickName;
@property (strong) NSString *sTransactType;//交易类型
@property (strong) NSString *sTransactTypeText;
@property (strong) NSString *sTransactID;//支付订单号


@end
