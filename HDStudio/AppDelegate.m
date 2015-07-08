//
//  AppDelegate.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/10.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "AppDelegate.h"
#import "HDLoginViewCtr.h"
#import "HDDBManager.h"
#import "HDIntroduceViewCtr.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialYixinHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialConfig.h"
#import "EaseMob.h"
#import "HDEmUserInfo.h"
#import "LDCry.h"
#import "HDInstance.h"
#import "HDLoginViewCtr.h"
#import "HDPlusViewCtr.h"
#import "HDNewBlogCtr.h"
#import "HDNewsViewCtr.h"
#import "HDMeViewCtr.h"
#import "HDPreviewImageCtr.h"
#import "HDShareViewCtr.h"
#import <AlipaySDK/AlipaySDK.h>
#import <HealthKit/HealthKit.h>
#import "HDLoginHelper.h"
#import "HDBubbleData.h"

@interface AppDelegate ()<EMChatManagerDelegate, EMChatManagerLoginDelegate>{
    HDHUD *hud;
}
@property (nonatomic, strong) UIWindow  *statusWindow;
@property (nonatomic, strong) UILabel   *statusLabel;
- (void) dismissStatus;
@end

@implementation AppDelegate

#pragma mark - life cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread detachNewThreadSelector:@selector(UMSetup) toTarget:self withObject:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if ([HDGlobalInfo instance].mar_area.count == 0) {
        [[HDJJUtility new] httpGetGlobalVariable:^(BOOL isSuc) {
        }];
    }
    NSNumber *iAppCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"iAppCount"];
    if (!iAppCount) {
        iAppCount = 0;
        [[NSUserDefaults standardUserDefaults] setValue:iAppCount forKey:@"iAppCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (iAppCount > 0) {
        UITabBarController *tab = [HDJJUtility structTheBuilding];
        tab.delegate = self;
        [self.window setRootViewController:tab];
    }else{
        [self.window setRootViewController:[HDIntroduceViewCtr new]];
        iAppCount = [NSNumber numberWithInt:(iAppCount.intValue + 1)];
        [[NSUserDefaults standardUserDefaults] setValue:iAppCount forKey:@"iAppCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self setNotification];
    [self setNavigationBarAndTabBarAppearence];
    [self EaseMobSetup:application option:launchOptions];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            NSString *str = FORMAT(@"%@", [resultDic objectForKey:@"resultStatus"]);
            if (str.integerValue == 9000){//支付成功
                [[NSNotificationCenter defaultCenter] postNotificationName:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:@"SuccessA"];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:@"FailureA"];
            }
        }];
        return YES;
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            NSString *str = FORMAT(@"%@", [resultDic objectForKey:@"resultStatus"]);
            if (str.integerValue == 9000){//支付成功
                [[NSNotificationCenter defaultCenter] postNotificationName:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:@"SuccessA"];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:@"FailureA"];
            }
        }];
        return YES;
    }
    return [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[EaseMob sharedInstance] applicationWillTerminate:application];
    [self autoLogin];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

}

- (void)applicationWillTerminate:(UIApplication *)application {
    Dlog(@"...");
}

#pragma mark - EMChatManagerChatDelegate
- (void)didReceiveMessage:(EMMessage *)message{
    NSUInteger iCount = [[EaseMob sharedInstance].chatManager totalUnreadMessagesCount];
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    if (tab.viewControllers.count < 4) {
        Dlog(@"Error:tabbarController格局有变化，请更改");
        return;
    }
    UIViewController *ctr = tab.viewControllers[3];
    ctr.tabBarItem.badgeValue = FORMAT(@"%d", (int)iCount);
    if (iCount == 0) {
        ctr.tabBarItem.badgeValue = nil;
    }
    NSArray *ar = message.messageBodies;
    if (ar.count == 0) {
        Dlog(@"无消息");
        return;
    }
    NSString *sContent = @"您收到一条新的消息";
//    id<IEMMessageBody> messageBody = ar[0];
//    NSString *sContent = ((EMTextMessageBody *)messageBody).text;
//    NSDictionary *dic = message.ext;
//    NSString *name = dic[@"chat_nick_name"];
//    if (name.length > 0) {
//        sContent = FORMAT(@"%@:%@", name, sContent);
//    }
    [self addLocalNotification:sContent count:iCount];
}
#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.viewControllers.count == 0) {
        Dlog(@"Error:程序出现错误。");
        return YES;
    }
    UIViewController *ctr = nav.viewControllers[0];
    BOOL isNeedLogin = [ctr isKindOfClass:[HDPlusViewCtr class]] || [ctr isKindOfClass:[HDMeViewCtr class]] || [ctr isKindOfClass:[HDNewsViewCtr class]];
    if (![HDGlobalInfo instance].hasLogined && isNeedLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return NO;
    }
    return YES;
}

#pragma mark - private method
- (void)EaseMobSetup:(UIApplication *)application option:(NSDictionary *)launchOptions{//环信设置
    // 真机的情况下,notification提醒设置
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {//iOS8 注册APNS
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
    //注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = @"jianjian";
    EMError *error = [[EaseMob sharedInstance] registerSDKWithAppKey:@"master-jian#jianjian" apnsCertName:apnsCertName];
    if (error) {
        [HDUtility mbSay:FORMAT(@"环信App注册失败：%d, %@", (int)error.errorCode, error.description)];
    }
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}
- (void)UMSetup{//友盟设置
    [UMSocialData openLog:YES];//打开调试log的开关
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    [UMSocialData setAppKey:@UmengAppkey];
    [UMSocialWechatHandler setWXAppId:@"wx09ebbad2ac8e5236" appSecret:@"23796b4054dedfebde91d030af901c22" url:@"http://www.liudu.com"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:@"2967096646" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.liudu.com"];
    [UMSocialYixinHandler setYixinAppKey:@"yx29502700c7cd49239c1d32a37b19d2dd" url:@"http://www.liudu.com"];
    [UMSocialQQHandler setSupportWebView:YES];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    //得到的数据在回调Block对象形参respone的data属性
    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
        NSLog(@"SnsInformation is %@",response.data);
    }];
}

