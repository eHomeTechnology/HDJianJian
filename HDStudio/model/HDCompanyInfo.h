//
//  HDCompanyInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDCompanyInfo : NSObject

@property (strong) NSString *sId;   //公司ID
@property (strong) NSString *sName; //公司名称

@end


@interface HDSearchPositionNameInfo : HDCompanyInfo

@end

@interface HDEmployerInfo : HDCompanyInfo

@property (strong) NSString *sTradeCode;        //行业ID
@property (strong) NSString *sTradeText;        //行业
@property (strong) NSString *sPropertyCode;     //雇主行业ID（公司性质编号）
@property (strong) NSString *sPropertyText;     //雇主行业描述(公司性质)
@property (strong) NSString *sRemark;           //雇主描述
@property (strong) NSString *sScene01;          //场景图片网络地址1
@property (strong) NSString *sScene02;          //场景图片网络地址2
@property (strong) NSString *sScene03;          //场景图片网络地址3
@property (strong) NSString *sScene04;          //场景图片网络地址4
@property (strong) NSMutableArray   *mar_urls;  //存放有值的url

@end





