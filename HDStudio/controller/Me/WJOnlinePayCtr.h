//
//  WJOnlinePayCtr.h
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartnerConfig.h"


@interface WJOnlinePayCtr : UIViewController<UITextFieldDelegate>

//@property (strong) NSString *allBalance; //账户余额
//@property (assign) BOOL      isOnlinePay;//用来判断是缴纳保证金还是在线充值
//@property (strong) NSString *tradeid;//交易模式编号
@property (strong) NSString *payID;//支付id
//@property (strong) NSString *shopPrice;//商品价格
@property (strong) NSString *merchandiseNum;//商品数量

/*
 **tradeid 交易模式编号
 **price   商品价格
 **type    缴纳保证金 购买服务 在线充值
 **buyID   购买id
 **userNO  用户编号
 **nickNO  荐客编号
 */
- (id)initWithTradeid:(NSString *)tradeid shopPrice:(NSString *)price payType:(NSInteger)type nickNo:(NSString *)nickNO;
@end
