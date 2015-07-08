//
//  HDUtility.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-6.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface HDUtility : NSObject

+ (NSDictionary *)getConectedWIFI;
/**
 跳出提示，1秒后自动消失
 @param     sMsg  提示语句
 @return    none
 
 @discussion
*/
+ (void)mbSay:(NSString *)sMsg;
/**
 跳出成功提示，
 @param     sMsg  提示语句
 @return    MBProgressHUD对象
 
 @discussion
*/
+ (MBProgressHUD *)sayAfterSuccess:(NSString *)s;
/**
 跳出失败提示，
 @param     sMsg  提示语句
 @return    MBProgressHUD对象
 
 @discussion
*/
+ (MBProgressHUD *)sayAfterFail:(NSString *)s;
/**
 跳出成功，用户手动关闭
 @param     sMsg  提示语句
 @return    void
 
 @discussion
*/
+ (void)say:(NSString *)sMsg;

+ (UIAlertView *)say:(NSString *)sMsg Delegate:(id)delegate_;
+ (UIAlertView *)say2:(NSString *)sMsg Delegate:(id)delegate_;
+ (BOOL)isEnableNetwork;
+ (BOOL)isEnableWIFI;
+ (BOOL)isEnable3G;
+ (NSString *)UnixTime;
+ (NSString *)md5: (NSString *) inPutText;
+ (void)circleTheView:(UIView *)view;
+ (void)circleWithNoBorder:(UIView *)view;
+ (void)rotateView:(UIView *)view angle:(float)angle;
+ (void)setShadow:(UIView *)view;

/** NSString验证合法性 **/
+ (BOOL)isValidateName:(NSString *)name;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidateMobile:(NSString *)mobile;
+ (BOOL)isValidateCarNo:(NSString *)carNo;
+ (BOOL)isValidatePassword:(NSString *)sPwd;
+ (BOOL)isValidateAccount:(NSString *)s;      //合法的不含特殊字符的字符串，通常用户账户，用户名等的验证
/** 时间date处理 **/
+ (NSString *)readNowTimeWithFormate:(NSString *)yyyyMMddhhmmss;
+ (NSString *)converDate2String:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)formatterDate:(NSDate *)date;
+ (NSDate *)convertDateFromString:(NSString *)sDate;

#pragma mark --返回人性化时间显示
/**
 @brief 返回人性化时间显示
 
 @param date 时间
 @return 对应时间
 
 @discussion 输入一个时间，返回人类所日常熟悉的时间称呼，如“昨天”，“前天”，“今天”“明后天”等
 */
+ (NSString *)returnHumanizedTime:(NSDate *)date;

/** 动画 **/
+ (void)showView:(UIView *)view centerAtPoint:(CGPoint)pos duration:(CGFloat)waitDuration;
+ (void)hideView:(UIView *)view duration:(CGFloat)waitDuration;
+ (void)view:(UIView *)view appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration;

/** 截屏 **/
+ (UIImage *)screenshotFromView:(UIView *)theView;
+ (UIImage *)screenshotFromView: (UIView *) theView atFrame:(CGRect)r;

+ (UIImage *)imageWithUrl:(NSString *)sUrl;
+ (BOOL)saveToDocument:(UIImage *) image withFilePath:(NSString *)filePath;
+ (NSString *)pathOfSavedImageName:(NSString *)imageName folderName:(NSString *)sFolder;

#pragma mark --保存图片到本地
/**
 @brief     保存图片到本地
 @param     image   图片
 @param     folder  文件夹名称
 @param     name    图片文件名称
 @return    返回图片保存地址
 */
+ (NSString *)saveImage:(UIImage *)image imageName:(NSString *)name folder:(NSString *)folder;
+ (BOOL)removeFileWithPath:(NSString *)path;
+ (BOOL)removeAllFile;
/** UUID **/
+ (NSString*)uuid;

/*相机*/
+ (BOOL) isCameraAvailable;
+ (BOOL) isRearCameraAvailable;
+ (BOOL) isFrontCameraAvailable;

//计算uitextview的contentsize的height
+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;

+ (UIImage *)resizeImage:(UIImage *)img_original;
@end





