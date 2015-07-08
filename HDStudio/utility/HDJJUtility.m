//
//  HDJJUtility.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDJJUtility.h"
#import "HDInstance.h"
#import "UMSocial.h"
#import "HDNewsViewCtr.h"
#import "HDMeViewCtr.h"
#import "HDPlusViewCtr.h"
#import "HDBlogViewCtr.h"
#import "HDDiscoverCtr.h"
#import "HDIntroduceViewCtr.h"
#import "BaseFunc.h"
#import "LDCry.h"
#import "EaseMob.h"
#import "HDEmUserInfo.h"
#import "HDPlusViewCtr.h"

@implementation HDJJUtility

+ (void)jjSay:(NSString *)message delegate:(id)object{
    
    [HDUtility say:message Delegate:object];
}
+ (void)umshareUrl:(NSString *)url title:(NSString *)title image:(UIImage *)image target:(id)target{
    if (url.length == 0 || title.length == 0 || !image || !target) {
        Dlog(@"传入参数错误");
        return;
    }
    [UMSocialData defaultData].extConfig.wechatSessionData.url      = url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url     = url;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.url     = url;
    [UMSocialData defaultData].extConfig.qqData.url                 = url;
    [UMSocialData defaultData].extConfig.qzoneData.url              = url;
    
    [UMSocialData defaultData].extConfig.wechatSessionData.title    = title;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title   = title;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.title   = title;
    [UMSocialData defaultData].extConfig.qqData.title               = title;
    [UMSocialData defaultData].extConfig.qzoneData.title            = title;
    NSString *sharedText = FORMAT(@"%@ %@", LS(@"TXT_SHARE_CONTENT"), url);
    [UMSocialSnsService presentSnsIconSheetView:target
                                         appKey:@UmengAppkey
                                      shareText:sharedText
                                     shareImage:image
                                shareToSnsNames:[NSArray arrayWithObjects:
                                                 UMShareToEmail,
                                                 UMShareToSms,
                                                 UMShareToWechatTimeline,
                                                 UMShareToWechatSession,
                                                 UMShareToWechatFavorite,
                                                 UMShareToSina,
                                                 UMShareToQQ,
                                                 UMShareToQzone,
                                                 nil]
                                       delegate:nil];
}

+ (UIImage *)image:(NSString *)url{
    if (url.length == 0) {
        return nil;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT];
    NSString *sPath = dic[url];
    if (sPath.length > 0) {
        UIImage *img = [UIImage imageWithContentsOfFile:FORMAT(@"%@/%@", HDDocumentPath, sPath)];
        if (img) {
            return img;
        }
    }
    [NSThread detachNewThreadSelector:@selector(httpGetImage:) toTarget:self withObject:url];
    return nil;
}

- (void)httpGetImage:(NSString *)url{
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSString *sPath = [HDUtility saveImage:image imageName:FORMAT(@"img%d.png", arc4random()) folder:@"imgs"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT]];
        sPath = [sPath substringFromIndex:HDDocumentPath.length];
        [dic setValue:sPath forKey:url];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:IMAGE_DOCUMENT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        Dlog(@"图片下载成功URL：%@", url);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        Dlog(@"图片下载失败URL：%@", url);
    }];
    [o start];
}
- (void)getImage:(NSString *)url withBlock:(void(^)(NSString *code, NSString *message, UIImage *img))block{

    if (url.length == 0) {
        block(@"1", @"默认图片", HDIMAGE(@"icon_headFalse"));
        return;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT];
    NSString *sPath = dic[url];
    if (sPath.length > 0) {
        UIImage *img = [UIImage imageWithContentsOfFile:FORMAT(@"%@/%@", HDDocumentPath, sPath)];
        if (img) {
            block(@"0", @"存储在本地的图片", img);
        }else{
            block(@"1", @"默认图片", HDIMAGE(@"icon_headFalse"));
        }
        return;
    }
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSString *sPath = [HDUtility saveImage:image imageName:FORMAT(@"img%d.png", arc4random()) folder:@"imgs"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT]];
        sPath = [sPath substringFromIndex:HDDocumentPath.length];
        [dic setValue:sPath forKey:url];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:IMAGE_DOCUMENT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        block(@"0", @"下载成功", image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        Dlog(@"fales");
        block(@"-1", @"下载失败，返回默认失败图片", HDIMAGE(@"falseImage"));
    }];
    [o start];
}

+ (void)getImage:(NSString *)url withBlock:(void(^)(NSString *code, NSString *message, UIImage *img))block{
    HDJJUtility *utility = [self new];
    @synchronized(utility){
        [utility getImage:url withBlock:block];
    }
}

