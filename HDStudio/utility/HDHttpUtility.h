//
//  HDHttpUtility.h
//  SNVideo
//
//  Created by Hu Dennis on 14-8-22.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFJsonRequestOperation.h"
#import "AFHTTPClient.h"
#import "MBProgressHUD.h"
#import "HDUserInfo.h"
#import "HDAddressInfo.h"
#import "SBJson.h"
#import "HDEvaluateInfo.h"
#import "HDCompanyInfo.h"
#import "HDIMPositionInfo.h"
#import "HDTalentInfo.h"
#import "HDProgressInfo.h"
#import "HDNewsInfo.h"
#import "HDJFriendInfo.h"
#import "HDValueItem.h"
#import "WJBrokerInfo.h"
#import "WJSaveRecommendInfo.h"
#import "WJBalanceInfo.h"
#import "WJTradeRecordListInfo.h"
#import "WJRewardMessageInfo.h"
#import "HDBlogInfo.h"
#import "WJPositionInfo.h"
#import "WJServiceInfo.h"
#import "HDApproveViewCtr.h"
#import "WJBuyServiceListInfo.h"
#import "WJBuyServiceDetailsInfo.h"
#import "WJMerchandiseListInfo.h"
#import "WJBankInfo.h"
#import "WJLinkmanListInfo.h"

#define IP @"http://app2.liudu.com/API/"
//#define IP @"http://fuzhouliudu.eicp.net:30004/API/"
//#define IP @"http://JJ.liudu.com/API/"

@interface HDHttpUtility : AFHTTPClient{

    //MBProgressHUD *HUD;
}

/******************************************************************************************************/

/******************************************************************************************************/
+ (HDHttpUtility *)sharedClient;
+ (HDHttpUtility *)instanceWithUrl:(NSString *)url;
- (BOOL)isNull:(id)object;
/******************************************************************************************************/

/******************************************************************************************************/

