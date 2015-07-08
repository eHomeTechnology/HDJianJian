
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@interface BaseFunc : NSObject
+ (id)getObjectNotNull:(id)obj;
+ (BOOL)isFirstLaunch;
+ (NSString *)getAppShortVersion;
+ (NSString *)getAppBuildVersion;
+ (NSString *)formatDateWithTimestamp:(double)timestamp dateFormat:(NSString *)dateFormat;
+ (void)cleanCookie;
+ (NSString *)calculateRefreshTime:(NSDate*)compareDate;
+ (BOOL)isJailbroken;
+ (NSString *)getImei;
+ (NSString *)getString:(id)value;
+ (CGSize)getStringSize:(NSString *)string onSize:(CGSize)size atFont:(UIFont *)font;
+ (NSString *)trim:(NSString *)str;
+ (NSString *)getRadomKey:(NSString *)seed;
@end