+ (NSDate *)dateWithTimeIntervalSiceChristionEra:(NSTimeInterval)secs{
    CGFloat t   = (CGFloat)(((1969 * 365 + (25 * 20 - 9) - 19 + 5) * 24) + 8) * 60 * 60 * 1000;
    CGFloat d   = secs/10000 - t;
    Dlog(@"[info.sCreateTime floatValue] = %f, t = %f, d = %f", secs, t, d);
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:d/1000];
    return date;
}

+ (BOOL)isNull:(id)object{
    NSString *s = FORMAT(@"%@", object);
    BOOL isNull1 = [s isEqualToString:@"<null>"] || [s isEqualToString:@"(null)"] || [s isEqualToString:@"null"];
    BOOL isNull2 = [s isEqualToString:@"<NULL>"] || [s isEqualToString:@"(NULL)"] || [s isEqualToString:@"NULL"];
    return isNull1 || isNull2;
}

+ (UITabBarController *)structTheBuilding{
    UITabBarController *tab = [[UITabBarController alloc] init];
    HDBlogViewCtr       *blogCtr            = [[HDBlogViewCtr       alloc] init];
    HDDiscoverCtr       *discoverCtr        = [[HDDiscoverCtr       alloc] init];
    HDMeViewCtr         *meCtr              = [[HDMeViewCtr         alloc] init];
    HDNewsViewCtr       *newsCtr            = [[HDNewsViewCtr       alloc] init];
    HDPlusViewCtr       *plus               = [[HDPlusViewCtr       alloc] init];
    UINavigationController  *nav_blog       = [[UINavigationController   alloc] initWithRootViewController:blogCtr];
    UINavigationController  *nav_discover   = [[UINavigationController   alloc] initWithRootViewController:discoverCtr];
    UINavigationController  *nav_news       = [[UINavigationController   alloc] initWithRootViewController:newsCtr];
    UINavigationController  *nav_me         = [[UINavigationController   alloc] initWithRootViewController:meCtr];
    UINavigationController  *nav_plus       = [[UINavigationController   alloc] initWithRootViewController:plus];
    nav_blog.tabBarItem      = [[UITabBarItem alloc] initWithTitle:@"荐友圈"
                                                             image:HDIMAGE(@"tab_jianyouquan")
                                                     selectedImage:HDIMAGE(@"tab_jianyouquanHi")];
    nav_discover.tabBarItem  = [[UITabBarItem alloc] initWithTitle:@"发现"
                                                             image:HDIMAGE(@"tab_discover")
                                                     selectedImage:HDIMAGE(@"tab_discoverHi")];
    nav_me.tabBarItem        = [[UITabBarItem alloc] initWithTitle:@"我"
                                                             image:HDIMAGE(@"tab_me")
                                                     selectedImage:HDIMAGE(@"tab_meHi")];
    nav_news.tabBarItem      = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                             image:HDIMAGE(@"tab_chat")
                                                     selectedImage:HDIMAGE(@"tab_chatHi")];
    nav_plus.tabBarItem          = [[UITabBarItem alloc] initWithTitle:@""
                                                             image:[HDIMAGE(@"tab_plus") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[HDIMAGE(@"tab_plus") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav_plus.tabBarItem.imageInsets  = UIEdgeInsetsMake(7, 0, -7, 0);
    [tab setViewControllers:@[nav_blog, nav_discover, nav_plus, nav_news, nav_me]];
    return tab;
}

+ (HDAddressInfo *)getGlobalVariableFromLocalPlist{
    HDAddressInfo *address      = [HDAddressInfo new];
    NSMutableDictionary *dic    = MDIC_PLIST;
    address.sClientDownload     = dic[@"sClientDownload"];
    address.sDataVersion        = dic[@"sDataVersion"];
    address.sWebsite_waproot    = dic[@"sWebsite_waproot"];
    address.sWebsite_webroot    = dic[@"sWebsite_webroot"];
    address.sWebsite_approot    = dic[@"sWebsite_approot"];
    address.sCloudsite_webroot  = dic[@"sCloudsite_webroot"];
    address.sLogo_shop          = dic[@"sLogo_shop"];
    address.sLogo_position      = dic[@"sLogo_position"];
    address.sLogo_app           = dic[@"sLogo_app"];
    return address;
}

- (void)stopHttp{
    if (_op_parameter) {
        [_op_parameter cancel];
        _op_parameter = nil;
    }
    if (_op_veriable) {
        [_op_veriable cancel];
        _op_veriable = nil;
    }
}
- (void)httpGetGlobalVariable:(void(^)(BOOL isSuc))block{
    _op_veriable = [[HDHttpUtility sharedClient] getGlobalVariable:^(BOOL isSuccess, HDAddressInfo *info, NSString *sCode, NSString *sMessage) {
        NSMutableArray *mar_reward          = [HDJJUtility transformValueInfoFromJson:MAR_PLIST_REWARD];
        [HDGlobalInfo instance].mar_reward  = mar_reward;
        if (!isSuccess) {
            [_hud hiden];
            [HDUtility mbSay:sMessage];
            [HDGlobalInfo instance].addressInfo     = [HDJJUtility getGlobalVariableFromLocalPlist];
            [HDGlobalInfo instance].mar_feedback    = MAR_PLIST_FEEDBACK;
            [HDGlobalInfo instance].mar_area        = [HDJJUtility transformAreaInfoFromJson:MAR_PLIST_EARA];
            [HDGlobalInfo instance].mar_trade       = [HDJJUtility transformValueInfoFromJson:MAR_PLIST_TRADE];
            [HDGlobalInfo instance].mar_post        = [HDJJUtility transformPostInfoFromJson:MAR_PLIST_POST];
            [HDGlobalInfo instance].mar_workExp     = [HDJJUtility transformValueInfoFromJson:MAR_PLIST_WORKEXP];
            [HDGlobalInfo instance].mar_salary      = [HDJJUtility transformValueInfoFromJson:MAR_PLIST_SALARY];
            [HDGlobalInfo instance].mar_education   = [HDJJUtility transformValueInfoFromJson:MAR_PLIST_EDUCATION];
            [HDGlobalInfo instance].mar_property    = [HDJJUtility transformAreaInfoFromJson:MAR_PLIST_PROPERTY];
            [HDGlobalInfo instance].mar_bank        = [HDJJUtility transformAreaInfoFromJson:MAR_PLIST_BANK];
            block(NO);
            return ;
        }
        [HDGlobalInfo instance].addressInfo = info;
        [self httpGetGlobalParameters:block];
    }];
}
- (void)httpGetGlobalParameters:(void(^)(BOOL isSuc))block{
    _op_parameter = [[HDHttpUtility sharedClient] getGlobalParameters:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(NO);
            return ;
        }
        block(YES);
    }];
}

