//
//  HDEmUserInfo.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDEmUserInfo.h"

@implementation HDEmUserInfo

+ (id)infoWithDictionary:(NSDictionary *)dic{
    return [[HDEmUserInfo alloc] initWithDictionary:dic];
}
- (id)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.sJid           = FORMAT(@"%@", !dic[@"jid"]?            @"": dic[@"jid"]);
        self.sLastLoginTime = FORMAT(@"%@", !dic[@"LastLoginTime"]?  @"": dic[@"LastLoginTime"]);
        self.sPassword      = FORMAT(@"%@", !dic[@"password"]?       @"": dic[@"password"]);
        self.sResource      = FORMAT(@"%@", !dic[@"resource"]?       @"": dic[@"resource"]);
        self.sToken         = FORMAT(@"%@", !dic[@"token"]?          @"": dic[@"token"]);
        self.sUserName      = FORMAT(@"%@", !dic[@"username"]?       @"": dic[@"username"]);
    }
    return self;
}

@end