#pragma mark --登录（102）
/**
 @brief     登录（102）
 
 @param     phone      手机号码
 @param     pwd        密码
 
 @return    isSuccess  是否成功
 @return    sCode      信息代码
 @return    sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)loginWithPhone:(NSString *)phone password:(NSString *)pwd CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage))completionBlock;

#pragma mark --修改密码(Act106)
/**
 @brief     修改密码(Act106)）
 
 @param     user       用户，非空
 @param     old        旧密码，非空
 @param     new        新密码，非空
 
 @return    isSuccess  是否成功
 @return    sCode      信息代码
 @return    sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)changePassword:(HDUserInfo *)user old:(NSString *)old new:(NSString *)new completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --请求秘钥（107）
/**
 @brief     请求秘钥（107）
 
 @return    key         秘钥
 @return    isSuccess   是否成功
 @return    sCode       信息代码
 @return    sMessage    信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getRandomKey:(void (^)(BOOL isSuccess, NSString *key, NSString *code, NSString *message))completionBlock;

#pragma mark --发送验证码（109）
/**
 @brief 发送验证码（109）
 
 @param phone       手机号码
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)sendMessage:(NSString *)phone isReg:(NSString *)isReg CompletionBlock:(void (^)(BOOL isSuccess, NSString *msgCode, NSString *sMessage))completionBlock;

#pragma mark --获取用户个人资料信息(Act114)
/**
 @brief 获取用户个人资料信息(Act114)
 
 @param user        用户，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getProfileInformation:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDUserInfo *user))block;

#pragma mark --上传头像或背景图片(Act115)
/**
 @brief 上传头像或背景图片(Act115)
 
 @param user        用户对象，不能为空
 @param flag        1、店铺logo（pass） 2、上传店铺背景图片（pass） 3、雇主场景 4、用户头像
 @param avata       头像或背景图片，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)uploadLogo:(HDUserInfo *)user flag:(NSString *)flag avatar:(UIImage *)avata completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block;

#pragma mark --手机注册(Act122)
/**
 @brief 手机注册(Act122)
 
 @param userName    注册手机号，非空。
 @param name        用户昵称，非空
 @param pwd         密码，非空，6位以上
 @param positionCode        验证码
 @param phone      手机号码
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)registerWithPhone:(NSString *)phone nickname:(NSString *)name password:(NSString *)pwd code:(NSString *)code CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage))block;
#pragma mark --校验验证码（123）
/**
 @brief 校验验证码（123）
 
 @param phone       注册手机号，非空。
 @param sCode       验证码
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)verifyMessageCode:(NSString *)phone code:(NSString *)sCode CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))completionBlock;

#pragma mark --用户预设信息（完善注册信息）(Act125)
/**
 @brief 用户预设信息（完善注册信息）(Act125)
 
 @param user        用户信息，非空。
 @param dic         四个预设值的codeID，非空，key：@“trade”， @“post”， @“area”，@“workExp”
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)presetUserInfo:(HDUserInfo *)user itemCodes:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --修改个人信息(Act127)
/**
 @brief 修改个人信息(Act127)
 
 @param user        用户信息，非空。
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)modifyProfile:(HDUserInfo *)user modifyUser:(HDUserInfo *)u completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取我的联系人列表(Act133)
/**
 @brief 获取我的联系人列表(Act133)
 
 @param user        用户信息，非空。
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getMyContactList:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *lists))block;

#pragma mark --获取我的荐荐信息（me主页）(Act135)
/**
 @brief 获取我的荐荐信息（me主页）(Act135)
 
 @param user        用户信息，非空。
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getMyJianJianInfomation:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDMyJianJianInfo *info))block;

#pragma mark --申请认证(Act137)
/**
 @brief 申请认证(Act137)
 
 @param user        用户信息，非空。
 @param dic_info    要上传的信息字典，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)askForApprove:(HDUserInfo *)user approveInfo:(NSDictionary *)dic_info completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取我的认证记录(Act138)
/**
 @brief 获取我的认证记录(Act138)
 
 @param user        用户信息，非空。
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getMyApproveInformation:(HDUserInfo *)user pageIndex:(int)index size:(int)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *array))block;

#pragma mark --获取职位列表（201）
/**
 @brief 获取职位列表（201）
 
 @param user        用户信息，非空。
 @param index       起始页
 @param size        每一页数量
 @param isOff       上架还是下架
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getPositionList:(HDUserInfo *)user pageIndex:(NSString *)index pageSize:(NSString *)size isOffShelve:(BOOL)isOff  CompletionBlock:(void (^)(BOOL isSuccess, BOOL isLastPage, NSArray *positons, NSString *sCode, NSString *sMessage))completionBlock;

#pragma mark --发布职位(202)
/**
 @brief 发布职位(202)
 
 @param user        用户信息，非空。
 @param type        雇主操作类型 0:不传雇主信息 1：不变（为1时只要传雇主编号） 2：添加 3：更新
 @param p           职位
 @param ar          图片，不超过4张，可以为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)releasePosition:(HDUserInfo *)user opType:(int)type position:(WJPositionInfo *)p images:(NSArray *)ar CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *positionId))block;

#pragma mark --获取评价信息（308）
- (AFHTTPRequestOperation *)getEvaluateInfomation:(NSString *)recommendId user:(HDUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDEvaluateInfo *info))completionBlock;


#pragma mark --获取职位信息(205)***替换成218
- (AFHTTPRequestOperation *)getPositionInfo:(HDUserInfo *)user pid:(NSString *)pId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info))block;
#pragma mark --修改职位信息（204）
- (AFHTTPRequestOperation *)modifyPosition:(HDUserInfo *)user position:(WJPositionInfo *)p completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark --上传职位场景图片（206）
- (AFHTTPRequestOperation *)postImageScene:(HDUserInfo *)user images:(NSArray *)ar positionId:(NSString *)pid completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block;


#pragma mark --修改职位场景图片(Act207)
/**
 @brief 修改职位场景图片(Act207)
 
 @param user            用户对象
 @param img             新图片
 @param positionId      职位编号
 @param sceneId         被修改的场景编号，1~4
 @param isDelete        删除还是添加， yes：删除，no：添加
 @return none
 
 @discussion
 */