+ (NSString *)getTrade:(NSString *)tradCode{
    NSMutableArray *mar = [HDGlobalInfo instance].mar_trade;
    if (mar.count == 0) {
        [[HDJJUtility new] httpGetGlobalParameters:^(BOOL isSuc) {
            
        }];
    }
    return nil;
}

+ (NSMutableArray *)transformAreaInfoFromJson:(NSArray *)ar_area{
    if (ar_area.count == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar_area.count; i++) {
        NSDictionary *d = ar_area[i];
        NSArray *ar_items = [NSArray new];
        if (!d[@"Items"] || [d[@"Items"] isKindOfClass:[NSNull class]]) {
            continue;
        }
        ar_items = d[@"Items"];
        if (d.count == 0 || !ar_items) {
            continue;
        }
        HDAreaInfo  *area   = [HDAreaInfo new];
        area.sCodeID        = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"CodeID"]]?    @"": d[@"CodeID"]);
        area.sKey           = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Key"]]?       @"": d[@"Key"]);
        area.sValue         = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Value"]]?     @"": d[@"Value"]);
        for (int i = 0; i < ar_items.count; i++) {
            NSDictionary *d_item = ar_items[i];
            if (d_item.count == 0) {
                continue;
            }
            HDAreaItem *item    = [HDAreaItem new];
            item.sValue         = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"Value"]]?     @"": d_item[@"Value"]);
            item.sKey           = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"Key"]]?       @"": d_item[@"Key"]);
            item.sCodeID        = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"CodeID"]]?    @"": d_item[@"CodeID"]);
            item.sParentID      = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"ParentID"]]?  @"": d_item[@"ParentID"]);
            [area.mar_items addObject:item];
        }
        [mar addObject:area];
    }
    return mar;
}

+ (NSMutableArray *)transformValueInfoFromJson:(NSArray *)ar_values{
    if (ar_values.count == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar_values.count; i++) {
        NSDictionary *d = ar_values[i];
        if ([d[@"Value"] isEqualToString:@"不限"]) {
            continue;
        }
        HDValueItem *info = [HDValueItem new];
        info.sCodeID    = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"CodeID"]]?     @"": d[@"CodeID"]);
        info.sKey       = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Key"]]?        @"": d[@"Key"]);
        info.sValue     = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Value"]]?      @"": d[@"Value"]);
        [mar addObject:info];
    }
    return mar;
}

