//
//  HDError.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HDErrorType) {

    HDErrorTypeWrongParameter = 100,
    
};

/*!
 @class
 @brief SDK错误信息定义类
 @discussion
 */
@interface HDError : NSObject

/*!
 @property
 @brief 错误代码
 */
@property (nonatomic) HDErrorType code;

/*!
 @property
 @brief 错误信息描述
 */
@property (strong) NSString *desc;

/*!
 @method
 @brief 创建一个EMError实例对象
 @param errCode 错误代码
 @param description 错误描述信息
 @discussion
 @result 错误信息描述实例对象
 */
+ (HDError *)errorWithCode:(HDErrorType)errCode
            andDescription:(NSString *)description;

/*!
 @method
 @brief 通过NSError对象, 生成一个EMError对象
 @param error NSError对象
 @discussion
 @result 错误信息描述实例对象
 */
+ (HDError *)errorWithNSError:(NSError *)error;

@end
