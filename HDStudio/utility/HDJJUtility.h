//
//  HDJJUtility.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFImageRequestOperation.h"
#import "HDHUD.h"
#import "HDAddressInfo.h"
#import "HDUserInfo.h"
#import "HDEmUserInfo.h"
#import "EaseMob.h"
#import "WJPositionInfo.h"

typedef NS_ENUM(NSInteger, HDExtendType) {
    HDExtendTypeTrade = 0,  //行业
    HDExtendTypePost,       //职能
    HDExtendTypeArea,       //地区
    HDExtendTypeWorkExp,    //工作年限
    HDExtendTypeSalary,     //薪资
    HDExtendTypeEducation,  //教育程度，eg:本科，硕士等
    HDExtendTypeProperty,   //公司性质，eg:合资、民营、国企等
    HDExtendTypeBank,       //银行
    HDExtendTypeReward,     //赏金
};

typedef NS_ENUM(NSInteger, WJPersonalType) {
    WJPersonalTypeEdit = 0,     //编辑人选
    WJPersonalTypeAdd,          //添加人选
};

typedef NS_ENUM(NSInteger, WJResumeType) {
    WJPublishType   = 1,    //发布简历
    WJReceiveType   = 2,   //收到简历
};

typedef NS_ENUM(NSInteger, WJPayType) {
    WJPayRewardType  = 0,  //缴纳保证金
    WJPayBuyServiceType ,  //购买服务
    WJOnlineCharge,        //在线充值
};
#define UmengAppkey     "54f6a054fd98c5fd87000ab2"

#define HD_NOTIFICATION_KEY_SHARE_POSITION              @"SHARE_POSITION"               //职位分享
#define HD_NOTIFICATION_KEY_REFRESH_MY_POSITION_LIST    @"NOTI_REFRESH_MY_POSTION_LIST"
#define HD_NOTIFICATION_KEY_LOGIN_SUCCESS_ACTION        @"NOTI_LOGIN_SUCCESS_ACTION"
#define HD_NOTIFICATION_KEY_REGISTER_SUCCESS            @"NOTI_REGISTER_SUCCESS"        //正常注册成功跳转荐友圈
#define HD_NOTIFICATION_KEY_THIRD_REGISTER_SUCCESS      @"NOTI_THIRD_REGISTER_SUCCESS"  //第三方注册成功跳转荐友圈
#define HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST           @"REFRESH_BLOG_LIST"
#define HD_NOTIFICATION_KEY_BLOG_CELL_POSITION_ACTION   @"BLOG_CELL_POSITION_ACTION"    //博客界面点击职位或人选事件
#define HD_NOTIFICATION_KEY_OPEN_RESUME                 @"OPEN_RESUME"
#define HD_NOTIFICATION_KEY_BUBBLE_CELL_CHECK           @"BUBBLE_CELL_CHECK"            //聊天界面点击简历或职位事件通知
#define HD_NOTIFICATION_KEY_EDIT_PERSONAL               @"EDIT_PERSONAL"                //编辑人选后用来刷新查看人选界面
#define HD_NOTIFICATION_KEY_REFRESH_CONVERSATION_LIST   @"REFRESH_CONVERSATION_LIST"    //刷新会话消息列表界面通知，
#define HD_NOTIFICATION_KEY_NEET_TO_LOGIN               @"NEET_TO_LOGIN"                //用户未登录，需要登录，通知
#define HD_NOTIFICATION_KEY_PREVIEW_BLOG_IMAGE          @"PREVIEW_BLOG_IMAGE"           //荐友圈预览image通知
#define WJ_NOTIFICATION_KEY_PAY_SUCCESS                 @"PAY_SUCCESS"                  //在线充值支付成功
#define WJ_NOTIFICATION_KEY_BUY_SERVICE_SUCCESS         @"BUY_SERVICE_SUCCESS"          //购买服务成功
#define WJ_NOTIFICATION_KEY_DONE_SERVICE                @"DONE_SERVICE"                 //完成服务

#define MAX_QQ_NAME             15      //qq名称最大长度
#define MAX_WEIXIN_NAME         32      //微信名称最大长度
#define MAX_EMPLOYEE_NAME       30      //雇主即公司名称最大值
#define MAX_POSITION_TITLE      50      //职位名称最大值
#define MAX_POSITION_REMARK     3000    //职位描述最大字符数（先随便写下，组织上还没定）
#define MAX_SHOP_NAME           32      //最大才铺名称大小
#define MAX_SHOP_ANNOUNCE       150     //店铺公告最大长度