- (AFHTTPRequestOperation *)changeImageScene:(HDUserInfo *)user image:(UIImage *)img positionId:(NSString *)pid sceneId:(NSString *)sceneId isDelete:(BOOL)isDelete completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block;

#pragma mark --导入多个职位(Act208)
/**
 @brief 导入多个职位(Act208)
 
 @param user            用户对象
 @param ar              职位对象集合
 @param enterpriceId    公司编号
 @return none
 
 @discussion
 */
- (AFHTTPRequestOperation *)releasePositions:(HDUserInfo *)user positions:(NSArray *)ar enterpriceId:(NSString *)enterproceId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark --职位上架下架操作(Act209)
/**
 @brief 职位上架下架操作(Act209)
 @param user        用户对象,不能为空
 @param isOff       yes:下架, NO:上架
 @param pId         职位编号
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)changeShelve:(HDUserInfo *)user isUnshelve:(BOOL)isOff positionId:(NSString *)pId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取雇主信息列表(Act217)
/**
 @brief 获取雇主信息列表(Act217)
 @param user        用户对象,不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getEmployeeInfoList:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *mar, BOOL isLastPage))block;

#pragma mark --设置反馈状态(Act301)
/**
 @brief 设置反馈状态(Act301)
 @param user        用户对象，不能为空
 @param rId         人选ID
 @param type        反馈编码
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)setFeedbackType:(HDUserInfo *)user recommendId:(NSString *)rId feedbackType:(int)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取朋友推荐的对应职位的人才(Act306)
/**
 @brief 获取朋友推荐的对应职位的人才(Act306)
 @param user            用户对象，不能为空
 @param pId             职位ID，如果为空，则返回所有职位对应的人才，也就是返回所有朋友推荐的人才
 @param index           起始页码
 @param size            每一页的条数
 
 @return isSuccess      是否成功
 @return sCode          信息代码
 @return sMessage       信息
 @return isLastPage     是否是最后一页
 @return ar_rcmd        人选列表，
 
 @discussion
*/
- (AFHTTPRequestOperation *)getRecommendList:(HDUserInfo *)user position:(NSString *)pId pageIndex:(NSString *)index pageSize:(NSString *)size CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd))completionBlock;

#pragma mark --获取人选进展状态列表(Act307)
/**
 @brief 获取人选进展状态列表(Act307)
 @param user            用户对象,不能为空
 @param rId             人选ID，不能为空
 
 @return isSuccess      是否成功
 @return sCode          信息代码
 @return sMessage       信息
 @return progressList   人选进展状态列表
 
 @discussion
 */
- (AFHTTPRequestOperation *)getRecommendProgress:(HDUserInfo *)user recommendId:(NSString *)rId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *progressList))block;

#pragma mark -- 修改人才简历(Act312)
/**
 @brief 修改人才简历(Act312)
 @param user        用户对象，不能为空
 @param talent      人才信息，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)modifyTalent:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --新增人才简历(Act313)
/**
 @brief 新增人才简历(Act313)
 @param user        用户对象，不能为空
 @param talent      人才信息，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)newTalent:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取我添加的人才(Act314) 
/**
 @brief 获取我添加的人才(Act314)
 
 @param user        用户对象
 @param index       起始页码
 @param size        每一页的条数
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
*/
- (AFHTTPRequestOperation *)getMyTalent:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block;

#pragma mark --获取我的小伙伴列表（联系人）(Act317)
/**
 @brief 获取我的小伙伴列表（联系人）(Act317)
 
 @param user        用户对象
 @param index       起始页码
 @param size        每一页的条数
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getMyJFriends:(HDUserInfo *)user index:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar_friends, BOOL isLast))block;

#pragma mark --获取所有人才列表（联系人-人才）(Act318)
/**
 @brief 获取所有人才列表（联系人-人才）
 
 @param user        用户对象
 @param index       起始页码
 @param size        每一页的条数
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return talents    人才列表
 @discussion
 */
- (AFHTTPRequestOperation *)getAllTalent:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block;

/**
 @brief 推荐现有人选(Act319)
 
 @param user        用户对象,非空
 @param positionNo  职位ID，非空
 @param talentNo    人选ID，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return talents    人才列表
 @discussion
 */
