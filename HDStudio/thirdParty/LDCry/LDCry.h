//
//  LDCry.h
//  liudu
//
//  Created by 91 on 14-8-18.
//
//

#import <Foundation/Foundation.h>

@interface LDCry : NSObject
+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)message key:(NSString *)key;
+ (NSString *)md5:(NSString *)str;
//32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString;
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString;
@end
