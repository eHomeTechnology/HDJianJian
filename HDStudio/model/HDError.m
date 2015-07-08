//
//  HDError.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDError.h"

@implementation HDError

+ (HDError *)errorWithCode:(HDErrorType)errCode andDescription:(NSString *)description{
    return [[self alloc] initWithCode:errCode desc:description];
}

- (id)initWithCode:(HDErrorType)code desc:(NSString *)desc{
    if (self = [super init]) {
        self.code   = code;
        self.desc   = desc;
    }
    return self;
}
+ (HDError *)errorWithNSError:(NSError *)error{
    return [self alloc];
}
@end