#pragma mark --推荐现有人选(Act319)
- (AFHTTPRequestOperation *)recommendMyTalent:(HDUserInfo *)user position:(NSString *)positionNo talent:(NSString *)talentNo completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDRecommendInfo *info))block;

#pragma mark --获取各类型订阅号消息列表(Act502)
/*!
 @brief 获取各类型订阅号消息列表(Act502)
 
 @param user        用户对象，不能为空
 @param ticks       上次向服务器取数据时的时间戳，由上一次请求服务器时下传
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return list       消息列表
 @return isLastPage 是否最后一页
 @return ticks      当前服务器时间戳
 
 @discussion 首页消息列表调用
 */
- (AFHTTPRequestOperation *)getSubscribeNews:(HDUserInfo *)user pageIndex:(int)index pageSize:(int)size  lastTicks:(NSString *)ticks completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage, NSString *tick))block;

#pragma mark --获取某订阅号详细消息列表(Act503)
/**
 @brief 获取某订阅号详细消息列表(Act503)
 
 @param user        用户对象
 @param index       起始页码
 @param size        每一页的条数
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getSubscribeDetail:(HDUserInfo *)user subscribeId:(NSString *)subId lastTicks:(NSString *)ticks completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage))block;

#pragma mark --检查更新(Act601)
/**
 @brief 检查更新(Act601)
 
 @param user        用户对象
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)updateVersion:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic))block;

#pragma mark --获取全局参数(Act602)
/**
 @brief 获取全局参数(Act602)
 
 @param user        用户对象，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getGlobalParameters:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic))block;

#pragma mark --意见反馈(Act603)
/**
 @brief 意见反馈(Act603)
 
 @param user        用户对象，不能为空
 @param content     反馈内容，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)feedback:(HDUserInfo *)user content:(NSString *)content completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --获取荐友圈广告(Act604)
/**
 @brief 获取荐友圈广告(Act604)
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return ar         广告Information
 
 @discussion
 */
- (AFHTTPRequestOperation *)getAdvertisementBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block;

#pragma mark --获取全局变量(Act605)
/*!
 @brief 获取全局变量(Act605)
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getGlobalVariable:(void (^)(BOOL isSuccess, HDAddressInfo *info, NSString *sCode, NSString *sMessage))completionBlock;

#pragma mark --添加博客(Act801)
/*!
 @brief 添加博客(Act801)
 
 @param user    用户信息，非空
 @param ar      图片数组，最多3张，可以为空
 @param content 博客内容，不能为空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)releaseBlog:(HDUserInfo *)user images:(NSArray *)ar content:(NSString *)content completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block;

#pragma mark --获取朋友圈博客列表(Act802)
/*!
 @brief 获取朋友圈博客列表(Act802)
 
 @param user，未登录状态传空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)getBlogList:(HDUserInfo *)user pageIndex:(int)index size:(int)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *lists))block;

#pragma mark --收藏博客(Act806)
/*!
 @brief 收藏博客(Act806)
 
 @param user
 @param blogId      要收藏的博客ID
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)collectBlog:(HDUserInfo *)user blog:(NSString *)blogId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark --分享博文、职位、简历到荐友圈(Act808)
/*!
 @brief 分享博文、职位、简历到荐友圈(Act808)
 
 @param user
 @param pId         职位ID
 @param rId         简历ID
 @param type        类别，1：职位，2：简历
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
 @discussion
 */
- (AFHTTPRequestOperation *)shared2Blog:(HDUserInfo *)user positionId:(NSString *)pId resumeId:(NSString *)rId type:(int)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark - -

/******************************************************************************************************/

/******************************************************************************************************/
#pragma mark --根据公司名称搜索查询公司
/*!
 @brief 根据公司名称搜索查询公司
 
 @param name        公司关键字，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return ar         公司列表
 
 @discussion
 */
- (AFHTTPRequestOperation *)queryForCompanyName:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block;

#pragma mark --导入职位描述-根据职位名称模糊匹配职位(QueryPositionName)
/*!
 @brief 导入职位描述-根据职位名称模糊匹配职位(QueryPositionName)
 
 @param name        职位模糊关键字，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return ar         职位列表
 
 @discussion
 */
