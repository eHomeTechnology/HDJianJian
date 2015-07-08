//
//  WJMerchandiseListInfo.h
//  JianJian
//
//  Created by liudu on 15/6/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJMerchandiseListInfo : NSObject

@property (strong) NSString *sBGPoint;              // 购买荐币
@property (strong) NSString *sPGPoint;              // 赠送荐币
@property (strong) NSString *sCreatedDT;
@property (strong) NSString *sMerchandisePrice;     // 商品单价(分)
@property (strong) NSString *sMerchandiseName;      // 商品名称
@property (strong) NSString *sUpdatedDT;
@property (strong) NSString *sAutold;
@property (strong) NSString *sRemark;               // 商品说明
@property (strong) NSString *sProperty;
@property (strong) NSString *sShowNo;               // 排序
@property (strong) NSString *sStatus;               // 状态
@property (strong) NSString *sMerchandiseCode;      // 商品编号

@end
