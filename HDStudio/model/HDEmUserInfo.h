//
//  HDEmUserInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDEmUserInfo : NSObject

@property (strong) NSString *sLastLoginTime;    //上次登录时间
@property (strong) NSString *sJid;              //eg:"master-jian#jianjian_18659152700@easemob.com"
@property (strong) NSString *sPassword;         //密码
@property (strong) NSString *sToken;            //token
@property (strong) NSString *sResource;         //登录平台，“mobile”
@property (strong) NSString *sUserName;         //用户名

+ (id)infoWithDictionary:(NSDictionary *)dic;
- (id)initWithDictionary:(NSDictionary *)dic;

@end