- (AFHTTPRequestOperation *)queryForPositionNames:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block;

#pragma mark --导入职位-根据公司ID查询职位列表(GetPositions )
/*!
 @brief 导入职位-根据公司ID查询职位列表(GetPositions)
 
 @param enterpriceId 公司ID，非空
 
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return ar         职位列表
 
 @discussion
 */
- (AFHTTPRequestOperation *)queryForPositionList:(NSString *)enterpriceId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block;


- (AFHTTPRequestOperation *)queryForPositions:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block;


#pragma mark **************************************************************************************
#pragma mark -- 吴健
#pragma mark **************************************************************************************
#pragma mark -- 第三方账号登录(Act116)
//第三方登陆类型,参考OpenAuthCode(1 腾讯微博 2 新浪微博 3 QQ 4 微信)
- (AFHTTPRequestOperation *)getThirdPartLogin:(NSString *)openAuth openUserID:(NSString *)userId openToken:(NSString *)token completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDUserInfo *user))block;
#pragma mark -- 第三方账号注册(Act117)
- (AFHTTPRequestOperation *)thirdPartyRegisterWithMobile:(NSString *)mobile openUserId:(NSString *)uid openToken:(NSString *)token nickName:(NSString *)name validCode:(NSString *)code openAuth:(NSString *)auth CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage))block;
#pragma mark -- 第三方账号绑定(Act118)
- (AFHTTPRequestOperation *)thirdPartyBoundWithPhone:(NSString *)openAuth openUserId:(NSString *)uid openToken:(NSString *)token CompletionBlock:(void (^)(BOOL isSuccess, NSString *msgCode, NSString *sMessage))block;

#pragma mark -- 获取荐客信息(Act124)
- (AFHTTPRequestOperation *)getBrokerInfo:(HDUserInfo *)user userno:(NSString *)userno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info))block;

#pragma mark --关注用户-根据用户ID关注用户(AttentionUser  Act131)
/*!
 @brief 关注用户-根据用户ID添加关注(AttentionUser)
 
 @param usernos 用户ID，非空
 @param isfocus 是否关注(1 关注  0取消关注)
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 
@discussion
 */
- (AFHTTPRequestOperation *)attentionUser:(HDUserInfo *)user usernos:(NSString *)usernos isfocus:(NSString *)isfocus completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;

#pragma mark -- 找荐客搜索（Act132）
- (AFHTTPRequestOperation *)getBrokerList:(HDUserInfo *)user dic:(NSDictionary *)dic pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *brokers))block;
#pragma mark --获取联系人列表(Act139)
/*
 @brief 获取联系人列表(getLinkmanList)

 @param contacttype 联系人类型  1、订阅号; 2、关注;  3、手机通讯录;  4、访客;  5、粉丝
 @return isSuccess  是否成功
 @return sCode      信息代码
 @return sMessage   信息
 @return list       联系人列表
 
 @discussion
 */
- (AFHTTPRequestOperation *)getLinkmanList:(HDUserInfo *)user contacttype:(NSString *)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *list))block;