- (void)autoLogin{
    BOOL hasLogin = [HDGlobalInfo instance].hasLogined;
    if (hasLogin) {
        return;
    }
    NSString *sAccount  = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER];
    NSString *sPwd      = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_PWD];
    if (sAccount.length > 0 && sPwd.length > 5) {
        hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:kWindow];
        [HDLoginHelper loginJian:sAccount pwd:sPwd block:^(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage, NSString *encryptPwd) {
            if (!isSuccess) {
                [hud hiden];
                [HDUtility mbSay:sMessage];
                return ;
            }
            NSString *str       = FORMAT(@"%@%@_jj&", sPwd, user.sHumanNo);
            NSString *cryPwd    = [LDCry getMd5_32Bit_String:str];
            [HDLoginHelper loginEaseMobe:user.sHumanNo pwd:cryPwd block:^(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:error.description];
                    return ;
                }
                user.sAccount       = sAccount;
                user.sPwd           = sPwd;
                [[NSUserDefaults standardUserDefaults] setObject:sAccount    forKey:LOGIN_USER];
                [[NSUserDefaults standardUserDefaults] setObject:sPwd        forKey:LOGIN_PWD];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [HDGlobalInfo instance].userInfo    = user;
                [HDGlobalInfo instance].hasLogined  = YES;
                [HDGlobalInfo instance].emUserInfo  = emUser;
                [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
            }];
        }];
        return;
    }
}
//在状态栏显示 一些Log
+ (void)showStatusWithText:(NSString *)string duration:(NSTimeInterval)duration {
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    delegate.statusLabel.text = string;
    [delegate.statusLabel sizeToFit];
    CGRect rect = [UIApplication sharedApplication].statusBarFrame;
    CGFloat width = delegate.statusLabel.frame.size.width;
    CGFloat height = rect.size.height;
    rect.origin.x = rect.size.width - width - 5;
    rect.size.width = width;
    delegate.statusWindow.frame = rect;
    delegate.statusLabel.frame = CGRectMake(0, 0, width, height);
    if (duration < 1.0) {
        duration = 1.0;
    }
    if (duration > 4.0) {
        duration = 4.0;
    }
    [delegate performSelector:@selector(dismissStatus) withObject:nil afterDelay:duration];
}

//干掉状态栏文字
- (void)dismissStatus {
    CGRect rect = self.statusWindow.frame;
    rect.origin.y -= rect.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.statusWindow.frame = rect;
    }];
}

- (void)go2Login:(NSNotification *)noti{
    UIViewController *ctr = self.window.rootViewController;
    [ctr presentViewController:[[UINavigationController alloc] initWithRootViewController:[HDLoginViewCtr new]] animated:YES completion:nil];
}
- (void)doPreviewBlogImage:(NSNotification *)noti{
    HDPreviewImageCtr *ctr = nil;
    if ([noti.object isKindOfClass:[UIImage class]]) {
        UIImage *image = noti.object;
        ctr = [[HDPreviewImageCtr alloc] initWithImage:image];
    }else if([noti.object isKindOfClass:[NSString class]]){
        NSString *sUrl = noti.object;
        ctr = [[HDPreviewImageCtr alloc] initWithUrl:sUrl];
    }
    ctr.view.frame = CGRectMake(0, 0, 20, 20);
    [self.window.rootViewController.view addSubview:ctr.view];
    [self.window.rootViewController addChildViewController:ctr];
    [UIView animateWithDuration:0.2 animations:^{
        ctr.view.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height);
    }];
}
- (void)setNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doPreviewBlogImage:) name:HD_NOTIFICATION_KEY_PREVIEW_BLOG_IMAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(go2Login:) name:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharePosition:) name:HD_NOTIFICATION_KEY_SHARE_POSITION object:nil];
}

- (void)setNavigationBarAndTabBarAppearence{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBack"] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:dic];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: HDCOLOR_RED}
                                             forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:HDCOLOR_RED];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
}

- (void)sharePosition:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    HDShareViewCtr *ctr = nil;
    if ([dic[@"key"] isEqualToString:@"talent"]) {
        HDTalentInfo *info = noti.object;
        ctr = [[HDShareViewCtr alloc] initWithTalent:info];
    }else{
        WJPositionInfo *info = noti.object;
        ctr = [[HDShareViewCtr alloc] initWithPosition:info];
    }
    [self.window.rootViewController addChildViewController:ctr];
    ctr.view.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height);
    [self.window.rootViewController.view addSubview:ctr.view];
}

#pragma mark 添加本地通知
-(void)addLocalNotification:(NSString *)content count:(NSUInteger)count{
    UILocalNotification *notification   = [[UILocalNotification alloc]init];
    notification.alertBody              = content;
    notification.applicationIconBadgeNumber = count;
    notification.alertAction            = @"打开应用";
    notification.alertLaunchImage       = @"backglound";
    notification.soundName              = @"msg.caf";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark 移除本地通知，在不需要此通知时记得移除
-(void)removeNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end