#define KEYBOARD_HEIGHT         216.0   //键盘高度
#define ANIMATION_DURATION      0.2     //动画时间
#define MAX_LENTH_WIFI          20      //wifi名称最大长度
#define MAX_LENTH_PASSWORD      100     //密码最大长度
#define MIN_LENTH_PASSWORD      6       //密码最小长度
#define MAX_LENTH_EMAIL         30      //邮箱最大长度

#define LOGIN_USER      @"login_user"   //登录用户key
#define LOGIN_PWD       @"login_pwd"    //登陆用户密码
#define IS_FIRST_USE    @"isFirstUse"   //第一次使用
#define VERSION         @"1.0.6"        //软件版本
#define VERSION_CODE    @"15070601"     //软件版本code
#define PLATFORM        @"101"          //平台编号
#define CHANAL          @"6"            //渠道，6：企业版，7：appstore版
#define IMAGE_DOCUMENT  FORMAT(@"%@_image", [HDGlobalInfo instance].userInfo.sHumanNo)//图片地址映射表key

#define PATH_PLIST_REGULAR  [[NSBundle mainBundle] pathForResource:@"RegularData" ofType:@"plist"]
#define MDIC_PLIST          [[NSMutableDictionary alloc] initWithContentsOfFile:PATH_PLIST_REGULAR]

#define PATH_PLIST_EARA     [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"]
#define MAR_PLIST_EARA      [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_EARA]

#define PATH_PLIST_FEEDBACK [[NSBundle mainBundle] pathForResource:@"feedback" ofType:@"plist"]
#define MAR_PLIST_FEEDBACK  [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_FEEDBACK]

#define PATH_PLIST_POST     [[NSBundle mainBundle] pathForResource:@"post" ofType:@"plist"]
#define MAR_PLIST_POST      [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_POST]

#define PATH_PLIST_TRADE    [[NSBundle mainBundle] pathForResource:@"trade" ofType:@"plist"]
#define MAR_PLIST_TRADE     [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_TRADE]

#define PATH_PLIST_WORKEXP  [[NSBundle mainBundle] pathForResource:@"workExp" ofType:@"plist"]
#define MAR_PLIST_WORKEXP   [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_WORKEXP]

#define PATH_PLIST_SALARY   [[NSBundle mainBundle] pathForResource:@"salary" ofType:@"plist"]
#define MAR_PLIST_SALARY    [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_SALARY]

#define PATH_PLIST_EDUCATION    [[NSBundle mainBundle] pathForResource:@"education" ofType:@"plist"]
#define MAR_PLIST_EDUCATION     [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_EDUCATION]

#define PATH_PLIST_PROPERTY     [[NSBundle mainBundle] pathForResource:@"property" ofType:@"plist"]
#define MAR_PLIST_PROPERTY      [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_PROPERTY]

#define PATH_PLIST_BANK         [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"plist"]
#define MAR_PLIST_BANK          [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_BANK]

#define PATH_PLIST_REWARD         [[NSBundle mainBundle] pathForResource:@"reward" ofType:@"plist"]
#define MAR_PLIST_REWARD          [[NSMutableArray alloc] initWithContentsOfFile:PATH_PLIST_REWARD]

typedef NS_ENUM(NSInteger, HDRecommendFeedbackType) {
    HDRecommendFeedbackTypeWaitingForResponse,      //0	待反馈
    HDRecommendFeedbackTypeSuitable,                //1	人选合适
    HDRecommendFeedbackTypeUndetermined,            //2	待定
    HDRecommendFeedbackTypeNotSuitable,             //3	人选不合适
    HDRecommendFeedbackTypeInterviewing,            //4	面试
    HDRecommendFeedbackTypeHired,                   //5	录用
    HDRecommendFeedbackTypePosted,                  //6	上岗
};


@interface HDJJUtility : NSObject{

    
}

@property (strong) HDHUD *hud;
@property (strong) AFHTTPRequestOperation *op_veriable;
@property (strong) AFHTTPRequestOperation *op_parameter;

+ (void)jjSay:(NSString *)message delegate:(id)object;

/**
 @brief    友盟分享
 @param    url     分享网络地址
 @param    title   标题
 @param    image   图片
 @param    target  调用对象
 @discussion
 */
+ (void)umshareUrl:(NSString *)url title:(NSString *)title image:(UIImage *)image target:(id)target;