+ (NSMutableArray *)transformPostInfoFromJson:(NSArray *)ar_post{
    if (ar_post.count == 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar_post.count; i++) {
        NSDictionary *d = ar_post[i];
        if (!d[@"Items"] || [d[@"Items"] isKindOfClass:[NSNull class]]) {
            continue;
        }
        HDPostInfo *info    = [HDPostInfo new];
        info.sCodeID        = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"CodeID"]]?     @"": d[@"CodeID"]);
        info.sKey           = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Key"]]?        @"": d[@"Key"]);
        info.sValue         = FORMAT(@"%@", [[HDHttpUtility new] isNull:d[@"Value"]]?      @"": d[@"Value"]);
        NSArray *ar_items   = d[@"Items"];
        for (int i = 0; i < ar_items.count; i++) {
            NSDictionary *d_item = ar_items[i];
            if (d_item.count == 0) {
                continue;
            }
            HDPostItem *item    = [HDPostItem new];
            item.sValue         = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"Value"]]?     @"": d_item[@"Value"]);
            item.sKey           = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"Key"]]?       @"": d_item[@"Key"]);
            item.sCodeID        = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"CodeID"]]?    @"": d_item[@"CodeID"]);
            item.sParentID      = FORMAT(@"%@", [[HDHttpUtility new] isNull:d_item[@"ParentID"]]?  @"": d_item[@"ParentID"]);
            [info.mar_items addObject:item];
        }
        [mar addObject:info];
    }
    return mar;
}

//价格分割
+ (NSString *)countNumAndChangeformat:(NSString *)num{
    if (num == nil){
        return @"";
    }
    int count = 0;
    long long int a = num.longLongValue;
    while (a != 0)    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:num];
    NSMutableString *newstring = [NSMutableString string];
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

//自适应宽度
+ (CGFloat)withOfString:(NSString*)str font:(UIFont *)font widthMax:(NSInteger)widthMax{
    if (str.length == 0) {
        Dlog(@"警告:传入参数str为空字符串");
        return 10;
    }
    if (!font) {
        font = [UIFont systemFontOfSize:14];
    }
    CGSize size = [str boundingRectWithSize:CGSizeMake(40000, 21.)
                    options:NSStringDrawingUsesLineFragmentOrigin
                 attributes:@{NSFontAttributeName: font}
                    context:nil].size;
    return MIN(size.width+1, widthMax);
}

+ (CGFloat)heightOfString:(NSString *)str font:(UIFont *)font width:(int)w maxHeight:(int)height{
    if (str.length == 0 || w <= 0 || height < 20) {
        Dlog(@"警告:传入参数有误");
        return 55;
    }
    if (!font) {
        font = [UIFont systemFontOfSize:17];
    }
    CGSize size = [str boundingRectWithSize:CGSizeMake(w, 99999999)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName: font}
                                    context:nil].size;
    CGFloat h = MAX(size.height, 55);
    return MIN(h, height);
}

//截取html标签里的内容，他们都是<>开头内容
+ (NSString *)flattenHTML:(NSString *)html string:(NSString *)str{
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:str];
    }
    return html;
}

+ (void)umsharePosition:(WJPositionInfo *)positionInfo withType:(NSString *)type image:(UIImage *)image shareText:(NSString *)shareTxt delegate:(id)object{
    if (!image || !object) {
        Dlog(@"Error:传入参数错误");
        return;
    }
    [UMSocialData defaultData].extConfig.wechatSessionData.url  = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.url = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.qqData.url             = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.qzoneData.url          = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.yxsessionData.url      = positionInfo.sUrl;
    [UMSocialData defaultData].extConfig.yxtimelineData.url     = positionInfo.sUrl;
    
    [UMSocialData defaultData].extConfig.wechatSessionData.title    = positionInfo.sPositionName;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title   = positionInfo.sPositionName;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.title   = positionInfo.sPositionName;
    [UMSocialData defaultData].extConfig.qqData.title               = positionInfo.sPositionName;
    [UMSocialData defaultData].extConfig.qzoneData.title            = positionInfo.sPositionName;
    [[UMSocialControllerService defaultControllerService] setShareText:shareTxt shareImage:image socialUIDelegate:object];        //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:type].snsClickHandler(object, [UMSocialControllerService defaultControllerService], YES);
}

+ (NSString*)timeConversion:(NSInteger)dateInteger{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:dateInteger];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
@end