#pragma mark -- 第三方注册完善个人资料(Act140)
- (AFHTTPRequestOperation *)presetThirdPartyUserInfo:(HDUserInfo *)user parameters:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark --查找职位列表(Act211)
- (AFHTTPRequestOperation *)checkPosition:(HDUserInfo *)user typeDic:(NSDictionary *)typeDic sort:(NSString *)sort pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block;
#pragma mark --设置职位悬赏金(Act215)
- (AFHTTPRequestOperation *)settingPositionReward:(HDUserInfo *)user positionID:(NSString *)positionId delayDay:(NSString *)delayDay reward:(NSString *)reward CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *ID))block;
#pragma mark --我的推荐订单(Act216)
- (AFHTTPRequestOperation *)getMyRecommendOrder:(HDUserInfo *)user  sort:(NSString *)sort pageIndex:(NSString *)index size:(NSString *)size  completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block;
#pragma mark --新增候选人并推荐(Act309)
- (AFHTTPRequestOperation *)addPeopleAndRecommend:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,NSDictionary *talents))block;
#pragma mark --保存推荐人(Act310)
- (AFHTTPRequestOperation *)saveRecommendPeople:(HDUserInfo *)user recommend:(WJSaveRecommendInfo *)recommend completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark --保存评价信息(Act311)
- (AFHTTPRequestOperation *)saveEvaluateInfo:(HDUserInfo *)user evaluate:(HDEvaluateInfo *)evaluate completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *matchId))block;
#pragma mark --搜索简历(Act323)
- (AFHTTPRequestOperation *)searchResume:(HDUserInfo *)user dic:(NSDictionary *)dic  pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block;
#pragma mark -- 获取简历详情(Act324)
- (AFHTTPRequestOperation *)getResumeDetails:(HDUserInfo *)user personalno:(NSString *)personalno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,  HDTalentInfo *resumeDetail))block;
#pragma mark -- 我发送的推荐简历列表(Act325)
- (AFHTTPRequestOperation *)getMeRecommendResumeList:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd))block;
#pragma mark -- 开放简历搜索设置(Act326)
- (AFHTTPRequestOperation *)openResume:(HDUserInfo *)user dic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark -- 关闭简历搜索(Act327)
- (AFHTTPRequestOperation *)closeResume:(HDUserInfo *)user personalno:(NSString *)personalno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark -- 添加推荐信(Act329)
- (AFHTTPRequestOperation *)addRecommendLetter:(HDUserInfo *)user typeDic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,NSString *recommendID))block;
/**
 **银行卡服务
 **/
#pragma mark --获取余额(Act401)
- (AFHTTPRequestOperation *)getBalance:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance))block;
#pragma mark -- 获取交易记录(Act402)
- (AFHTTPRequestOperation *)getTradeRecordList:(HDUserInfo *)user lastTicks:(NSString *)lastTicks szType:(NSString *)szType index:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,  BOOL isLastPage, NSMutableArray *list))block;
#pragma mark -- 获取银行卡信息(Act403)
- (AFHTTPRequestOperation *)getBankCardMessage:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBankInfo *bank))block;

#pragma mark --创建支付订单(Act408)
- (AFHTTPRequestOperation *)createPayOrder:(HDUserInfo *)user tradeid:(NSString *)tradeid merchandiseCode:(NSString *)merchandiseCode number:(NSString *)number channeltype:(NSString *)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *payID))block;
#pragma mark --获取悬赏金信息(Act409)
- (AFHTTPRequestOperation *)getRewardMessage:(HDUserInfo *)user recommendId:(NSString *)recommendId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block;
#pragma mark --密码支付悬赏金(Act410)
- (AFHTTPRequestOperation *)passwordPayReward:(HDUserInfo *)user psd:(NSString *)psd recommendId:(NSString *)recommendId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block;
#pragma mark -- 荐币取现(Act411)
- (AFHTTPRequestOperation *)moneyWithDraw:(HDUserInfo *)user dic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block;
#pragma mark --分页获取购买服务记录(Act413)
- (AFHTTPRequestOperation *)getBuyServiceList:(HDUserInfo *)user lastTicks:(NSString *)lastTicks isBuyer:(NSString *)isBuyer isBigger:(NSString *)isBigger pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *orderList))block;
#pragma mark -- 获取购买服务详细信息(Act414)
- (AFHTTPRequestOperation *)getBuyServiceDetail:(HDUserInfo *)user buyId:(NSString *)buyId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBuyServiceDetailsInfo *detailsInfo))block;
#pragma mark -- 获取购买服务进展列表(Act415)
- (AFHTTPRequestOperation *)getBuyServiceProgress:(HDUserInfo *)user buyId:(NSString *)buyId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block;
#pragma mark -- 购买简历服务(Act416)
- (AFHTTPRequestOperation *)buyResumeService:(HDUserInfo *)user personalNo:(NSString *)personalNo completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *buyId))block;
#pragma mark -- 商品系统参数（充值套餐）
- (AFHTTPRequestOperation *)rechargeCombo:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block;
@end