/**
 @brief    自定义友盟职位分享
 @param    positionInfo     分享的职位
 @param    type             分享到不同平台的类别
 @param    image            分享的职位相关图片
 @param    shareTxt         分享的文字内容，文案
 @param    object           回调代理的对象
 @discussion
 */

+ (void)umsharePosition:(WJPositionInfo *)positionInfo withType:(NSString *)type image:(UIImage *)image shareText:(NSString *)shareTxt delegate:(id)object;

/**
 @brief     由url得到图片，如果本地没有改图片，下载，下次调用就能得到，未完成
 @param     url     图片网络地址
 @return    image   返回图片
 @discussion    如果该图片已经下载过，本地有该图片，则不会进行网络请求，直接返回本地图片
 */
+ (UIImage *)image:(NSString *)url;

/**
 @brief     下载图片
 @param     url     图片网络地址
 @return    code    结果编码，0成功,1返回默认图片，-1返回失败图片
 @return    message 返回结果描述
 @return    image   返回图片
 @discussion    如果该图片已经下载过，本地有该图片，则不会进行网络请求，直接返回本地图片
 */
+ (void)getImage:(NSString *)url withBlock:(void(^)(NSString *code, NSString *message, UIImage *img))block;

/**
 @brief     公元元年开始的时间戳转为当前时间
 @param     secs 公元元年开始计时的时间戳
 @return    1970年开始计时的时间
 @discussion 针对某些服务器计算时间戳是从公元元年开始，iOS和安卓都是1970年开始
 */
+ (NSDate *)dateWithTimeIntervalSiceChristionEra:(NSTimeInterval)secs;

/**
 @brief     搭建软件结构
 @return    返回架构基础UITabbarController
 */
+ (UITabBarController *)structTheBuilding;

/**
 @brief     全局变量网络获取失败的话，调用改方法从本地plist文件读取
 @return    HDAddressInfo全局变量实例
 */
+ (HDAddressInfo *)getGlobalVariableFromLocalPlist;


- (void)stopHttp;
- (void)httpGetGlobalVariable:(void(^)(BOOL isSuc))block;

/**
 @brief     将服务器返回的地区json数据转为本地使用的areaInfo数据类型，
 @param     ar_area josn转化成的array形式
 @return    以areaInfo组成的数组
 @discussion 主要网络接口那边调用和网络出错的时候需要调用本地plist文件的时候调用到该方法
 */
+ (NSMutableArray *)transformAreaInfoFromJson:(NSArray *)ar_area;

/**
 @brief     将服务器返回的职能json数据转为本地使用的postInfo数据类型，
 @param     ar_post josn转化成的array形式
 @return    以postInfo组成的数组
 @discussion 主要网络接口那边调用和网络出错的时候需要调用本地plist文件的时候调用到该方法
 */
+ (NSMutableArray *)transformPostInfoFromJson:(NSArray *)ar_post;

/**
 @brief     将服务器返回的工作经验年限json数据转为本地使用的HDValueInfo数据类型，
 @param     ar_values josn转化成的array形式
 @return    以HDValueInfo组成的数组
 @discussion 主要网络接口那边调用和网络出错的时候需要调用本地plist文件的时候调用到该方法
 */
+ (NSMutableArray *)transformValueInfoFromJson:(NSArray *)ar_values;

+ (BOOL)isNull:(id)object;

//**********************************吴健**************************
/*
 **将服务器返回的数字每三位数以 “,”隔开
 */
+ (NSString *)countNumAndChangeformat:(NSString *)num;

/**
 @brief     计算返回str的宽度
 @param     str         要计算宽度的字符串
 @param     font        字体
 @param     widthMax    最大宽度
 @return    字符串的宽度
 @discussion 用余只有一行字符串的情况
 */
+ (CGFloat)withOfString:(NSString *)str font:(UIFont *)font widthMax:(NSInteger)widthMax;
/**
 @brief     计算返回str的高度
 @param     str     要计算高度的字符串
 @param     font    字体
 @param     w       计算高度所依赖的宽度，
 @param     height  最大高度
 @return    字符串的高度
 @discussion 计算高度是在确定的宽度基础上，
 */
+ (CGFloat)heightOfString:(NSString *)str font:(UIFont *)font width:(int)w maxHeight:(int)height;

//截取html标签里的内容，他们都是<>开头内容  str 用来表示以什么分割
+ (NSString *)flattenHTML:(NSString *)html string:(NSString *)str;

//时间转换
+ (NSString*)timeConversion:(NSInteger)dateInteger;
@end
