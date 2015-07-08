//
//  NSObject_Instance.h
//  FEPosUniversal
//
//  Created by DennisHu on 12-8-6.
//  Copyright (c) 2012年 __iDennisHu__. All rights reserved.
//

typedef NS_ENUM(NSInteger, HDCharacterType) {
    
    HDCharacterTypeEnglish = 0,         
    HDCharacterTypeChinese,
    HDCharacterTypeOther,
};


//----------------------系统----------------------------

//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是否 Retina屏、设备是否%fhone 5、是否是iPad
#define isRetina3_5 CGSizeEqualToSize(CGSizeMake(320, 480), [UIScreen mainScreen].bounds.size)
#define isRetina4_0 CGSizeEqualToSize(CGSizeMake(320, 568), [UIScreen mainScreen].bounds.size)
#define isRetina4_7 CGSizeEqualToSize(CGSizeMake(375, 667), [UIScreen mainScreen].bounds.size)
#define isRetina5_5 CGSizeEqualToSize(CGSizeMake(414, 736), [UIScreen mainScreen].bounds.size)
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
//----------------------系统----------------------------


//----------------------图片----------------------------

//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGEFILE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define HDIMAGE(_pointer) [UIImage imageNamed:_pointer]

//建议使用前两种宏定义,性能高于后者
//----------------------图片----------------------------


//----------------------颜色类---------------------------
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//带有RGBA的颜色设置
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

//背景色
//#define BACKGROUND_COLOR [UIColor colorWithRed:242.0/255.0 green:236.0/255.0 blue:231.0/255.0 alpha:1.0]

//清除背景色
#define CLEARCOLOR [UIColor clearColor]

#pragma mark - color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//----------------------颜色类--------------------------



#define _fileName_default__     @"default"
#define FONT_BODY               [UIFont fontWithName:@"Arial" size:13]
#define FONT_HEAD               [UIFont fontWithName:@"Arial" size:15]
#define HDCOLOR_RED             [UIColor colorWithRed:207/255. green:18/255. blue:8/255. alpha:1.0]
#define COLOR_GRAY              [UIColor colorWithRed:1.00f green:1.00f blue:1.00f alpha:1.00f];


#define SRV_CONNECTED       0
#define SRV_CONNECT_SUC     1
#define SRV_CONNECT_FAIL    2
#define debugMode           1

#ifdef DEBUG
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif

#ifdef DEBUG
#define Dlog(fmt, ...) NSLog((@"====%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define Dlog(fmt, ...)
#endif

#define HDDocumentPath ((NSString *)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])

#define DEVICE_IS_IPHONE    [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define DEVICE_IS_IPAD      [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define HDDeviceSize        [[UIScreen mainScreen] bounds].size
#define kWindow             [UIApplication sharedApplication].keyWindow
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define DOCUMENTS_FOLDER    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define FILEPATH            [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]
#define LS(s)  NSLocalizedString((s), @"")

#define ORITATION_IS_HORIZONTAL     ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft)

#define ORITATION_IS_VERTICAL       ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown)

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]

#ifndef IOS_VERSION
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#endif
#define IS_4INCH_SCREEN     (fabs((double)[[UIScreen mainScreen ] bounds].size.height - (double)568)  <  DBL_EPSILON )
#define IS_35INCH_SCREEN    (fabs((double)[[UIScreen mainScreen ] bounds].size.height - (double)568)  >= DBL_EPSILON )

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)






