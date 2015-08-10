

//  SNHttpUtility.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-22.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "HDHttpUtility.h"
#import "Reachability.h"


@implementation HDHttpUtility

+ (HDHttpUtility *)sharedClient{
    Reachability *rech = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (rech.currentReachabilityStatus == NotReachable) {
        Dlog(@"当前百度拼不通");
    }
    static HDHttpUtility *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:IP]];
    });
    return _sharedClient;
}

+ (HDHttpUtility *)instanceWithUrl:(NSString *)url{
    Reachability *rech = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (rech.currentReachabilityStatus == NotReachable) {
        Dlog(@"当前百度拼不通");
    }
    static HDHttpUtility *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:url]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}

- (BOOL)isNull:(id)object{
    NSString *s = FORMAT(@"%@", object);
    BOOL isNull1 = [s isEqualToString:@"<null>"] || [s isEqualToString:@"(null)"] || [s isEqualToString:@"null"];
    BOOL isNull2 = [s isEqualToString:@"<NULL>"] || [s isEqualToString:@"(NULL)"] || [s isEqualToString:@"NULL"];
    return isNull1 || isNull2 || !object;
}

#pragma mark --模板(Act000)
- (AFHTTPRequestOperation *)f1111111:(HDUserInfo *)user position:(WJPositionInfo *)position completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !position) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act202" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act202 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act202 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark - 
#pragma mark --手机登录(Act102)
- (AFHTTPRequestOperation *)loginWithPhone:(NSString *)phone password:(NSString *)pwd CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage))block
{
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:phone               forKey:@"UserName"];
    [mdc_parameter setValue:pwd                 forKey:@"Password"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act102" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act102 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSDictionary    *dic        = nil;
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        HDUserInfo      *userInfo   = [HDUserInfo new];
        
        dic         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
        sErrDesc    = FORMAT(@"%@", [JSON objectForKey:@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, nil, (sErrDesc.length == 0? @"登录失败，请稍后再试": sErrDesc));
            return;
        }
        userInfo.sHumanNo        = FORMAT(@"%@", [self isNull:dic[@"UserID"]]?       @"": dic[@"UserID"]);
        userInfo.sName           = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?     @"": dic[@"NickName"]);
        userInfo.sMemberLevel   = FORMAT(@"%@", [self isNull:dic[@"Level"]]?        @"": dic[@"Level"]);
        userInfo.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?      @"": dic[@"Approve"]);
        userInfo.isPerfect      = [FORMAT(@"%@",[self isNull:dic[@"IsPerfect"]]?    @"0": dic[@"IsPerfect"]) boolValue];
        userInfo.sShopName      = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?     @"": dic[@"ShopName"]);
        userInfo.sAvatarUrl     = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?       @"": dic[@"Avatar"]);
        userInfo.sTocken        = FORMAT(@"%@", [self isNull:dic[@"Token"]]?        @"": dic[@"Token"]);
        userInfo.sAnnounce      = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?     @"": dic[@"Announce"]);
        userInfo.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?      @"": dic[@"Approve"]);
        userInfo.sBackground    = FORMAT(@"%@", [self isNull:dic[@"Background"]]?   @"": dic[@"Background"]);
        userInfo.sTradeKey      = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]? @"": dic[@"BusinessCode"]);
        userInfo.sQQ            = FORMAT(@"%@", [self isNull:dic[@"CODE_QQ"]]?      @"": dic[@"CODE_QQ"]);
        userInfo.sWeixin        = FORMAT(@"%@", [self isNull:dic[@"CODE_WX"]]?      @"": dic[@"CODE_WX"]);
        userInfo.sCurCompany    = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?   @"": dic[@"CurCompany"]);
        userInfo.sPostKey       = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]? @"": dic[@"FunctionCode"]);
        userInfo.sCurPosition   = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?  @"": dic[@"CurPosition"]);
        userInfo.sHXResStatus   = FORMAT(@"%@", [self isNull:dic[@"HXResStatus"]]?  @"": dic[@"HXResStatus"]);
        userInfo.sPhone         = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?       phone: dic[@"MPhone"]);
        userInfo.sStartWorkDT   = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?  @"": dic[@"StartWorkDT"]);
        userInfo.sAreaKey       = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceCode"]]?@"": dic[@"WorkPlaceCode"]);
        userInfo.sWorkYears     = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?    @"": dic[@"WorkYears"]);
        userInfo.sRoleType      = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?     @"": dic[@"RoleType"]);
        userInfo.sAuthenCompany = FORMAT(@"%@", [self isNull:dic[@"AuthenCompany"]]?@"": dic[@"AuthenCompany"]);
        userInfo.sAuthenPosition= FORMAT(@"%@", [self isNull:dic[@"AuthenPosition"]]?@"": dic[@"AuthenPosition"]);
        userInfo.isFocus        = FORMAT(@"%@", [self isNull:dic[@"IsFocus"]]?      @"": dic[@"IsFocus"]).boolValue;
        userInfo.sStartWorkDT   = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?  @"": dic[@"StartWorkDT"]);
        userInfo.sTocken1       = FORMAT(@"%@", [self isNull:dic[@"Token1"]]?       @"": dic[@"Token1"]);
        
        block(YES, sCode, userInfo, @"登录成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, nil, @"请求数据失败，请检查网络！");
    }];
    return op;
}
#pragma mark --修改密码(Act106)
- (AFHTTPRequestOperation *)changePassword:(HDUserInfo *)user old:(NSString *)old new:(NSString *)new completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || old.length == 0 || new.length == 0) {
        block(NO, nil, @"传入参数有误------");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:old                 forKey:@"OldPassword"];
    [mdc_parameter setValue:new                 forKey:@"newPassword"];
    AFHTTPRequestOperation *op = [self getServer:@"Act106" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act106 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act106 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"修改成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取随机秘钥(Act107)
- (AFHTTPRequestOperation *)getRandomKey:(void (^)(BOOL isSuccess, NSString *key, NSString *code, NSString *message))block
{
    AFHTTPRequestOperation *op = [self getServer:@"Act107" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act107 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act107 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString    *sResult    = nil;
        NSString    *sCode      = nil;
        if(JSON != [NSNull class]){
            NSDictionary *dic   = [JSON objectForKey:@"Result"];
            sResult             = FORMAT(@"%@", dic[@"Seed"]);
            sCode               = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
            if ([sResult length] == 0 || ![sCode isEqualToString:@"0"]) {
                block(NO, nil, nil, @"请求秘钥失败，请稍后再试");
                return;
            }
        }
        block(YES, sResult, sCode, @"请求秘钥成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, nil, @"请求秘钥失败，请检查网络！");
    }];
    return op;
}

#pragma mark --发送验证码(Act109)
- (AFHTTPRequestOperation *)sendMessage:(NSString *)phone isReg:(NSString *)isReg CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (![HDUtility isValidateMobile:phone]) {
        block(NO, nil, @"输入手机号码不正确");
        Dlog(@"输入手机号码不正确");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:FORMAT(@"%@", phone)    forKey:@"Mobile"];
    [mdc_parameter setValue:@"true"                 forKey:@"UnValid"];
   // [mdc_parameter setValue:unValid                 forKey:@"UnValid"];
    [mdc_parameter setValue:isReg                forKey:@"IsReg"];
    [mdc_parameter setValue:@"1"                    forKey:@"times"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act109" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act109 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：Act109 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, nil, (sErrDesc.length == 0? @"登录失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"请求发送验证码成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取用户个人资料信息(Act114)
- (AFHTTPRequestOperation *)getProfileInformation:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDUserInfo *user))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act114" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act114 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act114 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        HDUserInfo *userInfo    = [HDUserInfo new];
        HDUserInfo *u           = [HDGlobalInfo instance].userInfo;
        userInfo.sHumanNo       = FORMAT(@"%@", [self isNull:dic[@"UserID"]]?       @"": dic[@"UserID"]);
        userInfo.sName          = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?     @"": dic[@"NickName"]);
        userInfo.sMemberLevel   = FORMAT(@"%@", [self isNull:dic[@"Level"]]?        @"": dic[@"Level"]);
        userInfo.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?      @"": dic[@"Approve"]);
        userInfo.isPerfect      = [FORMAT(@"%@",[self isNull:dic[@"IsPerfect"]]?    @"0": dic[@"IsPerfect"]) boolValue];
        userInfo.sShopName      = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?     @"": dic[@"ShopName"]);
        userInfo.sAvatarUrl     = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?       @"": dic[@"Avatar"]);
        userInfo.sTocken        = FORMAT(@"%@", [self isNull:dic[@"Token"]]?        @"": dic[@"Token"]);
        userInfo.sAnnounce      = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?     @"": dic[@"Announce"]);
        userInfo.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?      @"": dic[@"Approve"]);
        userInfo.sBackground    = FORMAT(@"%@", [self isNull:dic[@"Background"]]?   @"": dic[@"Background"]);
        userInfo.sTradeKey      = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]? @"": dic[@"BusinessCode"]);
        userInfo.sQQ            = FORMAT(@"%@", [self isNull:dic[@"CODE_QQ"]]?      @"": dic[@"CODE_QQ"]);
        userInfo.sWeixin        = FORMAT(@"%@", [self isNull:dic[@"CODE_WX"]]?      @"": dic[@"CODE_WX"]);
        userInfo.sCurCompany    = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?   @"": dic[@"CurCompany"]);
        userInfo.sPostKey       = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]? @"": dic[@"FunctionCode"]);
        userInfo.sCurPosition   = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?  @"": dic[@"CurPosition"]);
        userInfo.sHXResStatus   = FORMAT(@"%@", [self isNull:dic[@"HXResStatus"]]?  @"": dic[@"HXResStatus"]);
        userInfo.sPhone         = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?       u.sPhone: dic[@"MPhone"]);
        userInfo.sStartWorkDT   = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?  @"": dic[@"StartWorkDT"]);
        userInfo.sAreaKey       = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceCode"]]?@"": dic[@"WorkPlaceCode"]);
        userInfo.sWorkYears     = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?    @"": dic[@"WorkYears"]);
        block(YES, sCode, @"更新成功", userInfo);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --上传头像(Act115)
- (AFHTTPRequestOperation *)uploadLogo:(HDUserInfo *)user flag:(NSString *)flag avatar:(UIImage *)avata completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [flag intValue] > 4 || [flag intValue] < 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:flag                forKey:@"avatarCode"];
    
    NSMutableURLRequest *request =[self multipartFormRequestWithMethod:@"post" path:@"Act115" parameters:mdc_parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *data          = UIImagePNGRepresentation(avata);
        NSString *fileName    = FORMAT(@"%d.png", arc4random());
        [formData appendPartWithFileData:data name:@"Photo" fileName:fileName mimeType:@"image/png"];
    }];
    AFHTTPRequestOperation *opration = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act115 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act115 dic = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试" , nil);
            return;
        }
        NSString *sCode         = FORMAT(@"%@", !JSON[@"Code"]?         @"":        JSON[@"Code"]);
        NSString *sResult       = FORMAT(@"%@", !JSON[@"Result"]?       @"":        JSON[@"Result"]);
        NSString *Description   = FORMAT(@"%@", !JSON[@"Description"]?  @"上传失败": JSON[@"Description"]);
        if ([sCode isEqualToString:@"0"]) {
            block(YES, sCode, @"上传成功", sResult);
            return;
        }else{
            block(NO, sCode, Description, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"网络请求失败->%@", error);
        block(NO, FORMAT(@"%d", (int)error.code), @"网络请求失败", nil);
    }];
    
    [opration start];
    return opration;
}
#pragma mark --手机注册(Act122)
- (AFHTTPRequestOperation *)registerWithPhone:(NSString *)phone nickname:(NSString *)name password:(NSString *)pwd code:(NSString *)code CompletionBlock:(void (^)(BOOL, NSString *, HDUserInfo *, NSString *))block
{
    if (![HDUtility isValidateMobile:phone] || code.length == 0 || ![HDUtility isValidatePassword:pwd] || name.length == 0 ) {
        Dlog(@"传入参数有误");
        block(NO, nil, nil, @"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:[HDUtility uuid]        forKey:@"IMEI"];
    [mdc_parameter setValue:name                    forKey:@"NickName"];
    [mdc_parameter setValue:pwd                     forKey:@"Password"];
    [mdc_parameter setValue:FORMAT(@"%@", phone)    forKey:@"Mobile"];
    [mdc_parameter setValue:code                    forKey:@"validCode"];

    AFHTTPRequestOperation *op = [self getServer:@"Act122" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act122 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act122 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSDictionary    *dic        = nil;
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        HDUserInfo      *userInfo   = [HDUserInfo new];
        if(JSON != [NSNull class]){
            dic         = [JSON objectForKey:@"Result"];
            sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
            sErrDesc    = FORMAT(@"%@", [JSON objectForKey:@"ErrorDesc"]);
            if (![sCode isEqualToString:@"0"]) {
                block(NO, sCode, userInfo, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
                return;
            }
            userInfo.sHumanNo        = FORMAT(@"%@", (dic[@"UserID"]     == nil? @"": dic[@"UserID"]));
            userInfo.sName      = FORMAT(@"%@", dic[@"NickName"]    == nil? @"": dic[@"NickName"]);
            userInfo.sMemberLevel   = FORMAT(@"%@", (dic[@"Level"]      == nil? @"": dic[@"Level"]));
            userInfo.sApprove       = FORMAT(@"%@", (dic[@"Approve"]    == nil? @"": dic[@"Approve"]));
            userInfo.sShopName      = FORMAT(@"%@", (dic[@"ShopName"]   == nil? @"": dic[@"ShopName"]));
            userInfo.sTocken        = FORMAT(@"%@", (dic[@"Token"]      == nil? @"": dic[@"Token"]));
            userInfo.isPerfect      = [dic[@"IsPerfect"] boolValue];
        }
        block(YES, sCode, userInfo, @"注册成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, nil, @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --校验验证码(Act123)
- (AFHTTPRequestOperation *)verifyMessageCode:(NSString *)phone code:(NSString *)sCode CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (![HDUtility isValidateMobile:phone] || sCode.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:FORMAT(@"%@", phone)    forKey:@"Mobile"];
    [mdc_parameter setValue:sCode                   forKey:@"ValidCode"];

    AFHTTPRequestOperation *op = [self getServer:@"Act123" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act123 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act123 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString    *sResult    = nil;
        NSString    *sCode      = nil;
        NSString    *sErrDesc   = nil;
        sResult     = [JSON objectForKey:@"Result"];
        sErrDesc    = [JSON objectForKey:@"ErrorDesc"];
        sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"请求发送验证码成功，请查阅您的手机短信");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --用户预设信息（完善注册信息）(Act125)
- (AFHTTPRequestOperation *)presetUserInfo:(HDUserInfo *)user itemCodes:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !dic || dic.count < 4) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:dic[@"trade"]       forKey:@"businessCode"];
    [mdc_parameter setValue:dic[@"post"]        forKey:@"functionCode"];
    [mdc_parameter setValue:dic[@"area"]        forKey:@"workPlaceCode"];
    [mdc_parameter setValue:dic[@"workExp"]     forKey:@"startWorkDT"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act125" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act125 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act125 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", (!JSON[@"Code"]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", (!JSON[@"ErrorDesc"]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --修改个人信息(Act127)
- (AFHTTPRequestOperation *)modifyProfile:(HDUserInfo *)user modifyUser:(HDUserInfo *)u completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !u) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:u.sName             forKey:@"nickname"];
    [mdc_parameter setValue:u.sShopMPhone       forKey:@"mobile"];
    [mdc_parameter setValue:u.sWeixin           forKey:@"wxusername"];
    [mdc_parameter setValue:u.sQQ               forKey:@"qq"];
    [mdc_parameter setValue:u.sPostKey          forKey:@"functionCode"];
    [mdc_parameter setValue:u.sAreaKey          forKey:@"workPlaceCode"];
    [mdc_parameter setValue:u.sStartWorkDT      forKey:@"startWorkDT"];
    [mdc_parameter setValue:u.sTradeKey         forKey:@"businessCode"];
    [mdc_parameter setValue:u.sCurCompany       forKey:@"curcompany"];
    [mdc_parameter setValue:u.sCurPosition      forKey:@"curposition"];
    [mdc_parameter setValue:u.sAnnounce         forKey:@"Announce"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act127" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act127 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act127 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取我的联系人列表(Act133)
- (AFHTTPRequestOperation *)getMyContactList:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *lists))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act133" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act133 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act133 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSArray         *ar         = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !ar) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        NSMutableArray *mar_list = [[NSMutableArray alloc] init];
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *dic   = ar[i];
            HDHumanInfo *info   = [HDHumanInfo new];
            info.sAvatarUrl     = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?   @"": dic[@"Avatar"]);
            info.sPhone         = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?   @"": dic[@"MPhone"]);
            info.sName          = FORMAT(@"%@", [self isNull:dic[@"NickName"]]? @"": dic[@"NickName"]);
            info.sHumanNo       = FORMAT(@"%@", [self isNull:dic[@"UserID"]]?   @"": dic[@"UserID"]);
            [mar_list addObject:info];
        }
        block(YES, sCode, @"更新成功", mar_list);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}
#pragma mark --获取我的荐荐信息（me主页）(Act135)
- (AFHTTPRequestOperation *)getMyJianJianInfomation:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDMyJianJianInfo *info))block
{
    if (user.sHumanNo.length == 0 || user.sTocken.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"userno"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"userID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act135" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act135 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act135 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        HDMyJianJianInfo *info  = [HDMyJianJianInfo new];
        info.sBuyCount          = FORMAT(@"%@", [self isNull:dic[@"BuyCount"]]?         @"": dic[@"BuyCount"]);
        info.sCBlogCount        = FORMAT(@"%@", [self isNull:dic[@"CBlogCount"]]?       @"": dic[@"CBlogCount"]);
        info.sCPersonalCount    = FORMAT(@"%@", [self isNull:dic[@"CPersonalCount"]]?   @"": dic[@"CPersonalCount"]);
        info.sCPositionCount    = FORMAT(@"%@", [self isNull:dic[@"CPositionCount"]]?   @"": dic[@"CPositionCount"]);
        info.sDepositCount      = FORMAT(@"%@", [self isNull:dic[@"DepositCount"]]?     @"": dic[@"DepositCount"]);
        info.sFanCount          = FORMAT(@"%@", [self isNull:dic[@"FanCount"]]?         @"": dic[@"FanCount"]);
        info.sFocusCount        = FORMAT(@"%@", [self isNull:dic[@"FocusCount"]]?       @"": dic[@"FocusCount"]);
        info.sGGold             = FORMAT(@"%@", [self isNull:dic[@"GGold"]]?            @"": dic[@"GGold"]);
        info.sGold              = FORMAT(@"%@", [self isNull:dic[@"Gold"]]?             @"": dic[@"Gold"]);
        info.sGoldCount         = FORMAT(@"%@", [self isNull:dic[@"GoldCount"]]?        @"": dic[@"GoldCount"]);
        info.sMemberLevel       = FORMAT(@"%@", [self isNull:dic[@"MemberLevel"]]?      @"": dic[@"MemberLevel"]);
        info.sPGold             = FORMAT(@"%@", [self isNull:dic[@"PGold"]]?            @"": dic[@"PGold"]);
        info.sPersonalCount     = FORMAT(@"%@", [self isNull:dic[@"PersonalCount"]]?    @"": dic[@"PersonalCount"]);
        info.sPositionCount     = FORMAT(@"%@", [self isNull:dic[@"PositionCount"]]?    @"": dic[@"PositionCount"]);
        info.sRGold             = FORMAT(@"%@", [self isNull:dic[@"RGold"]]?            @"": dic[@"RGold"]);
        info.sRecommendCount    = FORMAT(@"%@", [self isNull:dic[@"RecommendCount"]]?   @"": dic[@"RecommendCount"]);
        info.sRecruiterCount    = FORMAT(@"%@", [self isNull:dic[@"RecruiterCount"]]?   @"": dic[@"RecruiterCount"]);
        info.sSellCount         = FORMAT(@"%@", [self isNull:dic[@"SellCount"]]?        @"": dic[@"SellCount"]);
        info.sUserNo            = FORMAT(@"%@", [self isNull:dic[@"UserNo"]]?           @"": dic[@"UserNo"]);
        info.sVisitCount        = FORMAT(@"%@", [self isNull:dic[@"VisitCount"]]?       @"": dic[@"VisitCount"]);
        info.sXP                = FORMAT(@"%@", [self isNull:dic[@"XP"]]?               @"": dic[@"XP"]);
        block(YES, sCode, @"更新成功", info);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --申请认证(Act137)
- (AFHTTPRequestOperation *)askForApprove:(HDUserInfo *)user approveInfo:(NSDictionary *)dic_info completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !dic_info) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithDictionary:dic_info];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act137" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act202 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act202 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"提交成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取我的认证记录(Act138)
- (AFHTTPRequestOperation *)getMyApproveInformation:(HDUserInfo *)user pageIndex:(int)index size:(int)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *array))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act138" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act135 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act135 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        BOOL isLast = FORMAT(@"%@", [self isNull:dic[@"IsLastPage"]]? @"": dic[@"IsLastPage"]).boolValue;
        NSArray *ar = dic[@"List"];
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *d = ar[i];
            HDApproveInfo *info     = [HDApproveInfo new];
            info.sAutoId            = FORMAT(@"%@", [self isNull:d[@"AutoID"]]?         @"": d[@"AutoID"]);
            info.sCompanyName       = FORMAT(@"%@", [self isNull:d[@"CompanyName"]]?    @"": d[@"CompanyName"]);
            info.sCreatedDT         = FORMAT(@"%@", [self isNull:d[@"CreatedDT"]]?      @"": d[@"CreatedDT"]);
            info.sPosition          = FORMAT(@"%@", [self isNull:d[@"Position"]]?       @"": d[@"Position"]);
            info.sRealName          = FORMAT(@"%@", [self isNull:d[@"RealName"]]?       @"": d[@"RealName"]);
            info.sRemark            = FORMAT(@"%@", [self isNull:d[@"Remark"]]?         @"": d[@"Remark"]);
            info.sScene01           = FORMAT(@"%@", [self isNull:d[@"Scene01"]]?        @"": d[@"Scene01"]);
            info.approveStatus      = FORMAT(@"%@", [self isNull:d[@"Status"]]?         @"": d[@"Status "]).integerValue;
            info.approveType        = FORMAT(@"%@", [self isNull:d[@"TypeID"]]?         @"": d[@"TypeID"]).integerValue;
            info.sUserNo            = FORMAT(@"%@", [self isNull:d[@"UserNo"]]?         @"": d[@"UserNo"]);
            [mar addObject:info];
        }
        block(YES, sCode, @"更新成功", isLast, mar);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark --获取职位列表(Act201)
- (AFHTTPRequestOperation *)getPositionList:(HDUserInfo *)user pageIndex:(NSString *)index pageSize:(NSString *)size isOffShelve:(BOOL)isOff  CompletionBlock:(void (^)(BOOL isSuccess, BOOL isLastPage, NSArray *positons, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, NO, nil, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                    forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM                forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]        forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION                 forKey:@"Version"];
    [mdc_parameter setValue:@"0"                    forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo           forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken            forKey:@"Token"];
    [mdc_parameter setValue:index                   forKey:@"PageIndex"];
    [mdc_parameter setValue:size                    forKey:@"pageSize"];
    [mdc_parameter setValue:FORMAT(@"%d", isOff)    forKey:@"isOffline"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act201" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act201 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act201 json = %@" , JSON);
        if (!JSON) {
            block(NO, NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        NSMutableArray  *mar_positon    = [[NSMutableArray alloc] init];
        BOOL            isLastPage      = NO;
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, NO, nil, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        dic  = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"Positions"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"Positions"];
        }
        for (int i = 0; i < ar.count; i++) {
            WJPositionInfo *position    = [[WJPositionInfo alloc] init];
            if (![ar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }

            NSDictionary *dic_p  = ar[i];
            Dlog(@"dic = %@", dic_p);
            position.sPositionNo        = FORMAT(@"%@", ([self isNull:dic_p[@"PositionID"]]?    @"": dic_p[@"PositionID"]));
            position.sPositionName      = FORMAT(@"%@", ([self isNull:dic_p[@"PositionName"]]?  @"": dic_p[@"PositionName"]));
            position.sRemark            = FORMAT(@"%@", ([self isNull:dic_p[@"Remark"]]?        @"": dic_p[@"Remark"]));
            position.sArea              = FORMAT(@"%@", ([self isNull:dic_p[@"Area"]]?          @"": dic_p[@"Area"]));
            position.sAreaText          = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?      @"": dic_p[@"AreaText"]));
            position.sCompanyNo         = FORMAT(@"%@", ([self isNull:dic_p[@"EnterpriseID"]]?  @"": dic_p[@"EnterpriseID"]));
            position.sCompnayName       = FORMAT(@"%@", ([self isNull:dic_p[@"EnterpriseName"]]?@"": dic_p[@"EnterpriseName"]));
            
            position.sPublishTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?   @"": dic_p[@"PublishTime"]));
            position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionCode"]]?  @"": dic_p[@"FunctionCode"]));
            position.sFunctionText      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?  @"": dic_p[@"FunctionText"]));
            position.sEducationCode     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationCode"]]? @"": dic_p[@"EducationCode"]));
            position.sEducationText     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationText"]]? @"": dic_p[@"EducationText"]));
            position.sWorkExpCode       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpCode"]]?   @"": dic_p[@"WorkExpCode"]));
            position.sWorkExpText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpText"]]?   @"": dic_p[@"WorkExpText"]));
            position.sSalaryCode        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryCode"]]?    @"": dic_p[@"SalaryCode"]));
            position.sSalaryText        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryText"]]?    @"": dic_p[@"SalaryText"]));
            position.sProperty          = FORMAT(@"%@", ([self isNull:dic_p[@"Property"]]?      @"": dic_p[@"Property"]));
            position.sReward            = FORMAT(@"%@", ([self isNull:dic_p[@"Reward"]]?        @"": dic_p[@"Reward"]));
            position.sHit               = FORMAT(@"%@", ([self isNull:dic_p[@"Hit"]]?           @"": dic_p[@"Hit"]));
            position.sDelayDay          = FORMAT(@"%@", ([self isNull:dic_p[@"DelayDay"]]?      @"": dic_p[@"DelayDay"]));
            position.sUpCount           = FORMAT(@"%@", ([self isNull:dic_p[@"UpCount"]]?       @"": dic_p[@"UpCount"]));
            position.isCollect          = FORMAT(@"%@", ([self isNull:dic_p[@"IsCollected"]]?   @"": dic_p[@"IsCollected"])).boolValue;
            position.isBonus            = FORMAT(@"%@", ([self isNull:dic_p[@"IsBonus"]]?       @"": dic_p[@"IsBonus"])).boolValue;
            position.isDeposit          = FORMAT(@"%@", ([self isNull:dic_p[@"IsDeposit"]]?     @"": dic_p[@"IsDeposit"])).boolValue;
            position.sUrl       = FORMAT(@"%@Position/Detail?pos=%@", [HDGlobalInfo instance].addressInfo.sWebsite_waproot, position.sPositionNo);
            HDEmployerInfo *e   = [HDEmployerInfo new];
            e.sId           = FORMAT(@"%@",([self isNull:dic_p[@"EnterpriseID"]]?     @"": dic_p[@"EnterpriseID"]));
            e.sName         = FORMAT(@"%@",([self isNull:dic_p[@"EnterpriseName"]]?   @"": dic_p[@"EnterpriseName"]));
            e.sTradeCode    = FORMAT(@"%@",([self isNull:dic_p[@"BusinessCode"]]?     @"": dic_p[@"BusinessCode"]));
            e.sTradeText    = FORMAT(@"%@",([self isNull:dic_p[@"BusinessText"]]?     @"": dic_p[@"BusinessText"]));
            e.sPropertyCode = FORMAT(@"%@",([self isNull:dic_p[@"ComProperty"]]?      @"": dic_p[@"ComProperty"]));
            e.sPropertyText = FORMAT(@"%@",([self isNull:dic_p[@"ComPropertyText"]]?  @"": dic_p[@"ComPropertyText"]));
            e.sScene01      = FORMAT(@"%@",([self isNull:dic_p[@"Scene01"]]?          @"": dic_p[@"Scene01"]));
            e.sScene02      = FORMAT(@"%@",([self isNull:dic_p[@"Scene02"]]?          @"": dic_p[@"Scene02"]));
            e.sScene03      = FORMAT(@"%@",([self isNull:dic_p[@"Scene03"]]?          @"": dic_p[@"Scene03"]));
            e.sScene04      = FORMAT(@"%@",([self isNull:dic_p[@"Scene04"]]?          @"": dic_p[@"Scene04"]));
            e.sRemark       = FORMAT(@"%@",([self isNull:dic_p[@"ComDesc"]]?          @"": dic_p[@"ComDesc"]));
            if (e.sScene04.length > 0) {
                [e.mar_urls insertObject:e.sScene04 atIndex:0];
            }
            if (e.sScene03.length > 0) {
                [e.mar_urls insertObject:e.sScene03 atIndex:0];
            }
            if (e.sScene02.length > 0) {
                [e.mar_urls insertObject:e.sScene02 atIndex:0];
            }
            if (e.sScene01.length > 0) {
                [e.mar_urls insertObject:e.sScene01 atIndex:0];
            }
            position.employerInfo = e;
            position.sRemark = [position changeBr2n:position.sRemark];
            position.employerInfo.sRemark = [position changeBr2n:position.employerInfo.sRemark];
            [mar_positon addObject:position];
        }
        block(YES, isLastPage, mar_positon, sCode, @"获取职位列表成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, NO, nil, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --发布职位(Act202)
- (AFHTTPRequestOperation *)releasePosition:(HDUserInfo *)user opType:(int)type position:(WJPositionInfo *)p images:(NSArray *)ar CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *positionId))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !p || type < 0 || type > 3) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:@(type)                         forKey:@"operType"];
    [mdc_parameter setValue:p.employerInfo.sId              forKey:@"employerNo"];
    [mdc_parameter setValue:p.employerInfo.sName            forKey:@"employerName"];
    [mdc_parameter setValue:p.employerInfo.sTradeCode       forKey:@"employerTrade"];
    [mdc_parameter setValue:p.employerInfo.sPropertyCode    forKey:@"employerProperty"];
    [mdc_parameter setValue:p.employerInfo.sRemark          forKey:@"employerRemark"];
    [mdc_parameter setValue:p.sPositionName                 forKey:@"positionName"];
    [mdc_parameter setValue:p.sRemark                       forKey:@"positionRemark"];
    [mdc_parameter setValue:p.sArea                         forKey:@"positionWorkPlace"];
    [mdc_parameter setValue:p.sFunctionCode                 forKey:@"positionCategory"];
    [mdc_parameter setValue:p.sSalaryCode                   forKey:@"positionSalary"];
    [mdc_parameter setValue:p.sWorkExpCode                  forKey:@"positionWorkExp"];
    [mdc_parameter setValue:p.sEducationCode                forKey:@"positionEducation"];
    NSMutableURLRequest *request =[self multipartFormRequestWithMethod:@"POST" path:@"Act202" parameters:mdc_parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < ar.count; i++) {
            NSData *data           = UIImagePNGRepresentation(ar[i]);
            NSString *fileName     = [NSString stringWithFormat:@"%@.png", FORMAT(@"%d", arc4random())];
            [formData appendPartWithFileData:data name:@"Photo" fileName:fileName mimeType:@"image/png"];
        }
    }];
    AFHTTPRequestOperation *opration = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act202 Json= %@",    operation.responseString);
        Dlog(@"Act202 http = %@",   operation.response.URL);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!dic) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString *sCode         = FORMAT(@"%@", !dic[@"Code"]?          @"": dic[@"Code"]);
        NSString *sResult       = FORMAT(@"%@", !dic[@"Result"]?        @"": dic[@"Result"]);
        NSString *sErrorDesc    = FORMAT(@"%@", !dic[@"ErrorDesc"]?     @"": dic[@"ErrorDesc"]);
        NSString *sDescription  = FORMAT(@"%@", !dic[@"Description"]?   @"": dic[@"Description"]);
        if ([sCode isEqualToString:@"0"]) {
            block(YES, sCode, @"发布成功", sResult);
            return;
        }else{
            block(NO, sCode, sErrorDesc.length == 0? sDescription: sErrorDesc, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"网络请求失败->%@", error);
        block(NO, FORMAT(@"%d", (int)error.code), @"网络请求失败", nil);
    }];
    [opration start];
    return opration;
}

#pragma mark --修改职位(Act204)
- (AFHTTPRequestOperation *)modifyPosition:(HDUserInfo *)user position:(WJPositionInfo *)p completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !p) {
        Dlog(@"传入参数有误");
        block(NO, nil, @"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:p.sPositionNo           forKey:@"positionno"];
    [mdc_parameter setValue:p.sPositionName         forKey:@"positionname"];
    [mdc_parameter setValue:p.sRemark               forKey:@"remark"];
    [mdc_parameter setValue:p.employerInfo.sId              forKey:@"employerNo"];
    [mdc_parameter setValue:p.employerInfo.sName            forKey:@"employerName"];
    [mdc_parameter setValue:p.employerInfo.sTradeCode       forKey:@"employerTrade"];
    [mdc_parameter setValue:p.employerInfo.sPropertyCode    forKey:@"employerProperty"];
    [mdc_parameter setValue:p.employerInfo.sRemark          forKey:@"employerRemark"];
    [mdc_parameter setValue:p.sFunctionCode                 forKey:@"funtioncode"];
    [mdc_parameter setValue:p.sTradeKey                     forKey:@"businesscode"];
    [mdc_parameter setValue:p.sArea                         forKey:@"workplace"];
    [mdc_parameter setValue:p.sSalaryCode                   forKey:@"positionSalary"];
    [mdc_parameter setValue:p.sWorkExpCode                  forKey:@"positionWorkExp"];
    [mdc_parameter setValue:p.sEducationCode                forKey:@"positionEducation"];
    
    AFHTTPRequestOperation *op = [self postServer:@"Act204" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        dic         = [JSON objectForKey:@"Result"];
        Dlog(@"dic = %@", dic);
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"保存成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败,code:%d, url = %@", (int)operation.response.statusCode, operation.response.URL);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    
    return op;
}

#pragma mark --获取职位信息(Act205废弃－－－Act218开放)
- (AFHTTPRequestOperation *)getPositionInfo:(HDUserInfo *)user pid:(NSString *)pId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info))block
{
    if (pId.length == 0) {
        Dlog(@"传入参数有误");
        block(NO, nil, @"传入参数有误", nil);
        return nil;
    }
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:pId                 forKey:@"PositionID"];
    if ([HDGlobalInfo instance].hasLogined ) {
        [mdc_parameter setValue:user.sHumanNo   forKey:@"UserID"];
        [mdc_parameter setValue:user.sTocken    forKey:@"Token"];
    }
    
    AFHTTPRequestOperation *op = [self getServer:@"Act218" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act218 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act218 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic_p          = nil;
        NSDictionary    *dic_company    = nil;
        NSDictionary    *dic_recruiter  = nil;
        NSDictionary    *d_trade        = nil;
        WJPositionInfo  *position   = [WJPositionInfo new];
        dic_p           = [JSON objectForKey:@"Result"];
        dic_company     = [self isNull:dic_p[@"Company"]]?      nil: dic_p[@"Company"];
        dic_recruiter   = [self isNull:dic_p[@"Recruiter"]]?    nil: dic_p[@"Recruiter"];
        d_trade         = [self isNull:dic_p[@"TradeInfo"]]?    nil: dic_p[@"TradeInfo"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        Dlog(@"dic = %@", dic_p);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        position.sPositionNo        = FORMAT(@"%@", ([self isNull:dic_p[@"PositionNo"]]?        @"": dic_p[@"PositionNo"]));
        position.sPositionName      = FORMAT(@"%@", ([self isNull:dic_p[@"PositionName"]]?      @"": dic_p[@"PositionName"]));
        position.sRemark            = FORMAT(@"%@", ([self isNull:dic_p[@"Remark"]]?            @"": dic_p[@"Remark"]));
        position.sArea              = FORMAT(@"%@", ([self isNull:dic_p[@"Area"]]?              @"": dic_p[@"Area"]));
        position.sAreaText          = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?          @"": dic_p[@"AreaText"]));
        position.sCompanyNo         = FORMAT(@"%@", ([self isNull:dic_p[@"CompanyNo"]]?         @"": dic_p[@"CompanyNo"]));
        position.sCompnayName       = FORMAT(@"%@", ([self isNull:dic_p[@"CompnayName"]]?       @"": dic_p[@"CompnayName"]));
        position.sPublishTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?       @"": dic_p[@"PublishTime"]));
        position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionCode"]]?      @"": dic_p[@"FunctionCode"]));
        position.sFunctionText      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?      @"": dic_p[@"FunctionText"]));
        position.sEducationCode     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationCode"]]?     @"": dic_p[@"EducationCode"]));
        position.sEducationText     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationText"]]?     @"": dic_p[@"EducationText"]));
        position.sWorkExpCode       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpCode"]]?       @"": dic_p[@"WorkExpCode"]));
        position.sWorkExpText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpText"]]?       @"": dic_p[@"WorkExpText"]));
        position.sSalaryCode        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryCode"]]?        @"": dic_p[@"SalaryCode"]));
        position.sSalaryText        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryText"]]?        @"": dic_p[@"SalaryText"]));
        position.sProperty          = FORMAT(@"%@", ([self isNull:dic_p[@"Property"]]?          @"": dic_p[@"Property"]));
        position.sReward            = FORMAT(@"%@", ([self isNull:dic_p[@"Reward"]]?            @"": dic_p[@"Reward"]));
        position.isCollect          = [dic_p[@"IsCollect"]    boolValue];
        position.isBonus            = [dic_p[@"IsBonus"]      boolValue];
        position.isDeposit          = [dic_p[@"IsDeposit"]    boolValue];
        position.sUrl       = FORMAT(@"%@Position/Detail?pos=%@", [HDGlobalInfo instance].addressInfo.sWebsite_waproot, position.sPositionNo);
        HDEmployerInfo *e   = [HDEmployerInfo new];
        if (dic_company){
            e.sId           = FORMAT(@"%@",([self isNull:dic_company[@"CompanyNo"]]?    @"": dic_company[@"CompanyNo"]));
            e.sRemark       = FORMAT(@"%@",([self isNull:dic_company[@"Remark"]]?       @"": dic_company[@"Remark"]));
            e.sName         = FORMAT(@"%@",([self isNull:dic_company[@"ComName"]]?      @"": dic_company[@"ComName"]));
            e.sTradeCode    = FORMAT(@"%@",([self isNull:dic_company[@"BusinessCode"]]?    @"": dic_company[@"BusinessCode"]));
            e.sTradeText    = FORMAT(@"%@",([self isNull:dic_company[@"BusinessText"]]?    @"": dic_company[@"BusinessText"]));
            e.sPropertyCode = FORMAT(@"%@",([self isNull:dic_company[@"ComProperty"]]?     @"": dic_company[@"ComProperty"]));
            e.sPropertyText = FORMAT(@"%@",([self isNull:dic_company[@"ComPropertyText"]]? @"": dic_company[@"ComPropertyText"]));
            e.sScene01      = FORMAT(@"%@",([self isNull:dic_company[@"Scene01"]]?           @"": dic_company[@"Scene01"]));
            e.sScene02      = FORMAT(@"%@",([self isNull:dic_company[@"Scene02"]]?           @"": dic_company[@"Scene02"]));
            e.sScene03      = FORMAT(@"%@",([self isNull:dic_company[@"Scene03"]]?           @"": dic_company[@"Scene03"]));
            e.sScene04      = FORMAT(@"%@",([self isNull:dic_company[@"Scene04"]]?           @"": dic_company[@"Scene04"]));
            if (e.sScene04.length > 0) {
                [e.mar_urls insertObject:e.sScene04 atIndex:0];
            }
            if (e.sScene03.length > 0) {
                [e.mar_urls insertObject:e.sScene03 atIndex:0];
            }
            if (e.sScene02.length > 0) {
                [e.mar_urls insertObject:e.sScene02 atIndex:0];
            }
            if (e.sScene01.length > 0) {
                [e.mar_urls insertObject:e.sScene01 atIndex:0];
            }
        }
        position.employerInfo   = e;
        WJBrokerInfo *r  = [WJBrokerInfo new];
        if (dic_recruiter){
            r.sHumanNo      = FORMAT(@"%@",([self isNull:dic_recruiter[@"UserNo"]]?      @"": dic_recruiter[@"UserNo"]));
            r.sName         = FORMAT(@"%@",([self isNull:dic_recruiter[@"NickName"]]?    @"": dic_recruiter[@"NickName"]));
            r.sMemberLevel  = FORMAT(@"%@",([self isNull:dic_recruiter[@"Level"]]?       @"": dic_recruiter[@"Level"]));
            r.sAvatarUrl    = FORMAT(@"%@",([self isNull:dic_recruiter[@"Avatar"]]?      @"": dic_recruiter[@"Avatar"]));
            r.sCurCompany   = FORMAT(@"%@",([self isNull:dic_recruiter[@"CurCompany"]]?  @"": dic_recruiter[@"CurCompany"]));
            r.sCurPosition  = FORMAT(@"%@",([self isNull:dic_recruiter[@"CurPosition"]]? @"": dic_recruiter[@"CurPosition"]));
            r.sRoleType     = FORMAT(@"%@",([self isNull:dic_recruiter[@"RoleType"]]?    @"": dic_recruiter[@"RoleType"]));
            r.isAuthen  = [dic_recruiter[@"IsAuthen"] boolValue];
            r.isFocus   = [dic_recruiter[@"IsFocus"] boolValue];
        }
        position.brokerInfo = r;
        
        WJTradeInfo *trade = [WJTradeInfo new];
        if (d_trade){
            trade.sTradeId         = FORMAT(@"%@",([self isNull:d_trade[@"TradeId"]]?         @"": d_trade[@"TradeId"]));
            trade.sServiceFees     = FORMAT(@"%@",([self isNull:d_trade[@"ServiceFees"]]?     @"": d_trade[@"ServiceFees"]));
            trade.sServiceType     = FORMAT(@"%@",([self isNull:d_trade[@"ServiceType"]]?     @"": d_trade[@"ServiceType"]));
            trade.sServiceTypeText = FORMAT(@"%@",([self isNull:d_trade[@"ServiceTypeText"]]? @"": d_trade[@"ServiceTypeText"]));
            trade.sDelayDay        = FORMAT(@"%@",([self isNull:d_trade[@"DelayDay"]]?        @"": d_trade[@"DelayDay"]));
            trade.sDeposit         = FORMAT(@"%@",([self isNull:d_trade[@"Deposit"]]?         @"": d_trade[@"Deposit"]));
            trade.sProperty        = FORMAT(@"%@",([self isNull:d_trade[@"Property"]]?        @"": d_trade[@"Property"]));
            trade.sTradeDesc       = FORMAT(@"%@",([self isNull:d_trade[@"TradeDesc"]]?       @"": d_trade[@"TradeDesc"]));
            trade.sRemark          = FORMAT(@"%@",([self isNull:d_trade[@"Remark"]]?          @"": d_trade[@"Remark"]));
        }
        position.tradeInfo = trade;
        position.sRemark = [position changeBr2n:position.sRemark];
        position.employerInfo.sRemark = [position changeBr2n:position.employerInfo.sRemark];
        block(YES, sCode, @"获取成功", position);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --上传职位场景图片(Act206)
- (AFHTTPRequestOperation *)postImageScene:(HDUserInfo *)user images:(NSArray *)ar positionId:(NSString *)pid completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || ar.count == 0 || pid.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:pid                 forKey:@"positionid"];
    NSMutableURLRequest *request =[self multipartFormRequestWithMethod:@"post" path:@"Act206" parameters:mdc_parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         for (int i = 0; i < ar.count; i++) {
             NSData *data           = UIImagePNGRepresentation(ar[i]);
             NSString *fileName     = FORMAT(@"%d.png", arc4random());
             [formData appendPartWithFileData:data name:@"Photo" fileName:fileName mimeType:@"image/png"];
         }
    }];
    AFHTTPRequestOperation *opration = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Act206 Json ===%@",operation.responseString);
        Dlog(@"Act206 http = %@", operation.response.URL);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned dic = %@" , dic);
        if (!dic) {
            block(NO, nil, @"网络出错，请稍后再试" , nil);
            return;
        }
        NSString *sCode         = FORMAT(@"%@", !dic[@"Code"]?      @"": dic[@"Code"]);
        NSString *sResult       = FORMAT(@"%@", !dic[@"Result"]?    @"": dic[@"Result"]);
        NSString *sErrorDesc    = FORMAT(@"%@", !dic[@"ErrorDesc"]? @"上传失败": dic[@"ErrorDesc"]);
        if ([sCode isEqualToString:@"0"]) {
            block(YES, sCode, @"上传成功", sResult);
            return;
        }else{
            block(NO, sCode, sErrorDesc, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"网络请求失败->%@", error);
        block(NO, FORMAT(@"%d", (int)error.code), @"网络请求失败", nil);
    }];
    [opration start];
    return opration;
}

#pragma mark --修改职位场景图片(Act207)
- (AFHTTPRequestOperation *)changeImageScene:(HDUserInfo *)user image:(UIImage *)img positionId:(NSString *)pid sceneId:(NSString *)sceneId isDelete:(BOOL)isDelete completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || pid.length == 0 || sceneId.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter  = [[NSMutableDictionary alloc] init];
    NSString *sIsDelete                 = FORMAT(@"%d", isDelete);
    Dlog(@"sIsDelete = %@", sIsDelete);
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:pid                 forKey:@"positionid"];
    [mdc_parameter setValue:sceneId             forKey:@"sceneid"];
    [mdc_parameter setValue:sIsDelete           forKey:@"isdelete"];

    NSMutableURLRequest *request =[self multipartFormRequestWithMethod:@"post" path:@"Act207" parameters:mdc_parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (!isDelete) {
            NSData *data          = UIImagePNGRepresentation(img);
            NSString *fileName    = FORMAT(@"%d.png", arc4random());
            [formData appendPartWithFileData:data name:@"Photo" fileName:fileName mimeType:@"image/png"];
        }
    }];
    AFHTTPRequestOperation *opration = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"json ===%@",operation.responseString);
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned dic = %@" , dic);
        if (!dic) {
            block(NO, nil, @"网络出错，请稍后再试" , nil);
            return;
        }
        NSString *sCode         = FORMAT(@"%@",!dic[@"Code"]?           @"": dic[@"Code"]);
        NSString *sResult       = FORMAT(@"%@",!dic[@"Result"]?         @"": dic[@"Result"]);
        NSString *sErrorDesc    = FORMAT(@"%@", !dic[@"ErrorDesc"]?     @"上传失败": dic[@"ErrorDesc"]);
        if ([sCode isEqualToString:@"0"]) {
            block(YES, sCode, @"上传成功", sResult);
            return;
        }else{
            block(NO, sCode, sErrorDesc, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"网络请求失败->%@", error);
        block(NO, FORMAT(@"%d", (int)error.code), @"网络请求失败", nil);
    }];
    [opration start];
    return opration;
}

#pragma mark --导入多个职位(Act208)
- (AFHTTPRequestOperation *)releasePositions:(HDUserInfo *)user positions:(NSArray *)ar enterpriceId:(NSString *)enterproceId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (ar.count == 0 || enterproceId.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSString *s = [(HDIMPositionInfo *)ar[0] sId];
    for (HDIMPositionInfo *info in ar) {
        s = [s stringByAppendingString:FORMAT(@",%@", info.sId)];
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:s                   forKey:@"positionIDs"];
    [mdc_parameter setValue:enterproceId        forKey:@"enterpriseID"];
    AFHTTPRequestOperation *op = [self getServer:@"Act208" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"发布成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;

}

#pragma mark --职位上架下架操作(Act209)
- (AFHTTPRequestOperation *)changeShelve:(HDUserInfo *)user isUnshelve:(BOOL)isOff positionId:(NSString *)pId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || pId.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                    forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM                forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]        forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION                 forKey:@"Version"];
    [mdc_parameter setValue:@"0"                    forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo            forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken            forKey:@"Token"];
    [mdc_parameter setValue:FORMAT(@"%d", isOff)    forKey:@"isOffline"];
    [mdc_parameter setValue:pId                     forKey:@"positionid"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act209" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSString        *sResult    = nil;
        
        sResult     = FORMAT(@"%@", (!JSON[@"Result"]? @"": JSON[@"Result"]));
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"操作成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取雇主信息列表(Act217)
- (AFHTTPRequestOperation *)getEmployeeInfoList:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *mar, BOOL isLastPage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", nil, NO);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:@"100"              forKey:@"Size"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act217" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil, NO);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil, NO);
            return;
        }
        NSMutableArray *mar = [NSMutableArray new];
        BOOL isLast         = [((NSString *)FORMAT(@"%@", ([self isNull:dic[@"IsLastPage"]]?  @"": dic[@"IsLastPage"]))) boolValue];
        NSArray *ar_employees = dic[@"Employer"];
        if (!ar_employees) {
            block(NO, nil, @"服务器出错，请稍后再试", nil, NO);
            return;
        }
        for (int i = 0; i < ar_employees.count; i++) {
            HDEmployerInfo *info = [HDEmployerInfo new];
            NSDictionary *dic_  = ar_employees[i];
            info.sTradeCode     = FORMAT(@"%@", [self isNull:dic_[@"BusinessCode"]]?    @"": dic_[@"BusinessCode"]);
            info.sTradeText     = FORMAT(@"%@", [self isNull:dic_[@"BusinessText"]]?    @"": dic_[@"BusinessText"]);
            info.sName          = FORMAT(@"%@", [self isNull:dic_[@"ComName"]]?         @"": dic_[@"ComName"]);
            info.sId            = FORMAT(@"%@", [self isNull:dic_[@"ComNo"]]?           @"": dic_[@"ComNo"]);
            info.sPropertyCode  = FORMAT(@"%@", [self isNull:dic_[@"ComProperty"]]?     @"": dic_[@"ComProperty"]);
            info.sPropertyText  = FORMAT(@"%@", [self isNull:dic_[@"ComPropertyText"]]? @"": dic_[@"ComPropertyText"]);
            info.sRemark        = FORMAT(@"%@", [self isNull:dic_[@"Remark"]]?          @"": dic_[@"Remark"]);
            info.sScene01       = FORMAT(@"%@", [self isNull:dic_[@"Scene01"]]?         @"": dic_[@"Scene01"]);
            info.sScene02       = FORMAT(@"%@", [self isNull:dic_[@"Scene02"]]?         @"": dic_[@"Scene02"]);
            info.sScene03       = FORMAT(@"%@", [self isNull:dic_[@"Scene03"]]?         @"": dic_[@"Scene03"]);
            info.sScene04       = FORMAT(@"%@", [self isNull:dic_[@"Scene04"]]?         @"": dic_[@"Scene04"]);
            [mar addObject:info];
        }
        block(YES, sCode, @"更新成功", mar, isLast);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil, NO);
    }];
    return op;
}

#pragma mark --设置反馈状态(Act301)
- (AFHTTPRequestOperation *)setFeedbackType:(HDUserInfo *)user recommendId:(NSString *)rId feedbackType:(int)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || rId.length == 0 || type < 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSString *sType = FORMAT(@"%d", (int)type);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:sType               forKey:@"feedbacktype"];
    [mdc_parameter setValue:rId                 forKey:@"recommendId"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act301" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        dic         = [JSON objectForKey:@"Result"];
        Dlog(@"dic = %@", dic);
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获取我的人选(Act306)
- (AFHTTPRequestOperation *)getRecommendList:(HDUserInfo *)user position:(NSString *)pId pageIndex:(NSString *)index pageSize:(NSString *)size CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                    forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM                forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]        forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION                 forKey:@"Version"];
    [mdc_parameter setValue:@"0"                    forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo           forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken            forKey:@"Token"];
    [mdc_parameter setValue:index                   forKey:@"PageIndex"];
    [mdc_parameter setValue:size                    forKey:@"pageSize"];
    [mdc_parameter setValue:pId                     forKey:@"PositionID"];
    AFHTTPRequestOperation *op = [self getServer:@"Act306" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        BOOL            isLastPage  = YES;
        NSArray         *ar_rcmd    = nil;
        NSMutableArray  *mar_rcmd   = [NSMutableArray new];
        
        dic         = [JSON objectForKey:@"Result"];
        Dlog(@"dic = %@", dic);
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        
        if (![dic[@"Recommends"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar_rcmd  = dic[@"Recommends"];
        }
        
        for (int i = 0; i < ar_rcmd.count; i++) {
            NSDictionary *dic = nil;
            if ([ar_rcmd[i] isKindOfClass:[NSDictionary class]]) {
                dic = ar_rcmd[i];
            }else{
                Dlog(@"Error:获取服务器数据出错");
            }
            HDRecommendInfo *recommend      = [[HDRecommendInfo alloc] init];
            recommend.sHumanNo              = FORMAT(@"%@", [self isNull:dic[@"PersonalNo"]]?        @"": dic[@"PersonalNo"]);
            recommend.sCreatedTime          = FORMAT(@"%@", [self isNull:dic[@"CreatedTime"]]?       @"": dic[@"CreatedTime"]);
            recommend.sCurCompanyName       = FORMAT(@"%@", [self isNull:dic[@"CurCompanyName"]]?    @"": dic[@"CurCompanyName"]);
            recommend.sCurPosition          = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?       @"": dic[@"CurPosition"]);
            recommend.sEduLevel             = FORMAT(@"%@", [self isNull:dic[@"EducationText"]]?     @"": dic[@"EducationText"]);
            recommend.sEducation            = FORMAT(@"%@", [self isNull:dic[@"Education"]]?         @"": dic[@"Education"]);
            recommend.sEnterpriseID         = FORMAT(@"%@", [self isNull:dic[@"EnterpriseID"]]?      @"": dic[@"EnterpriseID"]);
            recommend.sEnterpriseText       = FORMAT(@"%@", [self isNull:dic[@"EducationText"]]?     @"": dic[@"EducationText"]);
            recommend.sPhone                = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?            @"": dic[@"MPhone"]);
            recommend.sMatchCount           = FORMAT(@"%@", [self isNull:dic[@"MatchCount"]]?        @"": dic[@"MatchCount"]);
            recommend.sName                 = FORMAT(@"%@", [self isNull:dic[@"Name"]]?              @"": dic[@"Name"]);
            recommend.sPositionDes          = FORMAT(@"%@", [self isNull:dic[@"PositionDes"]]?       @"": dic[@"PositionDes"]);
            recommend.sPositionID           = FORMAT(@"%@", [self isNull:dic[@"PositionID"]]?        @"": dic[@"PositionID"]);
            recommend.sPositionName         = FORMAT(@"%@", [self isNull:dic[@"PositionName"]]?      @"": dic[@"PositionName"]);
            recommend.sProgress             = FORMAT(@"%@", [self isNull:dic[@"Progress"]]?          @"": dic[@"Progress"]);
            recommend.sProgressText         = FORMAT(@"%@", [self isNull:dic[@"ProgressText"]]?      @"": dic[@"ProgressText"]);
            recommend.sRecommendId          = FORMAT(@"%@", [self isNull:dic[@"RecommendID"]]?       @"": dic[@"RecommendID"]);
            recommend.sRefereeCompanyName   = FORMAT(@"%@", [self isNull:dic[@"RefereeCompanyName"]]?@"": dic[@"RefereeCompanyName"]);
            recommend.sRefereeId            = FORMAT(@"%@", [self isNull:dic[@"RefereeId"]]?         @"": dic[@"RefereeId"]);
            recommend.sRefereeMPhone        = FORMAT(@"%@", [self isNull:dic[@"RefereeMPhone"]]?     @"": dic[@"RefereeMPhone"]);
            recommend.sRefereeName          = FORMAT(@"%@", [self isNull:dic[@"RefereeName"]]?       @"": dic[@"RefereeName"]);
            recommend.sRefereePosition      = FORMAT(@"%@", [self isNull:dic[@"RefereePosition"]]?   @"": dic[@"RefereePosition"]);
            recommend.sServiceFee           = FORMAT(@"%@", [self isNull:dic[@"ServiceFee"]]?        @"": dic[@"ServiceFee"]);
            recommend.sSexText              = FORMAT(@"%@", [self isNull:dic[@"SexText"]]?           @"": dic[@"SexText"]);
            recommend.sWorkYears            = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?         @"": dic[@"WorkYears"]);
            recommend.sPersonalDesc         = FORMAT(@"%@", [self isNull:dic[@"PersonalDes"]]?       @"": dic[@"PersonalDes"]);
            recommend.isMale                = FORMAT(@"%@", [self isNull:dic[@"Sex"]]?               @"": dic[@"Sex"]).boolValue;
            recommend.isOpen                = FORMAT(@"%@", [self isNull:dic[@"IsOpen"]]?            @"": dic[@"IsOpen"]).boolValue;
            recommend.isBonus               = FORMAT(@"%@", [self isNull:dic[@"IsBonus"]]?           @"": dic[@"IsBonus"]).boolValue;
            recommend.isDeposit             = FORMAT(@"%@", [self isNull:dic[@"IsDeposit"]]?         @"": dic[@"IsDeposit"]).boolValue;
            recommend.isFromCloud           = FORMAT(@"%@", [self isNull:dic[@"IsFromCloud"]]?       @"": dic[@"IsFromCloud"]).boolValue;
            recommend.isHaveBonus           = FORMAT(@"%@", [self isNull:dic[@"IsHaveBonus"]]?       @"": dic[@"IsHaveBonus"]).boolValue;
            [mar_rcmd addObject:recommend];
        }
        block(YES, sCode, @"更新成功", isLastPage, mar_rcmd);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark --获取人选进展状态列表(Act307)
- (AFHTTPRequestOperation *)getRecommendProgress:(HDUserInfo *)user recommendId:(NSString *)rId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *progressList))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || rId.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:rId                 forKey:@"RecommendID"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act307" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act307 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act307 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSArray         *ar             = nil;
        NSMutableArray  *mar_progress   = [NSMutableArray new];
        ar          = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *dic       = ar[i];
            HDProgressInfo *info    = [HDProgressInfo new];
            info.sContent           = FORMAT(@"%@", [self isNull:dic[@"Content"]]?              @"": dic[@"Content"]);
            info.sCreatedTime       = FORMAT(@"%@", [self isNull:dic[@"ConteCreatedTiment"]]?   @"": dic[@"CreatedTime"]);
            info.sProgress          = FORMAT(@"%@", [self isNull:dic[@"Progress"]]?             @"": dic[@"Progress"]);
            info.sProgressText      = FORMAT(@"%@", [self isNull:dic[@"ProgressText"]]?         @"": dic[@"ProgressText"]);
            [mar_progress addObject:info];
        }
        
        block(YES, sCode, @"获取状态列表成功", mar_progress);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --获取评价信息(Act308)
- (AFHTTPRequestOperation *)getEvaluateInfomation:(NSString *)recommendId user:(HDUserInfo *)user CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDEvaluateInfo *info))block
{
    if (recommendId.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:recommendId         forKey:@"recommendid"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act308" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        HDEvaluateInfo  *evaluate   = [HDEvaluateInfo new];
        dic         = [JSON objectForKey:@"Result"];
        Dlog(@"dic = %@", dic);
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        evaluate.sEvalueId      = FORMAT(@"%@", [self isNull:dic[@"AutoID"]]?                @"": dic[@"AutoID"]);
        evaluate.sPersonalNo    = FORMAT(@"%@", [self isNull:dic[@"FK_PersonalNo"]]?         @"": dic[@"FK_PersonalNo"]);
        evaluate.sRecommendId   = FORMAT(@"%@", [self isNull:dic[@"FK_RemmendID"]]?          @"": dic[@"FK_RemmendID"]);
        evaluate.sRefereeId     = FORMAT(@"%@", [self isNull:dic[@"FK_Referee"]]?            @"": dic[@"FK_Referee"]);
        evaluate.sMatchPoint1   = FORMAT(@"%@", [self isNull:dic[@"MatchPoint1"]]?           @"": dic[@"MatchPoint1"]);
        evaluate.sMatchPoint2   = FORMAT(@"%@", [self isNull:dic[@"MatchPoint2"]]?           @"": dic[@"MatchPoint2"]);
        evaluate.sMatchPoint3   = FORMAT(@"%@", [self isNull:dic[@"MatchPoint3"]]?           @"": dic[@"MatchPoint3"]);
        evaluate.sMatchPoint4   = FORMAT(@"%@", [self isNull:dic[@"MatchPoint4"]]?           @"": dic[@"MatchPoint4"]);
        evaluate.sMatchPoint5   = FORMAT(@"%@", [self isNull:dic[@"MatchPoint5"]]?           @"": dic[@"MatchPoint5"]);
        evaluate.sCreateTime    = FORMAT(@"%@", [self isNull:dic[@"CreatedTime"]]?           @"": dic[@"CreatedTime"]);
        evaluate.sRemark        = FORMAT(@"%@", [self isNull:dic[@"Remark"]]?                @"": dic[@"Remark"]);
        evaluate.sStatus        = FORMAT(@"%@", [self isNull:dic[@"Status"]]?                @"": dic[@"Status"]);
        evaluate.sProperty      = FORMAT(@"%@", [self isNull:dic[@"Property"]]?              @"": dic[@"Property"]);
        block(YES, sCode, @"更新成功", evaluate);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --修改人才简历(Act312)
- (AFHTTPRequestOperation *)modifyTalent:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !talent) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
//    NSString *sNow = [HDUtility readNowTimeWithFormate:@"yyyy.MM.dd"];
//    NSString *sYear = [sNow substringToIndex:4];
//    int y = [sYear intValue] - [talent.sWorkYears intValue];
//    NSString *sWorkTime = [FORMAT(@"%d", y) stringByAppendingString:[sNow substringFromIndex:4]];
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:talent.sName            forKey:@"name"];
    [mdc_parameter setValue:talent.sPhone           forKey:@"mobile"];
    [mdc_parameter setValue:talent.sCurCompanyName  forKey:@"currentEnterprise"];
    [mdc_parameter setValue:talent.sCurPosition     forKey:@"currentposition"];
    [mdc_parameter setValue:talent.sWorkYears       forKey:@"workTime"];
    [mdc_parameter setValue:talent.sRemark          forKey:@"remark"];
    [mdc_parameter setValue:talent.sHumanNo         forKey:@"personalno"];
    [mdc_parameter setValue:talent.sSexText             forKey:@"sex"];
    [mdc_parameter setValue:talent.sEduLevel        forKey:@"edulevel"];
    [mdc_parameter setValue:talent.sAreaText        forKey:@"livearea"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act312" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act312 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"修改成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --添加人选信息(Act313)
- (AFHTTPRequestOperation *)newTalent:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !talent) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
//    NSString *sNow = [HDUtility readNowTimeWithFormate:@"yyyy.MM.dd"];
//    NSString *sYear = [sNow substringToIndex:4];
//    int y = [sYear intValue] - [talent.sWorkYears intValue];
//    NSString *sWorkTime = [FORMAT(@"%d", y) stringByAppendingString:[sNow substringFromIndex:4]];
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    if (talent.sWorkYears) {
        if ([talent.sWorkYears rangeOfString:@"."].location==NSNotFound){
            talent.sWorkYears = [HDJJUtility timeConversion:a-[talent.sWorkYears integerValue]*356*24*60*60];
        }else{
            NSArray *year = [talent.sWorkYears componentsSeparatedByString:@"."];
            talent.sWorkYears = [HDJJUtility timeConversion:a-([year[0] integerValue]*356*24*60*60+[year[1] integerValue]*30*24*60*60)];
        }
    }
    NSLog(@"时间戳:%ld（%@）",(long)a,talent.sWorkYears);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:talent.sName            forKey:@"name"];
    [mdc_parameter setValue:talent.sPhone           forKey:@"mobile"];
    [mdc_parameter setValue:talent.sCurCompanyName  forKey:@"currentEnterprise"];
    [mdc_parameter setValue:talent.sCurPosition     forKey:@"currentposition"];
    [mdc_parameter setValue:talent.sWorkYears       forKey:@"workTime"];
    [mdc_parameter setValue:talent.sRemark          forKey:@"remark"];
    [mdc_parameter setValue:talent.sSexText         forKey:@"sex"];
    [mdc_parameter setValue:talent.sEduLevel        forKey:@"edulevel"];
    [mdc_parameter setValue:talent.sAreaText        forKey:@"livearea"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act313" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act313 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"新增成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --获得我新增的人选列表(Act314)
- (AFHTTPRequestOperation *)getMyTalent:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:index               forKey:@"PageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act314" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSMutableArray  *mar_talents    = [NSMutableArray new];
        BOOL            isLast          = NO;
        
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        dic         = [JSON objectForKey:@"Result"];Dlog(@"dic = %@", dic);
        isLast      = [dic[@"IsLastPage"] boolValue];
        NSArray *ar = dic[@"Recommends"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        if (!dic[@"IsLastPage"]) {
            block(YES, sCode, @"获取数据失败", NO, nil);
            return;
        }
        if (!ar) {
            block(YES, sCode, @"获取数据失败", NO, nil);
            return;
        }
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *dic_t    = ar[i];
            HDTalentInfo *talent        = [HDTalentInfo new];
            talent.sAreaText            = FORMAT(@"%@", [self isNull:dic_t[@"AreaText"]]?       @"": dic_t[@"AreaText"]);
            talent.sCreatedTime         = FORMAT(@"%@", [self isNull:dic_t[@"CreatedTime"]]?    @"": dic_t[@"CreatedTime"]);
            talent.sCurCompanyName      = FORMAT(@"%@", [self isNull:dic_t[@"CurCompanyName"]]? @"": dic_t[@"CurCompanyName"]);
            talent.sCurPosition         = FORMAT(@"%@", [self isNull:dic_t[@"CurPosition"]]?    @"": dic_t[@"CurPosition"]);
            talent.sEduLevel            = FORMAT(@"%@", [self isNull:dic_t[@"EducationText"]]?  @"": dic_t[@"EducationText"]);
            talent.sPhone               = FORMAT(@"%@", [self isNull:dic_t[@"MPhone"]]?         @"": dic_t[@"MPhone"]);
            talent.sMatchCount          = FORMAT(@"%@", [self isNull:dic_t[@"MatchCount"]]?     @"": dic_t[@"MatchCount"]);
            talent.sName                = FORMAT(@"%@", [self isNull:dic_t[@"Name"]]?           @"": dic_t[@"Name"]);
            talent.sHumanNo             = FORMAT(@"%@", [self isNull:dic_t[@"PersonalNo"]]?     @"": dic_t[@"PersonalNo"]);
            talent.sServiceFee          = FORMAT(@"%@", [self isNull:dic_t[@"ServiceFee"]]?     @"": dic_t[@"ServiceFee"]);
            talent.sSexText             = FORMAT(@"%@", [self isNull:dic_t[@"SexText"]]?        @"": dic_t[@"SexText"]);
            talent.sStartWorkTime       = FORMAT(@"%@", [self isNull:dic_t[@"StartWorkTime"]]?  @"": dic_t[@"StartWorkTime"]);
            talent.sWorkYears           = FORMAT(@"%@", [self isNull:dic_t[@"WorkYears"]]?      @"": dic_t[@"WorkYears"]);
            talent.isOpen               = FORMAT(@"%@", [self isNull:dic_t[@"IsOpen"]]?         @"": dic_t[@"IsOpen"]).boolValue;
            [mar_talents addObject:talent];
        }
        block(YES, sCode, @"更新成功", isLast, mar_talents);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}


#pragma mark --获得指定人选信息(Act316)未完
- (void)getMyRecommendInIformation:(HDUserInfo *)user personalNo:(NSString *)persionNo completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || persionNo.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [self getPath:@"Act202" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        dic         = [JSON objectForKey:@"Result"];
        Dlog(@"dic = %@", dic);
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
}

#pragma mark --获取我的小伙伴列表（联系人）(Act317)
- (AFHTTPRequestOperation *)getMyJFriends:(HDUserInfo *)user index:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar_friends, BOOL isLast))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] < 0 || [size intValue] < 0) {
        block(NO, nil, @"传入参数有误", nil, NO);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:index               forKey:@"PageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act317" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil, NO);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", (!JSON[@"Code"]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", (!JSON[@"ErrorDesc"]?   @"": JSON[@"ErrorDesc"]));
        NSMutableArray  *mar        = [NSMutableArray new];
        BOOL            isLastPage  = NO;
        NSDictionary    *dic        = JSON[@"Result"];
        NSArray         *ar         = dic[@"Referees"];
        if (![sCode isEqualToString:@"0"] || dic.count == 0 || !ar) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil, NO);
            return;
        }
        isLastPage              = [FORMAT(@"%@", [self isNull:dic[@"IsLastPage"]]? @"": dic[@"IsLastPage"]) boolValue];
        for (int i = 0; i < ar.count; i++) {
            HDJFriendInfo *info = [HDJFriendInfo new];
            NSDictionary *dic   = ar[i];
            info.sCreatedDt     = FORMAT(@"%@", [self isNull:dic[@"CreatedDt"]]?        @"": dic[@"CreatedDt"]);
            info.sMatchCount    = FORMAT(@"%@", [self isNull:dic[@"MatchCount"]]?       @"": dic[@"MatchCount"]);
            info.sPCompany      = FORMAT(@"%@", [self isNull:dic[@"PCompany"]]?         @"": dic[@"PCompany"]);
            info.sPMPhone       = FORMAT(@"%@", [self isNull:dic[@"PMPhone"]]?          @"": dic[@"PMPhone"]);
            info.sPName         = FORMAT(@"%@", [self isNull:dic[@"PName"]]?            @"": dic[@"PName"]);
            info.sPPosition     = FORMAT(@"%@", [self isNull:dic[@"PPosition"]]?        @"": dic[@"PPosition"]);
            info.sPersonalNo    = FORMAT(@"%@", [self isNull:dic[@"PersonalNo"]]?       @"": dic[@"PersonalNo"]);
            info.sPositionName  = FORMAT(@"%@", [self isNull:dic[@"PositionName"]]?     @"": dic[@"PositionName"]);
            info.sPositionNo    = FORMAT(@"%@", [self isNull:dic[@"PositionNo"]]?       @"": dic[@"PositionNo"]);
            info.sProgress      = FORMAT(@"%@", [self isNull:dic[@"Progress"]]?         @"": dic[@"Progress"]);
            info.sProgressText  = FORMAT(@"%@", [self isNull:dic[@"ProgressText"]]?     @"": dic[@"ProgressText"]);
            info.sRCompany      = FORMAT(@"%@", [self isNull:dic[@"RCompany"]]?         @"": dic[@"RCompany"]);
            info.sRCreatedDT    = FORMAT(@"%@", [self isNull:dic[@"RCreatedDT"]]?       @"": dic[@"RCreatedDT"]);
            info.sRMPhone       = FORMAT(@"%@", [self isNull:dic[@"RMPhone"]]?          @"": dic[@"RMPhone"]);
            info.sRName         = FORMAT(@"%@", [self isNull:dic[@"RName"]]?            @"": dic[@"RName"]);
            info.sRPosition     = FORMAT(@"%@", [self isNull:dic[@"RPosition"]]?        @"": dic[@"RPosition"]);
            info.sRecommendID   = FORMAT(@"%@", [self isNull:dic[@"RecommendID"]]?      @"": dic[@"RecommendID"]);
            info.sReferee       = FORMAT(@"%@", [self isNull:dic[@"Referee"]]?          @"": dic[@"Referee"]);
            info.sStartWorkTime = FORMAT(@"%@", [self isNull:dic[@"StartWorkTime"]]?    @"": dic[@"StartWorkTime"]);
            info.sWorkYears     = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?        @"": dic[@"WorkYears"]);
            [mar addObject:info];
        }
        block(YES, sCode, @"获取信息成功", mar, isLastPage);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil, NO);
    }];
    return op;
}

#pragma mark --获取所有人才列表（联系人-人才）(Act318)
- (AFHTTPRequestOperation *)getAllTalent:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:index               forKey:@"PageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act318" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSMutableArray  *mar_talents    = [NSMutableArray new];
        BOOL            isLast          = NO;
        
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        dic         = [JSON objectForKey:@"Result"];Dlog(@"dic = %@", dic);
        isLast      = [dic[@"IsLastPage"] boolValue];
        NSArray *ar = dic[@"Recommends"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        if (!dic[@"IsLastPage"]) {
            block(YES, sCode, @"获取数据失败", NO, nil);
            return;
        }
        if (!ar) {
            block(YES, sCode, @"获取数据失败", NO, nil);
            return;
        }
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *dic_t    = ar[i];
            HDTalentInfo *talent        = [HDTalentInfo new];
            talent.sAreaText            = FORMAT(@"%@", [self isNull:dic_t[@"AreaText"]]?       @"": dic_t[@"AreaText"]);
            talent.sCreatedTime         = FORMAT(@"%@", [self isNull:dic_t[@"CreatedTime"]]?    @"": dic_t[@"CreatedTime"]);
            talent.sCurCompanyName      = FORMAT(@"%@", [self isNull:dic_t[@"CurCompanyName"]]? @"": dic_t[@"CurCompanyName"]);
            talent.sCurPosition         = FORMAT(@"%@", [self isNull:dic_t[@"CurPosition"]]?    @"": dic_t[@"CurPosition"]);
            talent.sEduLevel            = FORMAT(@"%@", [self isNull:dic_t[@"EducationText"]]?  @"": dic_t[@"EducationText"]);
            talent.sPhone               = FORMAT(@"%@", [self isNull:dic_t[@"MPhone"]]?         @"": dic_t[@"MPhone"]);
            talent.sMatchCount          = FORMAT(@"%@", [self isNull:dic_t[@"MatchCount"]]?     @"": dic_t[@"MatchCount"]);
            talent.sName                = FORMAT(@"%@", [self isNull:dic_t[@"Name"]]?           @"": dic_t[@"Name"]);
            talent.sHumanNo             = FORMAT(@"%@", [self isNull:dic_t[@"PersonalNo"]]?     @"": dic_t[@"PersonalNo"]);
            talent.sServiceFee          = FORMAT(@"%@", [self isNull:dic_t[@"ServiceFee"]]?     @"": dic_t[@"ServiceFee"]);
            talent.sSexText             = FORMAT(@"%@", [self isNull:dic_t[@"SexText"]]?        @"": dic_t[@"SexText"]);
            talent.sStartWorkTime       = FORMAT(@"%@", [self isNull:dic_t[@"StartWorkTime"]]?  @"": dic_t[@"StartWorkTime"]);
            talent.sWorkYears           = FORMAT(@"%@", [self isNull:dic_t[@"WorkYears"]]?      @"": dic_t[@"WorkYears"]);
            talent.isOpen               = FORMAT(@"%@", [self isNull:dic_t[@"IsOpen"]]?         @"": dic_t[@"IsOpen"]).boolValue;
            [mar_talents addObject:talent];
        }
        block(YES, sCode, @"更新成功", isLast, mar_talents);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark --推荐现有人选(Act319)
- (AFHTTPRequestOperation *)recommendMyTalent:(HDUserInfo *)user position:(NSString *)positionNo talent:(NSString *)talentNo completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDRecommendInfo *info))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || positionNo.length == 0 || talentNo.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:positionNo          forKey:@"positionno"];
    [mdc_parameter setValue:talentNo            forKey:@"personalno"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act319" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act319 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act319 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        HDRecommendInfo *recommendInfo = [HDRecommendInfo new];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        recommendInfo.sHumanNo      = FORMAT(@"%@", [self isNull:dic[@"PersonalNo"]]? @"": dic[@"PersonalNo"]);
        recommendInfo.sRecommendId  = FORMAT(@"%@", [self isNull:dic[@"RecommendID"]]? @"": dic[@"RecommendID"]);
        block(YES, sCode, @"加载成功", recommendInfo);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --获取各类型订阅号消息列表(Act502)
- (AFHTTPRequestOperation *)getSubscribeNews:(HDUserInfo *)user pageIndex:(int)index pageSize:(int)size lastTicks:(NSString *)ticks completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage, NSString *tick))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || ticks.length == 0) {
        block(NO, nil, @"传入参数有误", nil, NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:ticks               forKey:@"LastTicks"];
    [mdc_parameter setValue:@(index)            forKey:@"PageIndex"];
    [mdc_parameter setValue:@(size)             forKey:@"PageSize"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act502" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act502 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act502 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil, NO, nil);
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        NSMutableArray  *mar_list   = [NSMutableArray new];
        dic                         = [JSON objectForKey:@"Result"];
        sCode                       = FORMAT(@"%@", (!JSON[@"Code"]?        @"": JSON[@"Code"]));
        sErrDesc                    = FORMAT(@"%@", (!JSON[@"ErrorDesc"]?   @"": JSON[@"ErrorDesc"]));
        NSArray *ar_                = dic[@"List"];
        NSString *sTicks    = FORMAT(@"%@", !dic[@"Ticks"]? @"": dic[@"Ticks"]);
        BOOL        isLast  = [dic[@"IsLastPage"] boolValue];
        if (![sCode isEqualToString:@"0"] || sTicks.length == 0 || ar_ == nil) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil, NO, nil);
            return;
        }
        for (int i = 0; i < ar_.count; i++) {
            HDSubscriberInfo *sInfo = [HDSubscriberInfo new];
            NSDictionary *d         = ar_[i];
            sInfo.sSubscriberID     = FORMAT(@"%@", [self isNull:d[@"SubscriberID"]]?    @"": d[@"SubscriberID"]);
            sInfo.sSubscriberLogo   = FORMAT(@"%@", [self isNull:d[@"SubscriberLogo"]]?  @"": d[@"SubscriberLogo"]);
            sInfo.sSubscriberName   = FORMAT(@"%@", [self isNull:d[@"SubscriberName"]]?  @"": d[@"SubscriberName"]);
            sInfo.sCount            = FORMAT(@"%@", [self isNull:d[@"Count"]]?           @"": d[@"Count"]);
            sInfo.sMsgID            = FORMAT(@"%@", [self isNull:d[@"MsgID"]]?           @"": d[@"MsgID"]);
            sInfo.sTitle            = FORMAT(@"%@", [self isNull:d[@"Title"]]?           @"": d[@"Title"]);
            sInfo.sContent          = FORMAT(@"%@", [self isNull:d[@"Content"]]?         @"": d[@"Content"]);
            sInfo.formatType        = FORMAT(@"%@", [self isNull:d[@"FormatType"]]?      @"": d[@"FormatType"]).integerValue;
            sInfo.sCreateTime       = FORMAT(@"%@", [self isNull:d[@"CreateTime"]]?      @"": d[@"CreateTime"]);
            sInfo.sAvatarUrl        = FORMAT(@"%@", [self isNull:d[@"Url"]]?             @"": d[@"Url"]);
            sInfo.platformType      = HDMessagePlatformTypeJianJian;
            [mar_list addObject:sInfo];
        }
        block(YES, sCode, @"获取订阅号消息成功", mar_list, isLast, sTicks);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil, NO, nil);
    }];
    return op;
}

#pragma mark --获取某订阅号详细消息列表(Act503)
- (AFHTTPRequestOperation *)getSubscribeDetail:(HDUserInfo *)user subscribeId:(NSString *)subId lastTicks:(NSString *)ticks completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || ticks.length == 0 || subId.length == 0) {
        block(NO, nil, @"传入参数有误", nil, NO);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:ticks               forKey:@"LastTicks"];
    [mdc_parameter setValue:subId               forKey:@"subscriberID"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act503" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act503 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act503 JSON = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil, NO);
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        NSMutableArray  *mar_list   = [NSMutableArray new];
        dic                         = [JSON objectForKey:@"Result"];
        sCode                       = FORMAT(@"%@", (!JSON[@"Code"]?        @"": JSON[@"Code"]));
        sErrDesc                    = FORMAT(@"%@", (!JSON[@"ErrorDesc"]?   @"": JSON[@"ErrorDesc"]));
        NSArray *ar_                = dic[@"List"];
        BOOL isLast                 = [dic[@"IsLastPage"] boolValue];
        if (![sCode isEqualToString:@"0"] || ar_ == nil) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil, NO);
            return;
        }
        for (int i = 0; i < ar_.count; i++) {
            HDMessageInfo *info = [HDMessageInfo new];
            NSDictionary *d        = ar_[i];
            info.sMsgID            = FORMAT(@"%@", [self isNull:d[@"MsgID"]]?           @"": d[@"MsgID"]);
            info.sTitle            = FORMAT(@"%@", [self isNull:d[@"Title"]]?           @"": d[@"Title"]);
            info.sContent          = FORMAT(@"%@", [self isNull:d[@"Content"]]?         @"": d[@"Content"]);
            info.formatType        = FORMAT(@"%@", [self isNull:d[@"FormatType"]]?      @"": d[@"FormatType"]).integerValue;
            info.sCreateTime       = FORMAT(@"%@", [self isNull:d[@"CreateTime"]]?      @"": d[@"CreateTime"]);
            info.sAvatarUrl        = FORMAT(@"%@", [self isNull:d[@"Url"]]?             @"": d[@"Url"]);
            info.bubbleType        = ![info.sMsgID isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
            [mar_list addObject:info];
        }
        block(YES, sCode, @"获取订阅号消息成功", mar_list, isLast);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil, NO);
    }];
    return op;
}

#pragma mark --检查更新(Act601)
- (AFHTTPRequestOperation *)updateVersion:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION_CODE        forKey:@"versionCode"];
    [mdc_parameter setValue:CHANAL              forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act601" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act601 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act601 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        NSDictionary *dic_version   = dic[@"Version"];
        if ([self isNull:dic_version]) {
            block(YES, nil, @"当前为最新系统", nil);
            return;
        }
        
        block(YES, sCode, @"有新版本", dic_version);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --获取全局参数(Act602)
- (AFHTTPRequestOperation *)getGlobalParameters:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic))block
{
    AFHTTPRequestOperation *op = [self getServer:@"Act602" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        dic         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"] || dic.count == 0) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        NSArray *ar_area        = dic[@"Area"];
        NSArray *ar_trade       = dic[@"Trade"];
        NSArray *ar_post        = dic[@"Post"];
        NSArray *ar_workExp     = dic[@"WorkExp"];
        NSArray *ar_salary      = dic[@"Salary"];
        NSArray *ar_education   = dic[@"Education"];
        NSArray *ar_property    = dic[@"Property"];
        NSArray *ar_bank        = dic[@"Bank"];
        if (ar_area.count == 0 || ar_trade.count == 0 || ar_post.count == 0 || ar_workExp.count == 0) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        [HDGlobalInfo instance].mar_area        = [HDJJUtility transformAreaInfoFromJson:ar_area];
        [HDGlobalInfo instance].mar_trade       = [HDJJUtility transformValueInfoFromJson:ar_trade];
        [HDGlobalInfo instance].mar_post        = [HDJJUtility transformPostInfoFromJson:ar_post];
        [HDGlobalInfo instance].mar_workExp     = [HDJJUtility transformValueInfoFromJson:ar_workExp];
        [HDGlobalInfo instance].mar_salary      = [HDJJUtility transformValueInfoFromJson:ar_salary];
        [HDGlobalInfo instance].mar_education   = [HDJJUtility transformValueInfoFromJson:ar_education];
        [HDGlobalInfo instance].mar_property    = [HDJJUtility transformValueInfoFromJson:ar_property];
        [HDGlobalInfo instance].mar_bank        = [HDJJUtility transformValueInfoFromJson:ar_bank];
        [HDGlobalInfo instance].mar_feedback    = dic[@"Feedback"];
        
        for (int i = 0; i < ar_area.count; i++) {
            NSMutableDictionary *mdic = ar_area[i];
            NSArray *items = mdic[@"Items"];
            if (items == nil || [items isKindOfClass:[NSNull class]]) {
                mdic[@"Items"] = @"";
                continue;
            }
            for (int j = 0; j < items.count; j++) {
                NSMutableDictionary *mdc = items[j];
                if (mdc[@"Items"] == nil || [mdc[@"Items"] isKindOfClass:[NSNull class]]) {
                    mdc[@"Items"] = @"";
                }
            }
        }
        Dlog(@"ar_area = %@", ar_area);
        NSMutableArray *mar__ = [[NSMutableArray alloc] initWithArray:ar_area];
        [mar__ removeObjectAtIndex:mar__.count - 1];
//        if (![mar__ writeToFile:PATH_PLIST_EARA atomically:YES]) {
//            Dlog(@"Error:write to file fale");
//        }
        
        for (int i = 0; i < ar_trade.count; i++) {
            NSMutableDictionary *mdc = ar_trade[i];
            mdc[@"Items"] = @"";
        }
//        if (![ar_trade writeToFile:PATH_PLIST_TRADE atomically:YES]) {
//            Dlog(@"Error:write to file fale");
//        }
        
        for (int i = 0; i < ar_post.count; i++) {
            NSMutableDictionary *dic = ar_post[i];
            NSArray *ar_items = dic[@"Items"];
            if (ar_items == nil || [ar_items isKindOfClass:[NSNull class]]) {
                dic[@"Items"] = @"";
                continue;
            }
            for (int j = 0; j < ar_items.count; j++) {
                NSMutableDictionary *mdc = ar_items[j];
                mdc[@"Items"] = @"";
            }
        }
//        if (![ar_post writeToFile:PATH_PLIST_POST atomically:YES]) {
//            Dlog(@"Error:write to file fale");
//        }
//        if (![ar_workExp writeToFile:PATH_PLIST_WORKEXP atomically:YES]) {
//            Dlog(@"Error:write to file fale");
//        }
        //[[HDGlobalInfo instance].mar_feedback writeToFile:PATH_PLIST_FEEDBACK atomically:YES];
        
        block(YES, sCode, @"获取全局参数成功", dic);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --意见反馈(Act603)
- (AFHTTPRequestOperation *)feedback:(HDUserInfo *)user content:(NSString *)content completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || content.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:content             forKey:@"Content"];
    AFHTTPRequestOperation *op = [self postServer:@"Act603" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"提交成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}


#pragma mark --获取荐友圈广告(Act604)
- (AFHTTPRequestOperation *)getAdvertisementBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block
{
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"        forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM    forKey:@"Platform"];
    [mdc_parameter setValue:VERSION     forKey:@"Version"];
    [mdc_parameter setValue:@"0"        forKey:@"Channel"];
    [mdc_parameter setValue:@"1"        forKey:@"moduletype"];
    AFHTTPRequestOperation *op = [self getServer:@"Act604" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSArray         *ar         = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !ar) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < ar.count; i++) {
            HDAdvertiseInfo *info =[HDAdvertiseInfo new];
            NSDictionary *d = ar[i];
            info.sDescription   = FORMAT(@"%@", [self isNull:d[@"Description"]]?    @"": d[@"Description"]);
            info.sImageUrl      = FORMAT(@"%@", [self isNull:d[@"ImageUrl"]]?       @"": d[@"ImageUrl"]);
            info.sOrderBy       = FORMAT(@"%@", [self isNull:d[@"OrderBy"]]?        @"": d[@"OrderBy"]);
            info.sUrl           = FORMAT(@"%@", [self isNull:d[@"Url"]]?            @"": d[@"Url"]);
            [mar addObject:info];
        }
        block(YES, sCode, @"更新成功", mar);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --获取全局变量(Act605)
- (AFHTTPRequestOperation *)getGlobalVariable:(void (^)(BOOL isSuccess, HDAddressInfo *info, NSString *sCode, NSString *sMessage))block
{
    AFHTTPRequestOperation *op = [self getServer:@"Act605" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSDictionary    *dic        = nil;
        HDAddressInfo   *address    = [HDAddressInfo new];
        dic         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, nil, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        address.sClientDownload     = FORMAT(@"%@", [self isNull:dic[@"CLIENTDOWNDRESS"]]?   @"": dic[@"CLIENTDOWNDRESS"]);
        address.sDataVersion        = FORMAT(@"%@", [self isNull:dic[@"DATAVERSION"]]?       @"": dic[@"DATAVERSION"]);
        address.sWebsite_waproot    = FORMAT(@"%@", [self isNull:dic[@"WEBSITE_WAPROOT"]]?   @"": dic[@"WEBSITE_WAPROOT"]);
        address.sWebsite_webroot    = FORMAT(@"%@", [self isNull:dic[@"WEBSITE_WEBROOT"]]?   @"": dic[@"WEBSITE_WEBROOT"]);
        address.sWebsite_approot    = FORMAT(@"%@", [self isNull:dic[@"WEBSITE_APPROOT"]]?   @"": dic[@"WEBSITE_APPROOT"]);
        address.sCloudsite_webroot  = FORMAT(@"%@", [self isNull:dic[@"CLOUDSITE_WEBROOT"]]? @"": dic[@"CLOUDSITE_WEBROOT"]);
        address.sLogo_shop          = FORMAT(@"%@", [self isNull:dic[@"LOGO_SHOP"]]?         @"": dic[@"LOGO_SHOP"]);
        address.sLogo_position      = FORMAT(@"%@", [self isNull:dic[@"LOGO_POSITION"]]?     @"": dic[@"LOGO_POSITION"]);
        address.sLogo_app           = FORMAT(@"%@", [self isNull:dic[@"LOGO_APP"]]?          @"": dic[@"LOGO_APP"]);
        
        NSMutableDictionary *mdc    = MDIC_PLIST;
        [mdc setObject:address.sClientDownload      forKey:@"sClientDownload"];
        [mdc setObject:address.sDataVersion         forKey:@"sDataVersion"];
        [mdc setObject:address.sCloudsite_webroot   forKey:@"sCloudsite_webroot"];
        [mdc setObject:address.sWebsite_waproot     forKey:@"sWebsite_waproot"];
        [mdc setObject:address.sWebsite_webroot     forKey:@"sWebsite_webroot"];
        [mdc setObject:address.sWebsite_approot     forKey:@"sWebsite_approot"];
        [mdc setObject:address.sLogo_shop           forKey:@"sLogo_shop"];
        [mdc setObject:address.sLogo_position       forKey:@"sLogo_position"];
        [mdc setObject:address.sLogo_app            forKey:@"sLogo_app"];
        [mdc writeToFile:PATH_PLIST_REGULAR atomically:YES];
        block(YES, address, sCode, @"获取成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --添加博客(Act801)
- (AFHTTPRequestOperation *)releaseBlog:(HDUserInfo *)user images:(NSArray *)ar content:(NSString *)content completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || ar.count > 3) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:content             forKey:@"content"];
    NSMutableURLRequest *request =[self multipartFormRequestWithMethod:@"post" path:@"Act801" parameters:mdc_parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < ar.count; i++) {
            NSData *data           = UIImagePNGRepresentation(ar[i]);
            NSString *fileName     = FORMAT(@"%d.png", arc4random());
            [formData appendPartWithFileData:data name:@"PicID" fileName:fileName mimeType:@"image/png"];
        }
    }];
    AFHTTPRequestOperation *opration = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Act801 json ===%@",operation.responseString);
        Dlog(@"Act801 request http = %@", operation.response.URL);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act801 returned dic = %@" , dic);
        if (!dic) {
            block(NO, nil, @"网络出错，请稍后再试" , nil);
            return;
        }
        NSString *sCode         = FORMAT(@"%@", !dic[@"Code"]?           @"": dic[@"Code"]);
        NSString *sResult       = FORMAT(@"%@", !dic[@"Result"]?         @"": dic[@"Result"]);
        NSString *sErrorDesc    = FORMAT(@"%@", !dic[@"ErrorDesc"]?      @"上传失败": dic[@"ErrorDesc"]);
        if ([sCode isEqualToString:@"0"]) {
            block(YES, sCode, @"发布成功", sResult);
            return;
        }else{
            block(NO, sCode, sErrorDesc, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"网络请求失败->%@", error);
        block(NO, FORMAT(@"%d", (int)error.code), @"网络请求失败", nil);
    }];
    [opration start];
    return opration;
}

#pragma mark --获取朋友圈博客列表(Act802)
- (AFHTTPRequestOperation *)getBlogList:(HDUserInfo *)user pageIndex:(int)index size:(int)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *lists))block
{
    NSMutableDictionary *mdc_parameter = nil;
    if (user.sHumanNo.length > 0) {
        mdc_parameter = [[NSMutableDictionary alloc] init];
        [mdc_parameter setValue:@"1"                forKey:@"Source"];
        [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
        [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
        [mdc_parameter setValue:VERSION             forKey:@"Version"];
        [mdc_parameter setValue:@"0"                forKey:@"Channel"];
        [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
        [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
        [mdc_parameter setValue:user.sHumanNo        forKey:@"userno"];
        [mdc_parameter setValue:FORMAT(@"%d", index)forKey:@"pageIndex"];
        [mdc_parameter setValue:FORMAT(@"%d", size) forKey:@"pageSize"];
    }
    AFHTTPRequestOperation *op = [self getServer:@"Act802" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        NSMutableArray *mar = [NSMutableArray new];
        BOOL isLast = FORMAT(@"%@", [self isNull:dic[@"IsLastPage"]]? @"0": dic[@"IsLastPage"]).boolValue;
        NSArray *ar = dic[@"List"];
        if (!ar) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *d = ar[i];
            if (![d isKindOfClass:[NSDictionary class]]) {
                Dlog(@"服务器数据有误");
                continue;
            }
            HDBlogInfo *blog    = [HDBlogInfo new];
            blog.sBlogId        = FORMAT(@"%@", [self isNull:d[@"ID"]]?             @"": d[@"ID"]);
            blog.sAuthorId      = FORMAT(@"%@", [self isNull:d[@"UserID"]]?         @"": d[@"UserID"]);
            blog.sAuthorAvatar  = FORMAT(@"%@", [self isNull:d[@"Avatar"]]?         @"": d[@"Avatar"]);
            blog.sAuthorName    = FORMAT(@"%@", [self isNull:d[@"NickName"]]?       @"": d[@"NickName"]);
            blog.sQuoteCount    = FORMAT(@"%@", [self isNull:d[@"QuoteCount"]]?     @"": d[@"QuoteCount"]);
            blog.sCommentCount  = FORMAT(@"%@", [self isNull:d[@"CommentCount"]]?   @"": d[@"CommentCount"]);
            blog.sCollectCount  = FORMAT(@"%@", [self isNull:d[@"CollectCount"]]?   @"": d[@"CollectCount"]);
            blog.sCreateTime    = FORMAT(@"%@", [self isNull:d[@"CreateTime"]]?     @"": d[@"CreateTime"]);
            blog.sLikeCount     = FORMAT(@"%@", [self isNull:d[@"LikeCount"]]?      @"": d[@"LikeCount"]);
            blog.isLike         = FORMAT(@"%@", [self isNull:d[@"IsLike"]]?         @"": d[@"IsLike"]).boolValue;
            blog.isCollect      = FORMAT(@"%@", [self isNull:d[@"IsCollect"]]?      @"": d[@"IsCollect"]).boolValue;
            blog.isTop          = FORMAT(@"%@", [self isNull:d[@"IsTop"]]?          @"": d[@"IsTop"]).boolValue;
            blog.isAttention    = FORMAT(@"%@", [self isNull:d[@"IsAttention"]]?    @"": d[@"IsAttention"]).boolValue;
            blog.blogType       = FORMAT(@"%@", [self isNull:d[@"TypeID"]]?         @"": d[@"TypeID"]).integerValue;
            HDBlogTextInfo *blogText = [HDBlogTextInfo new];
            NSDictionary *d_text    = d[@"BlogText"];
            if (d_text) {
                blogText.sText  = FORMAT(@"%@", [self isNull:d_text[@"Text"]]? @"": d_text[@"Text"]);
                NSArray *ar_pic = d_text[@"PicIDs"];
                blogText.ar_picUrls = ar_pic? ar_pic: [NSArray new];
            }
            blog.blogTextInfo       = blogText;
            NSArray *ar_p           = d[@"PositionText"];
            NSMutableArray *mar_p   = [NSMutableArray new];
            if (ar_p) {
                for (int i = 0; i < ar_p.count; i++) {
                    WJPositionInfo *p   = [WJPositionInfo new];
                    NSDictionary *dp    = ar_p[i];
                    p.sPositionNo       = FORMAT(@"%@", [self isNull:dp[@"PositionNo"]]?    @"": dp[@"PositionNo"]);
                    p.sPositionName     = FORMAT(@"%@", [self isNull:dp[@"PositionName"]]?  @"": dp[@"PositionName"]);
                    p.sAreaText         = FORMAT(@"%@", [self isNull:dp[@"WorkPlace"]]?     @"": dp[@"WorkPlace"]);
                    p.sSalaryText       = FORMAT(@"%@", [self isNull:dp[@"SalaryText"]]?    @"": dp[@"SalaryText"]);
                    p.sRemark           = FORMAT(@"%@", [self isNull:dp[@"Reward"]]?        @"": dp[@"Reward"]);
                    p.employerInfo.sName    = FORMAT(@"%@", [self isNull:dp[@"CompanyName"]]?   @"": dp[@"CompanyName"]);
                    p.employerInfo.sRemark  = FORMAT(@"%@", [self isNull:dp[@"ComDesc"]]?       @"": dp[@"ComDesc"]);
                    NSArray *ar         = [self isNull:dp[@"PicIDs"]]? [NSArray new]: dp[@"PicIDs"];
                    p.employerInfo.mar_urls          = [[NSMutableArray alloc] initWithArray:ar];
                    [mar_p addObject:p];
                }
            }
            blog.ar_positions            = mar_p;
            
            NSArray *ar_talent          = d[@"ResumeText"];
            NSMutableArray *mar_talent  = [NSMutableArray new];
            if (ar_talent) {
                for (int i = 0; i < ar_talent.count; i++) {
                    HDTalentInfo *talent    = [HDTalentInfo new];
                    NSDictionary *dt        = ar_talent[i];
                    talent.sHumanNo         = FORMAT(@"%@", [self isNull:dt[@"ResumeNo"]]?      @"": dt[@"ResumeNo"]);
                    talent.sName            = FORMAT(@"%@", [self isNull:dt[@"Name"]]?          @"": dt[@"Name"]);
                    talent.sCurCompanyName  = FORMAT(@"%@", [self isNull:dt[@"CompanyName"]]?   @"": dt[@"CompanyName"]);
                    talent.sSexText         = FORMAT(@"%@", [self isNull:dt[@"Sex"]]?           @"": dt[@"Sex"]);
                    talent.sCurPosition     = FORMAT(@"%@", [self isNull:dt[@"Position"]]?      @"": dt[@"Position"]);
                    talent.sAreaText        = FORMAT(@"%@", [self isNull:dt[@"Location"]]?      @"": dt[@"Location"]);
                    talent.sEduLevel        = FORMAT(@"%@", [self isNull:dt[@"EduLevel"]]?      @"": dt[@"EduLevel"]);
                    talent.sWorkYears       = FORMAT(@"%@", [self isNull:dt[@"WorkExp"]]?       @"": dt[@"WorkExp"]);
                    talent.sServiceFee      = FORMAT(@"%@", [self isNull:dt[@"ServiceFee"]]?    @"": dt[@"ServiceFee"]);
                    [mar_talent addObject:talent];
                }
               
            }
            blog.ar_talents                 = mar_talent;
            [mar addObject:blog];
        }
        block(YES, sCode, @"更新成功", isLast, mar);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark --收藏博客(Act806)
- (AFHTTPRequestOperation *)collectBlog:(HDUserInfo *)user blog:(NSString *)blogId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || blogId.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:blogId              forKey:@"bid"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act806" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act806 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act806 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark --分享博文、职位、简历到荐友圈(Act808)
- (AFHTTPRequestOperation *)shared2Blog:(HDUserInfo *)user positionId:(NSString *)pId resumeId:(NSString *)rId type:(int)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || type < 1 || type > 2) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:pId                 forKey:@"posID"];
    [mdc_parameter setValue:rId                 forKey:@"resumeID"];
    [mdc_parameter setValue:@(type)             forKey:@"typeID"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act808" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act808 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act808 json = %@", JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"发布成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}


#pragma mark -
/******************************************************************************************
 
                                        华丽的分割线
 
 *******************************************************************************************/
#pragma mark -- 查询公司名称QueryEnterpriseName)
- (AFHTTPRequestOperation *)queryForCompanyName:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block
{
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:name forKey:@"name"];
    AFHTTPRequestOperation *op = [self getServer:@"QueryEnterpriseName" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSMutableArray  *mar            = [NSMutableArray new];
        NSMutableArray  *mar_company    =[NSMutableArray new];
        mar         = [JSON objectForKey:@"Result"];
        Dlog(@"mar = %@", mar);
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i < mar.count; i++) {
            NSDictionary *dic = mar[i];
            HDCompanyInfo *info = [HDCompanyInfo new];
            info.sId            = FORMAT(@"%@", [self isNull:dic[@"ID"]]?    @"": dic[@"ID"]);
            info.sName          = FORMAT(@"%@", [self isNull:dic[@"Name"]]?  @"": dic[@"Name"]);
            [mar_company addObject:info];
        }
        block(YES, sCode, @"更新成功", mar_company);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 导入职位-根据公司ID查询职位列表(GetPositions)
- (AFHTTPRequestOperation *)queryForPositionList:(NSString *)enterpriceId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block
{
    if (enterpriceId.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:enterpriceId forKey:@"enterpriseID"];
    
    AFHTTPRequestOperation *op = [self getServer:@"GetPositions" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSMutableArray  *mar            = [NSMutableArray new];
        NSMutableArray  *mar_company    =[NSMutableArray new];
        mar         = [JSON objectForKey:@"Result"];
        Dlog(@"mar = %@", mar);
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i < mar.count; i++) {
            NSDictionary *dic = mar[i];
            HDIMPositionInfo *info = [HDIMPositionInfo new];
            info.sId            = FORMAT(@"%@", [self isNull:dic[@"ID"]]?            @"": dic[@"ID"]);
            info.sName          = FORMAT(@"%@", [self isNull:dic[@"Name"]]?          @"": dic[@"Name"]);
            info.sAreaText      = FORMAT(@"%@", [self isNull:dic[@"AreaText"]]?      @"": dic[@"AreaText"]);
            info.sEducation     = FORMAT(@"%@", [self isNull:dic[@"Education"]]?     @"": dic[@"Education"]);
            info.sPublishTime   = FORMAT(@"%@", [self isNull:dic[@"PublishTime"]]?   @"": dic[@"PublishTime"]);
            info.sWorkTime      = FORMAT(@"%@", [self isNull:dic[@"WorkTime"]]?      @"": dic[@"WorkTime"]);
            info.isSelected     = NO;
            [mar_company addObject:info];
        }
        block(YES, sCode, @"更新成功", mar_company);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 导入职位描述-根据职位名称模糊匹配职位(QueryPositionName)
- (AFHTTPRequestOperation *)queryForPositionNames:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block
{
    if (name.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:name forKey:@"name"];
    
    AFHTTPRequestOperation *op = [self getServer:@"QueryPositionName" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@", JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSMutableArray  *mar            = [NSMutableArray new];
        NSMutableArray  *mar_company    =[NSMutableArray new];
        mar         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i < mar.count; i++) {
            if (![mar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p        = mar[i];
            HDSearchPositionNameInfo *position    = [HDSearchPositionNameInfo new];
            
            position.sId    = FORMAT(@"%@", ([self isNull:dic_p[@"ID"]]?    @"": dic_p[ @"ID"]));
            position.sName  = FORMAT(@"%@", ([self isNull:dic_p[@"Name"]]?  @"": dic_p[@"Name"]));
            [mar_company addObject:position];
        }
        block(YES, sCode, @"更新成功", mar_company);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 导入职位描述-根据职位名称关键字查询职位列表(QueryPositionDesc)
- (AFHTTPRequestOperation *)queryForPositions:(NSString *)name completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar))block
{
    if (name.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:name forKey:@"name"];
    
    AFHTTPRequestOperation *op = [self getServer:@"QueryPositionDesc" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSMutableArray  *mar            = [NSMutableArray new];
        NSMutableArray  *mar_company    =[NSMutableArray new];
        mar         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i < mar.count; i++) {
            if (![mar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p         = mar[i];
            WJPositionInfo *position    = [WJPositionInfo new];
            position.sPositionNo        = FORMAT(@"%@", ([self isNull:dic_p[@"ID"]]?                @"": dic_p[@"ID"]));
            position.sPositionName      = FORMAT(@"%@", ([self isNull:dic_p[@"Name"]]?              @"": dic_p[@"Name"]));
            position.sArea              = FORMAT(@"%@", ([self isNull:dic_p[@"AreaCode"]]?          @"": dic_p[@"AreaCode"]));
            position.sAreaText          = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?          @"": dic_p[@"AreaText"]));
            position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionCode"]]?      @"": dic_p[@"FunctionCode"]));
            position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?      @"": dic_p[@"FunctionText"]));
            position.sSalaryCode        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryCode"]]?        @"": dic_p[@"SalaryCode"]));
            position.sSalaryText        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryText"]]?        @"": dic_p[@"SalaryText"]));
            position.sWorkExpCode       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkTimeCode"]]?      @"": dic_p[@"WorkTimeCode"]));
            position.sWorkExpText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkTimeText"]]?      @"": dic_p[@"WorkTimeText"]));
            position.sEducationCode     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationCode"]]?     @"": dic_p[@"EducationCode"]));
            position.sEducationText     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationText"]]?     @"": dic_p[@"EducationText"]));
            position.sRemark            = FORMAT(@"%@", ([self isNull:dic_p[@"Desc"]]?              @"": dic_p[@"Desc"]));
            position.sRemark = [position changeBr2n:position.sRemark];
            position.employerInfo.sRemark = [position changeBr2n:position.employerInfo.sRemark];
            [mar_company addObject:position];
        }
        block(YES, sCode, @"更新成功", mar_company);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}
#pragma mark **************************************************************************************
#pragma mark -- 吴健
#pragma mark **************************************************************************************
/******************************************************************************************
 
                                            吴健
 
 *******************************************************************************************/
#pragma mark -
#pragma mark -- 第三方登录(Act116)
- (AFHTTPRequestOperation *)getThirdPartLogin:(NSString *)openAuth openUserID:(NSString *)userId openToken:(NSString *)token completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDUserInfo *user))block{
    if (openAuth.length == 0 || userId.length == 0 || token.length == 0) {
            block(NO, nil, @"传入参数有误", nil);
            Dlog(@"传入参数有误");
            return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:openAuth            forKey:@"openAuth"];
    [mdc_parameter setValue:userId              forKey:@"openUserID"];
    [mdc_parameter setValue:token               forKey:@"openToken"];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act116" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act102 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSDictionary    *dic        = nil;
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        HDUserInfo      *userInfo   = [HDUserInfo new];
        
        dic         = [JSON objectForKey:@"Result"];
        sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
        sErrDesc    = FORMAT(@"%@", [JSON objectForKey:@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"登录失败，请稍后再试": sErrDesc), nil);
            return;
        }
        userInfo.sHumanNo       = FORMAT(@"%@", [self isNull:dic[@"UserID"]]?       @"": dic[@"UserID"]);
        userInfo.sName          = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?     @"": dic[@"NickName"]);
        userInfo.sMemberLevel   = FORMAT(@"%@", [self isNull:dic[@"Level"]]?        @"": dic[@"Level"]);
        userInfo.isPerfect      = [FORMAT(@"%@",[self isNull:dic[@"IsPerfect"]]?    @"0": dic[@"IsPerfect"]) boolValue];
        userInfo.sAvatarUrl     = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?       @"": dic[@"Avatar"]);
        userInfo.sTocken        = FORMAT(@"%@", [self isNull:dic[@"Token"]]?        @"": dic[@"Token"]);
        userInfo.sRoleType      = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?     @"": dic[@"RoleType"]);
        userInfo.sTocken1       = FORMAT(@"%@", [self isNull:dic[@"Token1"]]?       @"": dic[@"Token1"]);
        userInfo.sAnnounce      = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?     @"": dic[@"Announce"]);
        userInfo.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?      @"": dic[@"Approve"]);
        userInfo.sAuthenCompany = FORMAT(@"%@", [self isNull:dic[@"AuthenCompany"]]?@"": dic[@"AuthenCompany"]);
        userInfo.sAuthenPosition= FORMAT(@"%@", [self isNull:dic[@"AuthenPosition"]]?@"": dic[@"AuthenPosition"]);
        userInfo.sBackground    = FORMAT(@"%@", [self isNull:dic[@"Background"]]?   @"": dic[@"Background"]);
        userInfo.sTradeKey      = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]? @"": dic[@"BusinessCode"]);
        userInfo.sTradeText     = FORMAT(@"%@", [self isNull:dic[@"BusinessText"]]? @"": dic[@"BusinessText"]);
        userInfo.sQQ            = FORMAT(@"%@", [self isNull:dic[@"CODE_QQ"]]?      @"": dic[@"CODE_QQ"]);
        userInfo.sWeixin        = FORMAT(@"%@", [self isNull:dic[@"CODE_WX"]]?      @"": dic[@"CODE_WX"]);
        userInfo.sCurCompany    = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?   @"": dic[@"CurCompany"]);
        userInfo.sCurPosition   = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?  @"": dic[@"CurPosition"]);
        userInfo.sPostKey       = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]? @"": dic[@"FunctionCode"]);
        userInfo.sPostText      = FORMAT(@"%@", [self isNull:dic[@"FunctionText"]]? @"": dic[@"FunctionText"]);
        userInfo.sHXResStatus   = FORMAT(@"%@", [self isNull:dic[@"HXResStatus"]]?  @"": dic[@"HXResStatus"]);
        userInfo.isFocus        = FORMAT(@"%@", [self isNull:dic[@"IsFocus"]]?      @"": dic[@"IsFocus"]).boolValue;
        userInfo.isPerfect      = FORMAT(@"%@", [self isNull:dic[@"IsPerfect"]]?    @"": dic[@"IsPerfect"]).boolValue;
        userInfo.sPhone         = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?       @"": dic[@"MPhone"]);
        userInfo.sShopName      = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?     @"": dic[@"ShopName"]);
        userInfo.sStartWorkDT   = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?  @"": dic[@"StartWorkDT"]);
        userInfo.sAreaKey       = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceCode"]]?@"": dic[@"WorkPlaceCode"]);
        userInfo.sAreaText      = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceText"]]?@"": dic[@"WorkPlaceText"]);
        userInfo.sWorkYears     = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?    @"": dic[@"WorkYears"]);        
        block(YES, sCode, @"登录成功", userInfo);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, @"请求数据失败，请检查网络！", nil);
    }];
    return op;

}

#pragma mark -- 第三方注册(Act117)
- (AFHTTPRequestOperation *)thirdPartyRegisterWithMobile:(NSString *)mobile openUserId:(NSString *)uid openToken:(NSString *)token nickName:(NSString *)name validCode:(NSString *)code openAuth:(NSString *)auth CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage))block{
    
    Dlog(@"%d----uid:%@----token:---%@----name:%@====code:%@----auth:%@",![HDUtility isValidateMobile:mobile],uid,token,name,code,auth);
    if (![HDUtility isValidateMobile:mobile] || uid.length == 0 || token.length == 0 || name.length == 0 || code.length == 0 || auth.length == 0) {
        Dlog(@"传入参数有误");
        block(NO, nil, nil, @"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];

    [mdc_parameter setValue:auth                    forKey:@"openAuth"];
    [mdc_parameter setValue:uid                     forKey:@"openUserID"];
    [mdc_parameter setValue:token                   forKey:@"openToken"];
    [mdc_parameter setValue:name                    forKey:@"nickName"];
    [mdc_parameter setValue:FORMAT(@"%@", mobile)   forKey:@"mobile"];
    [mdc_parameter setValue:code                    forKey:@"validCode"];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act117" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act117 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act117 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, nil, @"网络出错，请稍后再试");
            return;
        }
        NSDictionary    *dic        = nil;
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        HDUserInfo      *userInfo   = [HDUserInfo new];
        if(JSON != [NSNull class]){
            dic         = [JSON objectForKey:@"Result"];
            sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
            sErrDesc    = FORMAT(@"%@", [JSON objectForKey:@"ErrorDesc"]);
            if (![sCode isEqualToString:@"0"]) {
                block(NO, sCode, userInfo, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
                return;
            }
            userInfo.sHumanNo        = FORMAT(@"%@", (dic[@"UserID"]     == nil? @"": dic[@"UserID"]));
            userInfo.sName      = FORMAT(@"%@", dic[@"NickName"]    == nil? @"": dic[@"NickName"]);
            userInfo.sMemberLevel   = FORMAT(@"%@", (dic[@"Level"]      == nil? @"": dic[@"Level"]));
            userInfo.sApprove       = FORMAT(@"%@", (dic[@"Approve"]    == nil? @"": dic[@"Approve"]));
            userInfo.sShopName      = FORMAT(@"%@", (dic[@"ShopName"]   == nil? @"": dic[@"ShopName"]));
            userInfo.sTocken        = FORMAT(@"%@", (dic[@"Token"]      == nil? @"": dic[@"Token"]));
            userInfo.sTocken1       = FORMAT(@"%@", (dic[@"Token1"]     == nil? @"": dic[@"Token1"]));
            userInfo.isPerfect      = [dic[@"IsPerfect"] boolValue];
        }
        block(YES, sCode, userInfo, @"注册成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, nil, @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark -- 第三方账号绑定(Act118)
- (AFHTTPRequestOperation *)thirdPartyBoundWithPhone:(NSString *)openAuth openUserId:(NSString *)uid openToken:(NSString *)token CompletionBlock:(void (^)(BOOL isSuccess, NSString *msgCode, NSString *sMessage))block{
    if (openAuth.length == 0 || uid.length == 0 || token.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"4"        forKey:@"openAuth"];
    [mdc_parameter setValue:uid         forKey:@"openUserID"];
    [mdc_parameter setValue:token       forKey:@"openToken"];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act118" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act118 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"：Act118 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, nil, (sErrDesc.length == 0? @"登录失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"请求发送验证码成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, @"请求数据失败，请检查网络！");
    }];
    return op;

}

#pragma mark -- 获取荐客信息(Act124)
- (AFHTTPRequestOperation *)getBrokerInfo:(HDUserInfo *)user userno:(NSString *)userno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info))block{
    if ( userno.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:userno              forKey:@"userno"];
    AFHTTPRequestOperation *op = [self getServer:@"Act124" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act124 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act124 json = %@==%@" ,JSON, JSON[@"ErrorDesc"]);
        if (!JSON) {
            block(NO, nil, @"网络出错,请稍后再试", nil);
            return ;
        }
        NSString       *sCode             = nil;
        NSString       *sErrDesc          = nil;
        NSDictionary   *dic               = nil;
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]      == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@",([JSON objectForKey:@"ErrorDesc"] == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        dic         = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败,请稍后再试": sErrDesc), nil);
            return;
        }
        WJBrokerInfo *info  = [WJBrokerInfo new];
        info.sAreaKey        = FORMAT(@"%@", [self isNull:dic[@"AreaCode"]]?         @"": dic[@"AreaCode"]);
        info.sAreaText       = FORMAT(@"%@", [self isNull:dic[@"AreaText"]]?         @"": dic[@"AreaText"]);
        info.sAvatarUrl      = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?           @"": dic[@"Avatar"]);
        info.sBackground     = FORMAT(@"%@", [self isNull:dic[@"Background"]]?       @"": dic[@"Background"]);
        info.sTradeKey       = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]?     @"": dic[@"BusinessCode"]);
        info.sTradeText      = FORMAT(@"%@", [self isNull:dic[@"BusinessText"]]?     @"": dic[@"BusinessText"]);
        info.sCreatedDT      = FORMAT(@"%@", [self isNull:dic[@"CreatedDT"]]?        @"": dic[@"CreatedDT"]);
        info.sCurCompany     = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?       @"": dic[@"CurCompany"]);
        info.sCurPosition    = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?      @"": dic[@"CurPosition"]);
        info.sPostKey        = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]?     @"": dic[@"FunctionCode"]);
        info.sPostText       = FORMAT(@"%@", [self isNull:dic[@"FunctionText"]]?     @"": dic[@"FunctionText"]);
        info.sName           = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?         @"": dic[@"NickName"]);
        info.sProperty       = FORMAT(@"%@", [self isNull:dic[@"Property"]]?         @"": dic[@"Property"]);
        info.sRemark         = FORMAT(@"%@", [self isNull:dic[@"Remark"]]?           @"": dic[@"Remark"]);
        info.sStartWorkDT    = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?      @"": dic[@"StartWorkDT"]);
        info.sHumanNo        = FORMAT(@"%@", [self isNull:dic[@"UserNo"]]?           @"": dic[@"UserNo"]);
        info.sWorkYears      = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?        @"": dic[@"WorkYears"]);
        info.sShopMPhone     = FORMAT(@"%@", [self isNull:dic[@"ShopMPhone"]]?       @"": dic[@"ShopMPhone"]);
        info.sShopType       = FORMAT(@"%@", [self isNull:dic[@"ShopType"]]?         @"": dic[@"ShopType"]);
        info.sAnnounce       = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?         @"": dic[@"Announce"]);
        info.sShopName       = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?         @"": dic[@"ShopName"]);
        info.sAuthenCompany  = FORMAT(@"%@", [self isNull:dic[@"AuthenCompany"]]?    @"": dic[@"AuthenCompany"]);
        info.sAuthenPosition = FORMAT(@"%@", [self isNull:dic[@"AuthenPosition"]]?   @"": dic[@"AuthenPosition"]);
        info.sMemberLevel    = FORMAT(@"%@", [self isNull:dic[@"MemberLevel"]]?      @"": dic[@"MemberLevel"]);
        info.sRoleType       = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?         @"": dic[@"RoleType"]);
        info.isFocus         = [dic[@"IsFocus"]          boolValue];
        info.sName           = info.sName.length == 0? info.sShopName: info.sName;
        info.sShopMPhone     = FORMAT(@"%@", [self isNull:dic[@"ShopMPhone"]]?       @"": dic[@"ShopMPhone"]);
        info.sPhone          = info.sShopMPhone;
        block(YES, sCode, @"更新成功", info);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 关注用户 (Act131)
- (AFHTTPRequestOperation *)attentionUser:(HDUserInfo *)user usernos:(NSString *)usernos isfocus:(NSString *)isfocus completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block{
    if (usernos == nil) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:usernos forKey:@"usernos"];
    [mdc_parameter setValue:isfocus forKey:@"isfocus"];
    AFHTTPRequestOperation *op = [self getServer:@"Act131" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act131 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@", JSON);
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试");
            return ;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"关注成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark -- 查找荐客列表（Act132）
- (AFHTTPRequestOperation *)getBrokerList:(HDUserInfo *)user dic:(NSDictionary *)dic pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *brokers))block{
    if ( [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:index               forKey:@"pageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    if ([HDGlobalInfo instance].hasLogined) {
        [mdc_parameter setValue:user.sHumanNo   forKey:@"UserID"];
        [mdc_parameter setValue:user.sTocken    forKey:@"Token"];
    }
    AFHTTPRequestOperation *op = [self getServer:@"Act132" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act132 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@==%@" ,JSON, JSON[@"ErrorDesc"]);
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试",NO,nil);
            return ;
        }
        NSString       *sCode             = nil;
        NSString       *sErrDesc          = nil;
        NSDictionary   *dic               = nil;
        NSMutableArray *mar_brokers       = [NSMutableArray new];
        BOOL           isLast             = NO;
        
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]      == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@",([JSON objectForKey:@"ErrorDesc"] == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        dic         = [JSON objectForKey:@"Result"];
        isLast      = [dic[@"IsLastPage"] boolValue];
        NSArray *ar = dic[@"Positions"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO,sCode,(sErrDesc.length == 0? @"获取数据失败,请稍后再试": sErrDesc), NO, nil);
            return;
        }
        if (!dic[@"IsLastPage"]) {
            block(YES,sCode, @"获取数据失败", NO, nil);
            return;
        }
        if (!ar) {
            block(YES,sCode, @"获取数据失败", NO, nil);
            return;
        }
        
        for (int i = 0; i < ar.count; i++) {
           NSDictionary *dic    = ar[i];
            WJBrokerInfo *info   = [WJBrokerInfo new];
            info.sAreaText       = FORMAT(@"%@", [self isNull:dic[@"AreaText"]]?         @"": dic[@"AreaText"]);
            info.sAvatarUrl      = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?           @"": dic[@"Avatar"]);
            info.sBackground     = FORMAT(@"%@", [self isNull:dic[@"Background"]]?       @"": dic[@"Background"]);
            info.sTradeKey       = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]?     @"": dic[@"BusinessCode"]);
            info.sTradeText      = FORMAT(@"%@", [self isNull:dic[@"BusinessText"]]?     @"": dic[@"BusinessText"]);
            info.sCreatedDT      = FORMAT(@"%@", [self isNull:dic[@"CreatedDT"]]?        @"": dic[@"CreatedDT"]);
            info.sCurCompany     = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?       @"": dic[@"CurCompany"]);
            info.sCurPosition    = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?      @"": dic[@"CurPosition"]);
            info.sPostKey        = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]?     @"": dic[@"FunctionCode"]);
            info.sPostText       = FORMAT(@"%@", [self isNull:dic[@"FunctionText"]]?     @"": dic[@"FunctionText"]);
            info.sName       = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?         @"": dic[@"NickName"]);
            info.sProperty       = FORMAT(@"%@", [self isNull:dic[@"Property"]]?         @"": dic[@"Property"]);
            info.sRemark         = FORMAT(@"%@", [self isNull:dic[@"Remark"]]?           @"": dic[@"Remark"]);
            info.sStartWorkDT    = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?      @"": dic[@"StartWorkDT"]);
            info.sHumanNo         = FORMAT(@"%@", [self isNull:dic[@"UserNo"]]?           @"": dic[@"UserNo"]);
            info.sWorkYears      = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?        @"": dic[@"WorkYears"]);
            info.sShopMPhone     = FORMAT(@"%@", [self isNull:dic[@"ShopMPhone"]]?       @"": dic[@"ShopMPhone"]);
            info.sShopType       = FORMAT(@"%@", [self isNull:dic[@"ShopType"]]?         @"": dic[@"ShopType"]);
            
            info.sAnnounce       = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?         @"": dic[@"Announce"]);
            info.sShopName       = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?         @"": dic[@"ShopName"]);
            info.sAuthenCompany  = FORMAT(@"%@", [self isNull:dic[@"AuthenCompany"]]?    @"": dic[@"AuthenCompany"]);
            info.sAuthenPosition = FORMAT(@"%@", [self isNull:dic[@"AuthenPosition"]]?   @"": dic[@"AuthenPosition"]);
            info.sMemberLevel    = FORMAT(@"%@", [self isNull:dic[@"MemberLevel"]]?      @"": dic[@"MemberLevel"]);
            info.sRoleType       = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?         @"": dic[@"RoleType"]);
            info.isFocus         = [dic[@"IsFocus"]          boolValue];

            [mar_brokers addObject:info];
        }
        
        block(YES, sCode, @"更新成功", isLast, mar_brokers);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark -- 获取联系人列表 (Act139)
- (AFHTTPRequestOperation *)getLinkmanList:(HDUserInfo *)user contacttype:(NSString *)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *list))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || type.length == 0 ) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:type                forKey:@"contacttype"];

    AFHTTPRequestOperation *op = [self getServer:@"Act139" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act139 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@==%@" ,JSON, JSON[@"ErrorDesc"]);
        if (!JSON) {
            block(NO, nil, @"网络出错,请稍后再试", nil);
            return ;
        }
        NSString       *sCode             = nil;
        NSString       *sErrDesc          = nil;
        NSMutableArray *mar_brokers       = [NSMutableArray new];
        
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]      == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@",([JSON objectForKey:@"ErrorDesc"] == nil? @"": [JSON objectForKey:@"ErrorDesc"]));

        NSArray *ar = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败,请稍后再试": sErrDesc),  nil);
            return;
        }
        if (!ar) {
            block(YES, sCode, @"获取数据失败", nil);
            return;
        }
        
        for (int i = 0; i < ar.count; i++) {
            NSDictionary *dic    = ar[i];
            WJLinkmanListInfo *info   = [WJLinkmanListInfo new];
            info.sUserID        = FORMAT(@"%@", [self isNull:dic[@"UserID"]]?           @"": dic[@"UserID"]);
            info.sNickName      = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?         @"": dic[@"NickName"]);
            info.sLevel         = FORMAT(@"%@", [self isNull:dic[@"Level"]]?            @"": dic[@"Level"]);
            info.sApprove       = FORMAT(@"%@", [self isNull:dic[@"Approve"]]?          @"": dic[@"Approve"]);
            info.sAvatar        = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?           @"": dic[@"Avatar"]);
            info.sShopName      = FORMAT(@"%@", [self isNull:dic[@"ShopName"]]?         @"": dic[@"ShopName"]);
            info.sToken         = FORMAT(@"%@", [self isNull:dic[@"Token"]]?            @"": dic[@"Token"]);
            info.sToken1        = FORMAT(@"%@", [self isNull:dic[@"Token1"]]?           @"": dic[@"Token1"]);
            info.sBackground    = FORMAT(@"%@", [self isNull:dic[@"Background"]]?       @"": dic[@"Background"]);
            info.sFunctionCode  = FORMAT(@"%@", [self isNull:dic[@"FunctionCode"]]?     @"": dic[@"FunctionCode"]);
            info.sBusinessCode  = FORMAT(@"%@", [self isNull:dic[@"BusinessCode"]]?     @"": dic[@"BusinessCode"]);
            info.sWorkPlaceCode = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceCode"]]?    @"": dic[@"WorkPlaceCode"]);
            info.sStartWorkDT   = FORMAT(@"%@", [self isNull:dic[@"StartWorkDT"]]?      @"": dic[@"StartWorkDT"]);
            info.sWorkYears     = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?        @"": dic[@"WorkYears"]);
            info.CODE_WX        = FORMAT(@"%@", [self isNull:dic[@"CODE_WX"]]?          @"": dic[@"CODE_WX"]);
            info.CODE_QQ        = FORMAT(@"%@", [self isNull:dic[@"CODE_QQ"]]?          @"": dic[@"CODE_QQ"]);
            info.sMPhone        = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?           @"": dic[@"MPhone"]);
            info.sCurPosition   = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?      @"": dic[@"CurPosition"]);
            info.sCurCompany    = FORMAT(@"%@", [self isNull:dic[@"CurCompany"]]?       @"": dic[@"CurCompany"]);
            info.sHXResStatus   = FORMAT(@"%@", [self isNull:dic[@"HXResStatus"]]?      @"": dic[@"HXResStatus"]);
            info.sAnnounce      = FORMAT(@"%@", [self isNull:dic[@"Announce"]]?         @"": dic[@"Announce"]);
            info.sAuthenCompany = FORMAT(@"%@", [self isNull:dic[@"AuthenCompany"]]?    @"": dic[@"AuthenCompany"]);
            info.sAuthenPosition= FORMAT(@"%@", [self isNull:dic[@"AuthenPosition"]]?   @"": dic[@"AuthenPosition"]);
            info.sFunctionText  = FORMAT(@"%@", [self isNull:dic[@"FunctionText"]]?     @"": dic[@"FunctionText"]);
            info.sBusinessText  = FORMAT(@"%@", [self isNull:dic[@"BusinessText"]]?     @"": dic[@"BusinessText"]);
            info.sWorkPlaceText = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceText"]]?    @"": dic[@"WorkPlaceText"]);
            info.sRoleType      = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?         @"": dic[@"RoleType"]);
            info.IsPerfect      = [dic[@"IsPerfect"]    boolValue];
            info.IsFocus        = [dic[@"IsFocus"]      boolValue];
            [mar_brokers addObject:info];
        }
        
        block(YES, sCode, @"更新成功", mar_brokers);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;

}

#pragma mark -- 第三方注册完善个人资料(Act140)
- (AFHTTPRequestOperation *)presetThirdPartyUserInfo:(HDUserInfo *)user parameters:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !dic || dic.count < 6) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:dic[@"post"]        forKey:@"functionCode"];
    [mdc_parameter setValue:dic[@"trade"]       forKey:@"businessCode"];
    [mdc_parameter setValue:dic[@"area"]        forKey:@"workPlaceCode"];
    [mdc_parameter setValue:dic[@"curcompany"]  forKey:@"curcompany"];
    [mdc_parameter setValue:dic[@"curposition"] forKey:@"curposition"];
    [mdc_parameter setValue:dic[@"announce"]    forKey:@"announce"];

    
    AFHTTPRequestOperation *op = [self getServer:@"Act140" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act140 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act140 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", (!JSON[@"Code"]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", (!JSON[@"ErrorDesc"]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"更新成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;

}

#pragma mark -- 查找职位订单（Act211）
- (AFHTTPRequestOperation *)checkPosition:(HDUserInfo *)user typeDic:(NSDictionary *)typeDic sort:(NSString *)sort pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block{
    if ([index intValue] <= 0 || [size intValue] < 1|| !typeDic) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:@"0"                forKey:@"culture"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:index               forKey:@"pageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    
    [mdc_parameter setValue:[typeDic objectForKey:@"keyword"]       forKey:@"keyword"];
    [mdc_parameter setValue:[typeDic objectForKey:@"functionCode"]  forKey:@"functionCode"];
    [mdc_parameter setValue:[typeDic objectForKey:@"businessCode"]  forKey:@"businessCode"];
    [mdc_parameter setValue:[typeDic objectForKey:@"area"]          forKey:@"area"];
    [mdc_parameter setValue:[typeDic objectForKey:@"userno"]        forKey:@"userno"];
    if ([[typeDic objectForKey:@"rewardMin"] isEqualToString:@""]) {
        Dlog(@"最小值为空!");
    }else{
        [mdc_parameter setValue:[typeDic objectForKey:@"rewardMin"]     forKey:@"rewardMin"];
    }
    if ([[typeDic objectForKey:@"rewardMax"] isEqualToString:@""]) {
        Dlog(@"最大值为空!");
    }else{
        [mdc_parameter setValue:[typeDic objectForKey:@"rewardMax"]     forKey:@"rewardMax"];
    }
    if ([[typeDic objectForKey:@"istop"] isEqualToString:@""]){
    
    }else{
        [mdc_parameter setValue:[typeDic objectForKey:@"istop"]         forKey:@"istop"];
    }
    if ([[typeDic objectForKey:@"isreward"] isEqualToString:@""]) {
        
    }else{
        [mdc_parameter setValue:[typeDic objectForKey:@"isreward"]      forKey:@"isreward"];   
    }
    [mdc_parameter setValue:sort forKey:@"sort"];

    AFHTTPRequestOperation *op = [self getServer:@"Act211" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation,id responseObject){
        Dlog(@"Act211 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
         Dlog(@"Act211 json = %@" , JSON);
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试",NO,nil);
            return ;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        NSMutableArray  *mar_positon    = [[NSMutableArray alloc] init];
        BOOL            isLastPage      = NO;
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"Positions"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"Positions"];
        }
        for (int i = 0; i < ar.count; i++) {
            NSString        *sCode          = nil;
            NSString        *sErrDesc       = nil;
            NSDictionary    *dic_p          = nil;
            WJPositionInfo  *position   = [WJPositionInfo new];
            dic_p           = ar[i];
            sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
            sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
            Dlog(@"dic = %@", dic_p);
            if (![sCode isEqualToString:@"0"]) {
                block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
                return;
            }
            position.sPositionNo        = FORMAT(@"%@", ([self isNull:dic_p[@"PositionID"]]?        @"": dic_p[@"PositionID"]));
            position.sPositionName      = FORMAT(@"%@", ([self isNull:dic_p[@"PositionName"]]?      @"": dic_p[@"PositionName"]));
            position.sRemark            = FORMAT(@"%@", ([self isNull:dic_p[@"Remark"]]?            @"": dic_p[@"Remark"]));
            position.sDelayDay          = FORMAT(@"%@", ([self isNull:dic_p[@"DelayDay"]]?          @"": dic_p[@"DelayDay"]));
            position.sArea              = FORMAT(@"%@", ([self isNull:dic_p[@"Area"]]?              @"": dic_p[@"Area"]));
            position.sDivisionName      = FORMAT(@"%@", ([self isNull:dic_p[@"DivisionName"]]?      @"": dic_p[@"DivisionName"]));
            position.sAreaText          = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?          @"": dic_p[@"AreaText"]));
            position.sCompanyNo         = FORMAT(@"%@", ([self isNull:dic_p[@"EnterpriseID"]]?      @"": dic_p[@"EnterpriseID"]));
            position.sCompnayName       = FORMAT(@"%@", ([self isNull:dic_p[@"EnterpriseName"]]?    @"": dic_p[@"EnterpriseName"]));
            position.sPublishTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?       @"": dic_p[@"PublishTime"]));
            position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionCode"]]?      @"": dic_p[@"FunctionCode"]));
            position.sFunctionText      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?      @"": dic_p[@"FunctionText"]));
            position.sEducationCode     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationCode"]]?     @"": dic_p[@"EducationCode"]));
            position.sEducationText     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationText"]]?     @"": dic_p[@"EducationText"]));
            position.sWorkExpCode       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpCode"]]?       @"": dic_p[@"WorkExpCode"]));
            position.sWorkExpText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpText"]]?       @"": dic_p[@"WorkExpText"]));
            position.sSalaryCode        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryCode"]]?        @"": dic_p[@"SalaryCode"]));
            position.sSalaryText        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryText"]]?        @"": dic_p[@"SalaryText"]));
            position.sProperty          = FORMAT(@"%@", ([self isNull:dic_p[@"Property"]]?          @"": dic_p[@"Property"]));
            position.sReward            = FORMAT(@"%@", ([self isNull:dic_p[@"Reward"]]?            @"": dic_p[@"Reward"]));
            position.sHit               = FORMAT(@"%@", ([self isNull:dic_p[@"hit"]]?               @"": dic_p[@"hit"]));
            position.sUpCount           = FORMAT(@"%@", ([self isNull:dic_p[@"UpCount"]]?           @"": dic_p[@"UpCount"]));
            position.sPublishTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?       @"": dic_p[@"PublishTime"]));
            
            position.isCollect          = [dic_p[@"IsCollect"]    boolValue];
            position.isBonus            = [dic_p[@"IsBonus"]      boolValue];
            position.isDeposit          = [dic_p[@"IsDeposit"]    boolValue];
            position.sUrl       = FORMAT(@"%@Position/Detail?pos=%@", [HDGlobalInfo instance].addressInfo.sWebsite_waproot, position.sPositionNo);
            HDEmployerInfo *e   = [HDEmployerInfo new];
            e.sId           = FORMAT(@"%@",([self isNull:dic_p[@"EnterpriseID"]]?     @"": dic_p[@"EnterpriseID"]));
            e.sName         = FORMAT(@"%@",([self isNull:dic_p[@"EnterpriseName"]]?   @"": dic_p[@"EnterpriseName"]));
            e.sTradeCode    = FORMAT(@"%@",([self isNull:dic_p[@"BusinessCode"]]?     @"": dic_p[@"BusinessCode"]));
            e.sTradeText    = FORMAT(@"%@",([self isNull:dic_p[@"BusinessText"]]?     @"": dic_p[@"BusinessText"]));
            e.sPropertyCode = FORMAT(@"%@",([self isNull:dic_p[@"ComProperty"]]?      @"": dic_p[@"ComProperty"]));
            e.sPropertyText = FORMAT(@"%@",([self isNull:dic_p[@"ComPropertyText"]]?  @"": dic_p[@"ComPropertyText"]));
            e.sScene01      = FORMAT(@"%@",([self isNull:dic_p[@"Scene01"]]?          @"": dic_p[@"Scene01"]));
            e.sScene02      = FORMAT(@"%@",([self isNull:dic_p[@"Scene02"]]?          @"": dic_p[@"Scene02"]));
            e.sScene03      = FORMAT(@"%@",([self isNull:dic_p[@"Scene03"]]?          @"": dic_p[@"Scene03"]));
            e.sScene04      = FORMAT(@"%@",([self isNull:dic_p[@"Scene04"]]?          @"": dic_p[@"Scene04"]));
            e.sRemark       = FORMAT(@"%@",([self isNull:dic_p[@"ComDesc"]]?          @"": dic_p[@"ComDesc"]));
            if (e.sScene04.length > 0) {
                [e.mar_urls insertObject:e.sScene04 atIndex:0];
            }
            if (e.sScene03.length > 0) {
                [e.mar_urls insertObject:e.sScene03 atIndex:0];
            }
            if (e.sScene02.length > 0) {
                [e.mar_urls insertObject:e.sScene02 atIndex:0];
            }
            if (e.sScene01.length > 0) {
                [e.mar_urls insertObject:e.sScene01 atIndex:0];
            }
            position.employerInfo   = e;
            WJBrokerInfo *r = [WJBrokerInfo new];
            r.sHumanNo      = FORMAT(@"%@",([self isNull:dic_p[@"UserNo"]]?      @"": dic_p[@"UserNo"]));
            r.sName         = FORMAT(@"%@",([self isNull:dic_p[@"NickName"]]?    @"": dic_p[@"NickName"]));
            r.sMemberLevel  = FORMAT(@"%@",([self isNull:dic_p[@"Level"]]?       @"": dic_p[@"Level"]));
            r.sAvatarUrl    = FORMAT(@"%@",([self isNull:dic_p[@"Avatar"]]?      @"": dic_p[@"Avatar"]));
            r.sCurCompany   = FORMAT(@"%@",([self isNull:dic_p[@"CurCompany"]]?  @"": dic_p[@"CurCompany"]));
            r.sCurPosition  = FORMAT(@"%@",([self isNull:dic_p[@"CurPosition"]]? @"": dic_p[@"CurPosition"]));
            r.sPhone        = FORMAT(@"%@",([self isNull:dic_p[@"MPhone"]]?      @"": dic_p[@"MPhone"]));
            r.sRoleType     = FORMAT(@"%@",([self isNull:dic_p[@"RoleType"]]?    @"": dic_p[@"RoleType"]));
            r.sWorkYears    = FORMAT(@"%@",([self isNull:dic_p[@"WorkExpText"]]? @"": dic_p[@"WorkExpText"]));
            r.isAuthen  = [dic_p[@"IsAuthen"]   boolValue];
            r.isFocus   = [dic_p[@"IsFocus"]    boolValue];
            position.brokerInfo = r;
            WJTradeInfo *trade = [WJTradeInfo new];
            trade.sTradeId         = FORMAT(@"%@",([self isNull:dic_p[@"TradeId"]]?         @"": dic_p[@"TradeId"]));
            trade.sServiceFees     = FORMAT(@"%@",([self isNull:dic_p[@"ServiceFees"]]?     @"": dic_p[@"ServiceFees"]));
            trade.sServiceType     = FORMAT(@"%@",([self isNull:dic_p[@"ServiceType"]]?     @"": dic_p[@"ServiceType"]));
            trade.sServiceTypeText = FORMAT(@"%@",([self isNull:dic_p[@"ServiceTypeText"]]? @"": dic_p[@"ServiceTypeText"]));
            trade.sDelayDay        = FORMAT(@"%@",([self isNull:dic_p[@"DelayDay"]]?        @"": dic_p[@"DelayDay"]));
            trade.sDeposit         = FORMAT(@"%@",([self isNull:dic_p[@"Deposit"]]?         @"": dic_p[@"Deposit"]));
            trade.sProperty        = FORMAT(@"%@",([self isNull:dic_p[@"Property"]]?        @"": dic_p[@"Property"]));
            trade.sTradeDesc       = FORMAT(@"%@",([self isNull:dic_p[@"TradeDesc"]]?       @"": dic_p[@"TradeDesc"]));
            trade.sRemark          = FORMAT(@"%@",([self isNull:dic_p[@"Remark"]]?          @"": dic_p[@"Remark"]));
            position.tradeInfo = trade;
            position.sRemark = [position changeBr2n:position.sRemark];
            position.employerInfo.sRemark = [position changeBr2n:position.employerInfo.sRemark];
            [mar_positon addObject:position];
        }
        block(YES, sCode, @"获取职位列表成功", isLastPage, mar_positon);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark -- 设置职位悬赏金(Act215)
- (AFHTTPRequestOperation *)settingPositionReward:(HDUserInfo *)user positionID:(NSString *)positionId delayDay:(NSString *)delayDay reward:(NSString *)reward CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *ID))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || positionId.length == 0 || delayDay.length == 0 || reward.length == 0) {
        Dlog(@"传入参数有误");
        block(NO, nil, @"传入参数有误",nil);
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:positionId          forKey:@"positionid"];
    [mdc_parameter setValue:delayDay            forKey:@"delayDay"];
    [mdc_parameter setValue:reward              forKey:@"reward"];
    [mdc_parameter setValue:@"0"                forKey:@"serviceType"];
    [mdc_parameter setValue:@""                 forKey:@"remark"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act215" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSDictionary    *dic        = nil;
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        NSString        *str        = [JSON objectForKey:@"Result"];
        if(JSON != [NSNull class]){
            dic         = [JSON objectForKey:@"Result"];
            sCode       = FORMAT(@"%@", [JSON objectForKey:@"Code"]);
            sErrDesc    = FORMAT(@"%@", [JSON objectForKey:@"ErrorDesc"]);
            if (![sCode isEqualToString:@"0"]) {
                block(NO, sCode,  (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
                return;
            }
        }
        block(YES, sCode, @"设置成功", str);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, nil, @"请求数据失败，请检查网络！",nil);
    }];
    return op;
}

#pragma mark -- 我的推荐订单(Act216)
- (AFHTTPRequestOperation *)getMyRecommendOrder:(HDUserInfo *)user  sort:(NSString *)sort pageIndex:(NSString *)index size:(NSString *)size  completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:index           forKey:@"pageIndex"];
    [mdc_parameter setValue:size            forKey:@"pageSize"];
    [mdc_parameter setValue:sort            forKey:@"sort"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act216" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@==%@" ,JSON, JSON[@"ErrorDesc"]);
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试",NO,nil);
            return ;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        NSMutableArray  *mar_positon    = [[NSMutableArray alloc] init];
        BOOL            isLastPage      = NO;
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"Positions"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"Positions"];
        }
        for (int i = 0; i < ar.count; i++) {
            NSString        *sCode          = nil;
            NSString        *sErrDesc       = nil;
            NSDictionary    *dic_p          = nil;
            NSDictionary    *dic_company    = nil;
            NSDictionary    *dic_recruiter  = nil;
            NSDictionary    *d_trade        = nil;
            WJPositionInfo  *position   = [WJPositionInfo new];
            dic_p           = [JSON objectForKey:@"Result"];
            dic_company     = [self isNull:dic_p[@"Company"]]?      nil: dic_p[@"Company"];
            dic_recruiter   = [self isNull:dic_p[@"Recruiter"]]?    nil: dic_p[@"Recruiter"];
            d_trade         = [self isNull:dic_p[@"TradeInfo"]]?    nil: dic_p[@"TradeInfo"];
            sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
            sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
            Dlog(@"dic = %@", dic_p);
            if (![sCode isEqualToString:@"0"]) {
                block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
                return;
            }
            position.sPositionNo        = FORMAT(@"%@", ([self isNull:dic_p[@"PositionNo"]]?        @"": dic_p[@"PositionNo"]));
            position.sPositionName      = FORMAT(@"%@", ([self isNull:dic_p[@"PositionName"]]?      @"": dic_p[@"PositionName"]));
            position.sRemark            = FORMAT(@"%@", ([self isNull:dic_p[@"Remark"]]?            @"": dic_p[@"Remark"]));
            position.sArea              = FORMAT(@"%@", ([self isNull:dic_p[@"Area"]]?              @"": dic_p[@"Area"]));
            position.sAreaText          = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?          @"": dic_p[@"AreaText"]));
            position.sCompanyNo         = FORMAT(@"%@", ([self isNull:dic_p[@"CompanyNo"]]?         @"": dic_p[@"CompanyNo"]));
            position.sCompnayName       = FORMAT(@"%@", ([self isNull:dic_p[@"CompnayName"]]?       @"": dic_p[@"CompnayName"]));
            position.sPublishTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?       @"": dic_p[@"PublishTime"]));
            position.sFunctionCode      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionCode"]]?      @"": dic_p[@"FunctionCode"]));
            position.sFunctionText      = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?      @"": dic_p[@"FunctionText"]));
            position.sEducationCode     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationCode"]]?     @"": dic_p[@"EducationCode"]));
            position.sEducationText     = FORMAT(@"%@", ([self isNull:dic_p[@"EducationText"]]?     @"": dic_p[@"EducationText"]));
            position.sWorkExpCode       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpCode"]]?       @"": dic_p[@"WorkExpCode"]));
            position.sWorkExpText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpText"]]?       @"": dic_p[@"WorkExpText"]));
            position.sSalaryCode        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryCode"]]?        @"": dic_p[@"SalaryCode"]));
            position.sSalaryText        = FORMAT(@"%@", ([self isNull:dic_p[@"SalaryText"]]?        @"": dic_p[@"SalaryText"]));
            position.sProperty          = FORMAT(@"%@", ([self isNull:dic_p[@"Property"]]?          @"": dic_p[@"Property"]));
            position.sReward            = FORMAT(@"%@", ([self isNull:dic_p[@"Reward"]]?            @"": dic_p[@"Reward"]));
            position.isCollect          = [dic_p[@"IsCollect"]    boolValue];
            position.isBonus            = [dic_p[@"IsBonus"]      boolValue];
            position.isDeposit          = [dic_p[@"IsDeposit"]    boolValue];
            position.sUrl       = FORMAT(@"%@Position/Detail?pos=%@", [HDGlobalInfo instance].addressInfo.sWebsite_waproot, position.sPositionNo);
            HDEmployerInfo *e   = [HDEmployerInfo new];
            if (dic_company){
                e.sId           = FORMAT(@"%@",([self isNull:dic_company[@"CompanyNo"]]?  @"": dic_company[@"CompanyNo"]));
                e.sName         = FORMAT(@"%@",([self isNull:dic_company[@"ComName"]]?    @"": dic_company[@"ComName"]));
                e.sTradeCode    = FORMAT(@"%@",([self isNull:dic_company[@"BusinessCode"]]?    @"": dic_company[@"BusinessCode"]));
                e.sTradeText    = FORMAT(@"%@",([self isNull:dic_company[@"BusinessText"]]?    @"": dic_company[@"BusinessText"]));
                e.sPropertyCode = FORMAT(@"%@",([self isNull:dic_company[@"ComProperty"]]?     @"": dic_company[@"ComProperty"]));
                e.sPropertyText = FORMAT(@"%@",([self isNull:dic_company[@"ComPropertyText"]]? @"": dic_company[@"ComPropertyText"]));
                e.sScene01      = FORMAT(@"%@",([self isNull:dic_company[@"Scene01"]]?           @"": dic_company[@"Scene01"]));
                e.sScene02      = FORMAT(@"%@",([self isNull:dic_company[@"Scene02"]]?           @"": dic_company[@"Scene02"]));
                e.sScene03      = FORMAT(@"%@",([self isNull:dic_company[@"Scene03"]]?           @"": dic_company[@"Scene03"]));
                e.sScene04      = FORMAT(@"%@",([self isNull:dic_company[@"Scene04"]]?           @"": dic_company[@"Scene04"]));
                if (e.sScene04.length > 0) {
                    [e.mar_urls insertObject:e.sScene04 atIndex:0];
                }
                if (e.sScene03.length > 0) {
                    [e.mar_urls insertObject:e.sScene03 atIndex:0];
                }
                if (e.sScene02.length > 0) {
                    [e.mar_urls insertObject:e.sScene02 atIndex:0];
                }
                if (e.sScene01.length > 0) {
                    [e.mar_urls insertObject:e.sScene01 atIndex:0];
                }
            }
            position.employerInfo   = e;
            WJBrokerInfo *r  = [WJBrokerInfo new];
            if (dic_recruiter){
                r.sHumanNo      = FORMAT(@"%@",([self isNull:dic_recruiter[@"UserNo"]]?      @"": dic_recruiter[@"UserNo"]));
                r.sName         = FORMAT(@"%@",([self isNull:dic_recruiter[@"NickName"]]?    @"": dic_recruiter[@"NickName"]));
                r.sMemberLevel  = FORMAT(@"%@",([self isNull:dic_recruiter[@"Level"]]?       @"": dic_recruiter[@"Level"]));
                r.sAvatarUrl    = FORMAT(@"%@",([self isNull:dic_recruiter[@"Avatar"]]?      @"": dic_recruiter[@"Avatar"]));
                r.sCurCompany   = FORMAT(@"%@",([self isNull:dic_recruiter[@"CurCompany"]]?  @"": dic_recruiter[@"CurCompany"]));
                r.sCurPosition  = FORMAT(@"%@",([self isNull:dic_recruiter[@"CurPosition"]]? @"": dic_recruiter[@"CurPosition"]));
                r.sRoleType     = FORMAT(@"%@",([self isNull:dic_recruiter[@"RoleType"]]?    @"": dic_recruiter[@"RoleType"]));
                r.isAuthen  = [dic_recruiter[@"IsAuthen"] boolValue];
                r.isFocus   = [dic_recruiter[@"IsFocus"] boolValue];
            }
            position.brokerInfo = r;
            
            WJTradeInfo *trade = [WJTradeInfo new];
            if (d_trade){
                trade.sTradeId         = FORMAT(@"%@",([self isNull:d_trade[@"TradeId"]]?         @"": d_trade[@"TradeId"]));
                trade.sServiceFees     = FORMAT(@"%@",([self isNull:d_trade[@"ServiceFees"]]?     @"": d_trade[@"ServiceFees"]));
                trade.sServiceType     = FORMAT(@"%@",([self isNull:d_trade[@"ServiceType"]]?     @"": d_trade[@"ServiceType"]));
                trade.sServiceTypeText = FORMAT(@"%@",([self isNull:d_trade[@"ServiceTypeText"]]? @"": d_trade[@"ServiceTypeText"]));
                trade.sDelayDay        = FORMAT(@"%@",([self isNull:d_trade[@"DelayDay"]]?        @"": d_trade[@"DelayDay"]));
                trade.sDeposit         = FORMAT(@"%@",([self isNull:d_trade[@"Deposit"]]?         @"": d_trade[@"Deposit"]));
                trade.sProperty        = FORMAT(@"%@",([self isNull:d_trade[@"Property"]]?        @"": d_trade[@"Property"]));
                trade.sTradeDesc       = FORMAT(@"%@",([self isNull:d_trade[@"TradeDesc"]]?       @"": d_trade[@"TradeDesc"]));
                trade.sRemark          = FORMAT(@"%@",([self isNull:d_trade[@"Remark"]]?          @"": d_trade[@"Remark"]));
            }
            position.tradeInfo = trade;
            position.sRemark = [position changeBr2n:position.sRemark];
            position.employerInfo.sRemark = [position changeBr2n:position.employerInfo.sRemark];
            [mar_positon addObject:position];
        }
        block(YES, sCode, @"获取职位列表成功", isLastPage, mar_positon);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark -- 新增候选人并推荐(Act309)
- (AFHTTPRequestOperation *)addPeopleAndRecommend:(HDUserInfo *)user talent:(HDTalentInfo *)talent completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,NSDictionary *talents))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !talent) {
        block(NO, nil, @"传入参数有误",nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:talent.sHumanNo      forKey:@"positionno"];
    [mdc_parameter setValue:talent.sName            forKey:@"name"];
    [mdc_parameter setValue:talent.sPhone          forKey:@"mobile"];
    [mdc_parameter setValue:talent.sCurCompanyName  forKey:@"currentEnterprise"];
    [mdc_parameter setValue:talent.sCurPosition     forKey:@"currentposition"];
    [mdc_parameter setValue:talent.sWorkYears        forKey:@"workTime"];
    [mdc_parameter setValue:talent.sRemark          forKey:@"remark"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act309" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
        NSDictionary  *dic   = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
       
        block(YES, sCode, @"新增成功",dic);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);
    }];
    return op;
}

#pragma mark -- 保存推荐人(Act310)
- (AFHTTPRequestOperation *)saveRecommendPeople:(HDUserInfo *)user recommend:(WJSaveRecommendInfo *)recommend completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !recommend){
        block(NO,nil,@"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@",user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:recommend.matchid                       forKey:@"matchid"];
    [mdc_parameter setValue:recommend.recommendId                   forKey:@"recommendId"];
    [mdc_parameter setValue:recommend.personalno                    forKey:@"personalno"];
    [mdc_parameter setValue:recommend.name                          forKey:@"name"];
    [mdc_parameter setValue:recommend.mobile                        forKey:@"mobile"];
    [mdc_parameter setValue:recommend.currentEnterprise             forKey:@"currentEnterprise"];
    [mdc_parameter setValue:recommend.currentposition               forKey:@"currentposition"];
    [mdc_parameter setValue:recommend.ishide                        forKey:@"ishide"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act310" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = nil;
        NSString        *sErrDesc   = nil;
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        block(YES, sCode, @"保存成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark -- 保存评价信息(Act311)
- (AFHTTPRequestOperation *)saveEvaluateInfo:(HDUserInfo *)user evaluate:(HDEvaluateInfo *)evaluate completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *matchId))block
{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !evaluate) {
        block(NO, nil, @"传入参数有误",nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:evaluate.sRecommendId           forKey:@"RecommendId"];
    [mdc_parameter setValue:evaluate.sPersonalNo            forKey:@"PersonalNo"];
    [mdc_parameter setValue:evaluate.sMatchPoint1           forKey:@"matchpoint1"];
    [mdc_parameter setValue:evaluate.sMatchPoint2           forKey:@"Matchpoint2"];
    [mdc_parameter setValue:evaluate.sMatchPoint3           forKey:@"Matchpoint3"];
    [mdc_parameter setValue:evaluate.sMatchPoint4           forKey:@"MatchPoint4"];
    [mdc_parameter setValue:evaluate.sMatchPoint5           forKey:@"Matchpoint5"];
    [mdc_parameter setValue:evaluate.sRemark                forKey:@"remark"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act311" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        sCode       = FORMAT(@"%@", [self isNull:JSON[@"Code"]]?         @"": JSON[@"Code"]);
        sErrDesc    = FORMAT(@"%@", [self isNull:JSON[@"ErrorDesc"]]?    @"": JSON[@"ErrorDesc"]);
       NSString *str   = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
        block(YES, sCode, @"新增成功", str);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);
    }];
    return op;

}

#pragma mark -- 搜索简历(Act323)
- (AFHTTPRequestOperation *)searchResume:(HDUserInfo *)user dic:(NSDictionary *)dic pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents))block
{
    if (!dic) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:[dic objectForKey:@"keyword"]               forKey:@"keyword"];
    [mdc_parameter setValue:[dic objectForKey:@"area"]                  forKey:@"area"];
    [mdc_parameter setValue:[dic objectForKey:@"functioncode"]          forKey:@"functioncode"];
    [mdc_parameter setValue:[dic objectForKey:@"businesscode"]          forKey:@"businesscode"];
    [mdc_parameter setValue:[dic objectForKey:@"edulevel"]              forKey:@"edulevel"];
    [mdc_parameter setValue:[dic objectForKey:@"startworktime"]         forKey:@"startworktime"];
    [mdc_parameter setValue:[dic objectForKey:@"userno"]                forKey:@"userno"];
    [mdc_parameter setValue:[dic objectForKey:@"feeMin"]                forKey:@"feeMin"];
    [mdc_parameter setValue:[dic objectForKey:@"feeMax"]                forKey:@"feeMax"];
    // [mdc_parameter setValue:[dic objectForKey:@"istop"]                 forKey:@"istop"];
    [mdc_parameter setValue:index                                       forKey:@"pageIndex"];
    [mdc_parameter setValue:size                                        forKey:@"pageSize"];
    
    
    AFHTTPRequestOperation *op = [self getServer:@"Act323" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act323 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        BOOL            isLastPage      = NO;
        NSMutableArray  *mar_resume    = [[NSMutableArray alloc] init];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"Personals"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"Personals"];
        }
        for (int i = 0; i < ar.count; i++) {
            HDTalentInfo *talent = [HDTalentInfo new];
            if (![ar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p         = ar[i];
            talent.sHumanNo             = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalNo"]]?            @"": dic_p[@"PersonalNo"]));
            talent.sArea                = FORMAT(@"%@", ([self isNull:dic_p[@"Area"]]?                  @"": dic_p[@"Area"]));
            talent.sAreaText            = FORMAT(@"%@", ([self isNull:dic_p[@"AreaText"]]?              @"": dic_p[@"AreaText"]));
            talent.sCurCompanyName      = FORMAT(@"%@", ([self isNull:dic_p[@"LastCompanyName"]]?       @"": dic_p[@"LastCompanyName"]));
            talent.sCurPosition         = FORMAT(@"%@", ([self isNull:dic_p[@"LastPosition"]]?          @"": dic_p[@"LastPosition"]));
            talent.sPhone               = FORMAT(@"%@", ([self isNull:dic_p[@"MPhone"]]?                @"": dic_p[@"MPhone"]));
            talent.sName                = FORMAT(@"%@", ([self isNull:dic_p[@"Name"]]?                  @"": dic_p[@"Name"]));
            talent.sPersonalDesc        = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalDesc"]]?          @"": dic_p[@"PersonalDesc"]));
            talent.sProperty            = FORMAT(@"%@", ([self isNull:dic_p[@"Property"]]?              @"": dic_p[@"Property"]));
            talent.sStartWorkTime       = FORMAT(@"%@", ([self isNull:dic_p[@"PublishTime"]]?           @"": dic_p[@"PublishTime"]));
            talent.sEduLevel            = FORMAT(@"%@", ([self isNull:dic_p[@"EduLevelText"]]?          @"": dic_p[@"EduLevelText"]));
            talent.sWorkYears           = FORMAT(@"%@", ([self isNull:dic_p[@"WorkExpText"]]?           @"": dic_p[@"WorkExpText"]));
            talent.sFunctionText        = FORMAT(@"%@", ([self isNull:dic_p[@"FunctionText"]]?          @"": dic_p[@"FunctionText"]));
            talent.sBusinessText        = FORMAT(@"%@", ([self isNull:dic_p[@"BusinessText"]]?          @"": dic_p[@"BusinessText"]));
            talent.sWorkPlaceText       = FORMAT(@"%@", ([self isNull:dic_p[@"WorkPlaceText"]]?         @"": dic_p[@"WorkPlaceText"]));
            talent.sRemark              = FORMAT(@"%@", ([self isNull:dic_p[@"ResumeText"]]?            @"": dic_p[@"ResumeText"]));
            talent.sServiceFee          = FORMAT(@"%@", ([self isNull:dic_p[@"ServiceFee"]]?            @"": dic_p[@"ServiceFee"]));
            talent.sSexText             = FORMAT(@"%@", ([self isNull:dic_p[@"SexText"]]?               @"": dic_p[@"SexText"]));
            talent.sNickName            = FORMAT(@"%@", ([self isNull:dic_p[@"NickName"]]?              @"": dic_p[@"NickName"]));
            talent.sUserNo              = FORMAT(@"%@", ([self isNull:dic_p[@"UserNo"]]?                @"": dic_p[@"UserNo"]));
            talent.sShopType            = FORMAT(@"%@", ([self isNull:dic_p[@"ShopType"]]?              @"": dic_p[@"ShopType"]));
            talent.sRoleType            = FORMAT(@"%@", ([self isNull:dic_p[@"RoleType"]]?              @"": dic_p[@"RoleType"]));
            talent.sMemberLevel         = FORMAT(@"%@", ([self isNull:dic_p[@"MemberLevel"]]?           @"": dic_p[@"MemberLevel"]));
            talent.sSex                 = FORMAT(@"%@", ([self isNull:dic_p[@"Sex"]]?                   @"": dic_p[@"Sex"]));
            [mar_resume addObject:talent];
        }
        block(YES, sCode, @"获取数据成功", isLastPage, mar_resume);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark -- 获取简历详情(Act324)
- (AFHTTPRequestOperation *)getResumeDetails:(HDUserInfo *)user personalno:(NSString *)personalno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,  HDTalentInfo *resumeDetail))block{
    
    if (personalno.length == 0){
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:personalno          forKey:@"personalno"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act324" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!JSON) {
            block(NO, nil, @"网络出错,请稍后再试", nil);
            return ;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        HDTalentInfo *resume  = [HDTalentInfo new];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
        resume.sHumanNo         = FORMAT(@"%@", [self isNull:dic[@"PersonalNo"]]?       @"":dic[@"PersonalNo"]);
        resume.sArea            = FORMAT(@"%@", [self isNull:dic[@"Area"]]?             @"":dic[@"Area"]);
        resume.sAreaText        = FORMAT(@"%@", [self isNull:dic[@"AreaText"]]?         @"":dic[@"AreaText"]);
        resume.sCurCompanyName  = FORMAT(@"%@", [self isNull:dic[@"CurCompanyName"]]?   @"":dic[@"CurCompanyName"]);
        resume.sCurPosition     = FORMAT(@"%@", [self isNull:dic[@"CurPosition"]]?      @"":dic[@"CurPosition"]);
        resume.sPhone           = FORMAT(@"%@", [self isNull:dic[@"MPhone"]]?           @"":dic[@"MPhone"]);
        resume.sName            = FORMAT(@"%@", [self isNull:dic[@"Name"]]?             @"":dic[@"Name"]);
        resume.sPersonalDesc    = FORMAT(@"%@", [self isNull:dic[@"PersonalDesc"]]?     @"":dic[@"PersonalDesc"]);
        resume.sProperty        = FORMAT(@"%@", [self isNull:dic[@"Property"]]?         @"":dic[@"Property"]);
        resume.sStartWorkTime   = FORMAT(@"%@", [self isNull:dic[@"PublishTime"]]?      @"":dic[@"PublishTime"]);
        resume.sEduLevel        = FORMAT(@"%@", [self isNull:dic[@"EducationText"]]?    @"":dic[@"EducationText"]);
        resume.sEduLecelKey     = FORMAT(@"%@", [self isNull:dic[@"Education"]]?        @"":dic[@"Education"]);
        resume.sWorkYears       = FORMAT(@"%@", [self isNull:dic[@"WorkYears"]]?        @"":dic[@"WorkYears"]);
        resume.sFunctionText    = FORMAT(@"%@", [self isNull:dic[@"FunctionText"]]?     @"":dic[@"FunctionText"]);
        resume.sBusinessText    = FORMAT(@"%@", [self isNull:dic[@"BusinessText"]]?     @"":dic[@"BusinessText"]);
        resume.sWorkPlaceText   = FORMAT(@"%@", [self isNull:dic[@"WorkPlaceText"]]?    @"":dic[@"WorkPlaceText"]);
        resume.sRemark          = FORMAT(@"%@", [self isNull:dic[@"ResumeText"]]?       @"":dic[@"ResumeText"]);
        resume.sServiceFee      = FORMAT(@"%@", [self isNull:dic[@"ServiceFee"]]?       @"":dic[@"ServiceFee"]);
        resume.sSexText         = FORMAT(@"%@", [self isNull:dic[@"SexText"]]?          @"":dic[@"SexText"]);
        resume.sNickName        = FORMAT(@"%@", [self isNull:dic[@"NickName"]]?         @"":dic[@"NickName"]);
        resume.sUserNo          = FORMAT(@"%@", [self isNull:dic[@"UserNo"]]?           @"":dic[@"UserNo"]);
        resume.sShopType        = FORMAT(@"%@", [self isNull:dic[@"ShopType"]]?         @"":dic[@"ShopType"]);
        resume.sRoleType        = FORMAT(@"%@", [self isNull:dic[@"RoleType"]]?         @"":dic[@"RoleType"]);
        resume.sMemberLevel     = FORMAT(@"%@", [self isNull:dic[@"MemberLevel"]]?      @"":dic[@"MemberLevel"]);
        resume.sSex             = FORMAT(@"%@", [self isNull:dic[@"Sex"]]?              @"":dic[@"Sex"]);
        resume.sAvatarUrl       = FORMAT(@"%@", [self isNull:dic[@"Avatar"]]?           @"":dic[@"Avatar"]);
        resume.isFocus          = [dic[@"IsFocus"]        boolValue];
        resume.isOpen           = [dic[@"IsOpen"]         boolValue];
        resume.isBuy            = [dic[@"IsBuy"]          boolValue];
        resume.isCollect        = [dic[@"IsCollect"]      boolValue];
        block(YES, sCode, @"更新成功",resume);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);
    }];
    return op;
}

#pragma mark -- 我发送的推荐简历列表(Act325)
- (AFHTTPRequestOperation *)getMeRecommendResumeList:(HDUserInfo *)user pageIndex:(NSString *)index size:(NSString *)size CompletionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:index           forKey:@"pageIndex"];
    [mdc_parameter setValue:size            forKey:@"pageSize"];

    
    AFHTTPRequestOperation *op = [self getServer:@"Act325" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act325 json = %@==%@" ,JSON, JSON[@"ErrorDesc"]);
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试",NO,nil);
            return ;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        NSMutableArray  *mar_recommend    = [[NSMutableArray alloc] init];
        BOOL            isLastPage      = NO;
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"Recommends"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"Recommends"];
        }
        for (int i = 0; i < ar.count; i++) {
            HDRecommendInfo *recommend    = [HDRecommendInfo new];
            if (![ar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p         = ar[i];
            recommend.sCreatedTime          = FORMAT(@"%@", [self isNull:dic_p[@"CreatedTime"]]?       @"": dic_p[@"CreatedTime"]);
            recommend.sCurCompanyName       = FORMAT(@"%@", [self isNull:dic_p[@"CurCompanyName"]]?    @"": dic_p[@"CurCompanyName"]);
            recommend.sCurPosition          = FORMAT(@"%@", [self isNull:dic_p[@"CurPosition"]]?       @"": dic_p[@"CurPosition"]);
            recommend.sEduLevel             = FORMAT(@"%@", [self isNull:dic_p[@"EducationText"]]?     @"": dic_p[@"EducationText"]);
            recommend.sEducation            = FORMAT(@"%@", [self isNull:dic_p[@"Education"]]?         @"": dic_p[@"Education"]);
            recommend.sEnterpriseID         = FORMAT(@"%@", [self isNull:dic_p[@"EnterpriseID"]]?      @"": dic_p[@"EnterpriseID"]);
            recommend.sPhone                = FORMAT(@"%@", [self isNull:dic_p[@"MPhone"]]?            @"": dic_p[@"MPhone"]);
            recommend.sMatchCount           = FORMAT(@"%@", [self isNull:dic_p[@"MatchCount"]]?        @"": dic_p[@"MatchCount"]);
            recommend.sName                 = FORMAT(@"%@", [self isNull:dic_p[@"Name"]]?              @"": dic_p[@"Name"]);
            recommend.sPositionDes          = FORMAT(@"%@", [self isNull:dic_p[@"PositionDes"]]?       @"": dic_p[@"PositionDes"]);
            recommend.sPositionID           = FORMAT(@"%@", [self isNull:dic_p[@"PositionID"]]?        @"": dic_p[@"PositionID"]);
            recommend.sPositionName         = FORMAT(@"%@", [self isNull:dic_p[@"PositionName"]]?      @"": dic_p[@"PositionName"]);
            recommend.sProgress             = FORMAT(@"%@", [self isNull:dic_p[@"Progress"]]?          @"": dic_p[@"Progress"]);
            recommend.sProgressText         = FORMAT(@"%@", [self isNull:dic_p[@"ProgressText"]]?      @"": dic_p[@"ProgressText"]);
            recommend.sRecommendId          = FORMAT(@"%@", [self isNull:dic_p[@"RecommendID"]]?       @"": dic_p[@"RecommendID"]);
            recommend.sRefereeCompanyName   = FORMAT(@"%@", [self isNull:dic_p[@"RefereeCompanyName"]]?@"": dic_p[@"RefereeCompanyName"]);
            recommend.sRefereeId            = FORMAT(@"%@", [self isNull:dic_p[@"RefereeId"]]?         @"": dic_p[@"RefereeId"]);
            recommend.sRefereeMPhone        = FORMAT(@"%@", [self isNull:dic_p[@"RefereeMPhone"]]?     @"": dic_p[@"RefereeMPhone"]);
            recommend.sRefereeName          = FORMAT(@"%@", [self isNull:dic_p[@"RefereeName"]]?       @"": dic_p[@"RefereeName"]);
            recommend.sRefereePosition      = FORMAT(@"%@", [self isNull:dic_p[@"RefereePosition"]]?   @"": dic_p[@"RefereePosition"]);
            recommend.sServiceFee           = FORMAT(@"%@", [self isNull:dic_p[@"ServiceFee"]]?        @"": dic_p[@"ServiceFee"]);
            recommend.sSexText              = FORMAT(@"%@", [self isNull:dic_p[@"SexText"]]?           @"": dic_p[@"SexText"]);
            recommend.sWorkYears            = FORMAT(@"%@", [self isNull:dic_p[@"WorkYears"]]?         @"": dic_p[@"WorkYears"]);
            
            recommend.isMale                = FORMAT(@"%@", [self isNull:dic[@"Sex"]]?               @"": dic[@"Sex"]).boolValue;
            recommend.isOpen                = FORMAT(@"%@", [self isNull:dic[@"IsOpen"]]?            @"": dic[@"IsOpen"]).boolValue;
            recommend.isBonus               = FORMAT(@"%@", [self isNull:dic[@"IsBonus"]]?           @"": dic[@"IsBonus"]).boolValue;
            recommend.isDeposit             = FORMAT(@"%@", [self isNull:dic[@"IsDeposit"]]?         @"": dic[@"IsDeposit"]).boolValue;
            recommend.isFromCloud           = FORMAT(@"%@", [self isNull:dic[@"IsFromCloud"]]?       @"": dic[@"IsFromCloud"]).boolValue;
            recommend.isHaveBonus           = FORMAT(@"%@", [self isNull:dic[@"IsHaveBonus"]]?       @"": dic[@"IsHaveBonus"]).boolValue;


            [mar_recommend addObject:recommend];
        }
        block(YES, sCode, @"获取人选列表成功", isLastPage, mar_recommend);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;

}

#pragma mark -- 开放简历搜索设置(Act326)
- (AFHTTPRequestOperation *)openResume:(HDUserInfo *)user dic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block{
    if (!dic ) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self postServer:@"Act326" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
         Dlog(@"Act326 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"发布成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark -- 关闭简历搜索(Act327)
- (AFHTTPRequestOperation *)closeResume:(HDUserInfo *)user personalno:(NSString *)personalno completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block{
    if (personalno.length == 0 ) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:personalno          forKey:@"personalno"];
    
    AFHTTPRequestOperation *op = [self postServer:@"Act327" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act327 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"简历搜索已关闭");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;

}

#pragma mark -- 添加推荐信(Act329)
- (AFHTTPRequestOperation *)addRecommendLetter:(HDUserInfo *)user typeDic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage,NSString *recommendID))block{
    if (!dic ) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:[dic objectForKey:@"buyId"]     forKey:@"buyId"];
    [mdc_parameter setValue:[dic objectForKey:@"name"]      forKey:@"name"];
    [mdc_parameter setValue:[dic objectForKey:@"mobile"]    forKey:@"mobile"];
    [mdc_parameter setValue:[dic objectForKey:@"email"]     forKey:@"email"];
    [mdc_parameter setValue:[dic objectForKey:@"qq"]        forKey:@"qq"];
    [mdc_parameter setValue:[dic objectForKey:@"remark"]    forKey:@"remark"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act329" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act329 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"return json = %@", JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错,请稍后再试", nil);
            return ;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSString        *sID        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
        block(YES,sCode,@"推荐成功",sID);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);

    }];
    return op;

}

/*
 **银行服务
 */
#pragma mark -- 获取余额(Act401)
- (AFHTTPRequestOperation *)getBalance:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil ) {
        block(NO, nil, @"传入参数有误",nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act401" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        WJBalanceInfo   *balanceInfo= [WJBalanceInfo new];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
        balanceInfo.sUserNo         = FORMAT(@"%@", [self isNull:dic[@"UserNo"]]?       @"":dic[@"UserNo"]);
        balanceInfo.sGoldCount      = FORMAT(@"%@", [self isNull:dic[@"GoldCount"]]?    @"":dic[@"GoldCount"]);
        balanceInfo.sDeposit        = FORMAT(@"%@", [self isNull:dic[@"Deposit"]]?      @"":dic[@"Deposit"]);
        balanceInfo.sTotalIn        = FORMAT(@"%@", [self isNull:dic[@"TotalIn"]]?      @"":dic[@"TotalIn"]);
        balanceInfo.sTotalOut       = FORMAT(@"%@", [self isNull:dic[@"TotalOut"]]?     @"":dic[@"TotalOut"]);
        balanceInfo.sGGold          = FORMAT(@"%@", [self isNull:dic[@"GGold"]]?        @"":dic[@"GGold"]);
        balanceInfo.sGold           = FORMAT(@"%@", [self isNull:dic[@"Gold"]]?         @"":dic[@"Gold"]);
        block(YES, sCode, @"更新成功",balanceInfo);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);
    }];
    return op;
    
}

#pragma mark - 获取交易记录列表(Act402)
- (AFHTTPRequestOperation *)getTradeRecordList:(HDUserInfo *)user lastTicks:(NSString *)lastTicks szType:(NSString *)szType index:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *list))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO, nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:index               forKey:@"pageIndex"];
    [mdc_parameter setValue:size                forKey:@"pageSize"];
    [mdc_parameter setValue:szType              forKey:@"szType"];
    [mdc_parameter setValue:lastTicks           forKey:@"lastTicks"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act402" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试",NO , nil);
            return ;
        }
        NSString                *sCode          = nil;
        NSString                *sErrDesc       = nil;
        NSDictionary            *dic            = nil;
        NSArray                 *ar             = nil;
        NSMutableArray          *mar_position   = [NSMutableArray new] ;
        BOOL                    isLastPage      = NO;
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]         == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"TradeRecords"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            
            ar = dic[@"TradeRecords"];
        }
        for (int i = 0; i < ar.count; i++) {
            WJTradeRecordListInfo *tradeInfo  =[[WJTradeRecordListInfo alloc] init];
            if (![ar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p            = ar[i];
            tradeInfo.sTradeRecordID       = FORMAT(@"%@",([self isNull:dic_p[@"TradeRecordID"]]?           @"":dic_p[@"TradeRecordID"]));
            tradeInfo.sTradeType           = FORMAT(@"%@",([self isNull:dic_p[@"TradeType"]]?               @"":dic_p[@"TradeType"]));
            tradeInfo.sTradeTypeText       = FORMAT(@"%@",([self isNull:dic_p[@"TradeTypeText"]]?           @"":dic_p[@"TradeTypeText"]));
            tradeInfo.sAmount              = FORMAT(@"%@",([self isNull:dic_p[@"Amount"]]?                  @"":dic_p[@"Amount"]));
            tradeInfo.sBalance             = FORMAT(@"%@",([self isNull:dic_p[@"Balance"]]?                 @"":dic_p[@"Balance"]));
            tradeInfo.sContent             = FORMAT(@"%@",([self isNull:dic_p[@"Content"]]?                 @"":dic_p[@"Content"]));
            tradeInfo.sRemark              = FORMAT(@"%@",([self isNull:dic_p[@"Remark"]]?                  @"":dic_p[@"Remark"]));
            tradeInfo.sCreatedTime         = FORMAT(@"%@",([self isNull:dic_p[@"CreatedTime"]]?             @"":dic_p[@"CreatedTime"]));
            tradeInfo.sOtherUserNo         = FORMAT(@"%@",([self isNull:dic_p[@"OtherUserNo"]]?             @"":dic_p[@"OtherUserNo"]));
            tradeInfo.sOtherNickName       = FORMAT(@"%@",([self isNull:dic_p[@"OtherNickName"]]?           @"":dic_p[@"OtherNickName"]));
            tradeInfo.sTransactType        = FORMAT(@"%@",([self isNull:dic_p[@"TransactType"]]?            @"":dic_p[@"TransactType"]));
            tradeInfo.sTransactTypeText    = FORMAT(@"%@",([self isNull:dic_p[@"TransactTypeText"]]?        @"":dic_p[@"TransactTypeText"]));
            tradeInfo.sTransactID          = FORMAT(@"%@",([self isNull:dic_p[@"TransactID"]]?              @"":dic_p[@"TransactID"]));
            [mar_position addObject:tradeInfo];
        }
        block(YES, sCode, @"更新成功", isLastPage, mar_position);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO,
              nil);
    }];
    return op;
}

#pragma mark -- 获取银行卡信息(Act403)
- (AFHTTPRequestOperation *)getBankCardMessage:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBankInfo *bank))block{
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act403" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act403 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        WJBankInfo      *bankInfo   = [WJBankInfo new];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
        bankInfo.sName          = FORMAT(@"%@", [self isNull:dic[@"Name"]]?         @"": dic[@"Name"]);
        bankInfo.sBankAccount   = FORMAT(@"%@", [self isNull:dic[@"BankAccount"]]?  @"": dic[@"BankAccount"]);
        bankInfo.sBanktype      = FORMAT(@"%@", [self isNull:dic[@"BankType"]]?     @"": dic[@"BankType"]);
        bankInfo.sBankName      = FORMAT(@"%@", [self isNull:dic[@"BankName"]]?     @"": dic[@"BankName"]);
        bankInfo.sBankBranch    = FORMAT(@"%@", [self isNull:dic[@"BankBranch"]]?   @"": dic[@"BankBranch"]);

        block(YES, sCode, @"更新成功",bankInfo);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！",nil);
    }];
    return op;

}

#pragma mark - 创建支付订单(Act408)
/*
 **     tradeid交易模式编号
 **     merchandiseCode商品编码 保证金 100100 在线充值 100101
 **     channeltype支付渠道 1 银联 2 支付宝
 */
- (AFHTTPRequestOperation *)createPayOrder:(HDUserInfo *)user tradeid:(NSString *)tradeid merchandiseCode:(NSString *)merchandiseCode number:(NSString *)number channeltype:(NSString *)type completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *payID))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil ) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:tradeid             forKey:@"tradeId"];
    [mdc_parameter setValue:tradeid             forKey:@"buyId"];
    [mdc_parameter setValue:merchandiseCode     forKey:@"merchandiseCode"];
    [mdc_parameter setValue:number              forKey:@"merchandiseNum"];
    [mdc_parameter setValue:type                forKey:@"channeltype"];
    AFHTTPRequestOperation *op = [self getServer:@"Act408" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?       @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?  @"": JSON[@"ErrorDesc"]));
        NSString        *str        = FORMAT(@"%@", [self isNull:JSON[@"Result"]]?      @"": JSON[@"Result"]);
        if (![sCode isEqualToString:@"0"] || !str) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        block(YES, sCode, @"支付成功", str);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
    
}

#pragma mark -- 获得悬赏金信息(Act409)
- (AFHTTPRequestOperation *)getRewardMessage:(HDUserInfo *)user recommendId:(NSString *)recommendId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || recommendId.length == 0 ) {
        block(NO, nil, @"传入参数有误",nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter   = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:recommendId         forKey:@"recommendId"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act409" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试", nil);
            return ;
        }
        NSString                *sCode          = nil;
        NSString                *sErrDesc       = nil;
        NSDictionary            *dic            = nil;
        NSMutableArray          *mar_position   = [NSMutableArray new] ;
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]         == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        WJRewardMessageInfo *messageInfo = [[WJRewardMessageInfo alloc] init];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }
            messageInfo.sPositionName       = FORMAT(@"%@",([self isNull:dic[@"PositionName"]]?     @"":dic[@"PositionName"]));
            messageInfo.sDelayDay           = FORMAT(@"%@",([self isNull:dic[@"DelayDay"]]?         @"":dic[@"DelayDay"]));
            messageInfo.sDeposit            = FORMAT(@"%@",([self isNull:dic[@"Deposit"]]?          @"":dic[@"Deposit"]));
            messageInfo.sReward             = FORMAT(@"%@",([self isNull:dic[@"Reward"]]?           @"":dic[@"Reward"]));
            messageInfo.sRefereeId          = FORMAT(@"%@",([self isNull:dic[@"RefereeId"]]?        @"":dic[@"RefereeId"]));
            messageInfo.sRName              = FORMAT(@"%@",([self isNull:dic[@"RName"]]?            @"":dic[@"RName"]));
            messageInfo.sPersonalNo         = FORMAT(@"%@",([self isNull:dic[@"PersonalNo"]]?       @"":dic[@"PersonalNo"]));
            messageInfo.sTradeId            = FORMAT(@"%@",([self isNull:dic[@"TradeId"]]?          @"":dic[@"TradeId"]));
            messageInfo.sRecommendID        = FORMAT(@"%@",([self isNull:dic[@"RecommendID"]]?      @"":dic[@"RecommendID"]));
            messageInfo.sPositionID         = FORMAT(@"%@",([self isNull:dic[@"PositionID"]]?       @"":dic[@"PositionID"]));
            messageInfo.sPName             = FORMAT(@"%@",([self isNull:dic[@"PName"]]?           @"":dic[@"PName"]));
            messageInfo.sRUserNo            = FORMAT(@"%@",([self isNull:dic[@"RUserNo"]]?          @"":dic[@"RUserNo"]));
            messageInfo.sUserNo             = FORMAT(@"%@",([self isNull:dic[@"UserNo"]]?           @"":dic[@"UserNo"]));
            [mar_position addObject:messageInfo];
        block(YES, sCode, @"更新成功", mar_position);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 密码支付悬赏金(Act410)
- (AFHTTPRequestOperation *)passwordPayReward:(HDUserInfo *)user  psd:(NSString *)psd recommendId:(NSString *)recommendId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || recommendId.length == 0) {
        block(NO, nil, @"传入参数有误");
        Dlog(@"传入参数有误");
        return nil;
    }
    Dlog(@"tocke = %@", user.sTocken);
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:recommendId         forKey:@"recommendId"];
    [mdc_parameter setValue:psd                 forKey:@"password"];
    AFHTTPRequestOperation *op = [self getServer:@"Act410" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act410 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试");
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc));
            return;
        }
        
        block(YES, sCode, @"支付成功");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！");
    }];
    return op;
}

#pragma mark -- 荐币取现(Act411)
- (AFHTTPRequestOperation *)moneyWithDraw:(HDUserInfo *)user dic:(NSDictionary *)dic completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || !dic) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo        forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:[dic objectForKey:@"bankType"]      forKey:@"bankType"];
    [mdc_parameter setValue:[dic objectForKey:@"bankAccount"]   forKey:@"bankAccount"];
    [mdc_parameter setValue:[dic objectForKey:@"bankBranch"]    forKey:@"bankBranch"];
    [mdc_parameter setValue:[dic objectForKey:@"name"]          forKey:@"name"];
    [mdc_parameter setValue:[dic objectForKey:@"gold"]          forKey:@"gold"];
    [mdc_parameter setValue:[dic objectForKey:@"password"]      forKey:@"password"];
   
    AFHTTPRequestOperation *op = [self getServer:@"Act411" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {

        Dlog(@"Act411 http = %@", operation.response.URL);

        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act411 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSDictionary    *dic        = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || !dic) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        
        block(YES, sCode, @"取现成功", nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark --分页获取购买服务记录(Act413)
- (AFHTTPRequestOperation *)getBuyServiceList:(HDUserInfo *)user lastTicks:(NSString *)lastTicks isBuyer:(NSString *)isBuyer isBigger:(NSString *)isBigger pageIndex:(NSString *)index size:(NSString *)size completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *orderList))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || lastTicks.length == 0 || [index intValue] <= 0 || [size intValue] < 1) {
        block(NO, nil, @"传入参数有误", NO , nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSMutableDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:VERSION             forKey:@"Version"];
    [mdc_parameter setValue:@"0"                forKey:@"Channel"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    [mdc_parameter setValue:lastTicks   forKey:@"lastTicks"];
    [mdc_parameter setValue:isBuyer     forKey:@"isBuyer"];
    [mdc_parameter setValue:isBigger    forKey:@"isBigger"];
    [mdc_parameter setValue:index       forKey:@"pageIndex"];
    [mdc_parameter setValue:size        forKey:@"pageSize"];
    
    
    AFHTTPRequestOperation *op = [self getServer:@"Act413" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act413 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", NO, nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic            = nil;
        NSArray         *ar             = nil;
        BOOL            isLastPage      = NO;
        NSMutableArray  *mar_list       = [[NSMutableArray alloc] init];
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), NO, nil);
            return;
        }
        dic         = [JSON objectForKey:@"Result"];
        if (!dic[@"IsLastPage"]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            isLastPage  = [dic[@"IsLastPage"] boolValue];
        }
        if (![dic[@"List"] isKindOfClass:[NSArray class]]) {
            Dlog(@"Error:获取服务器数据出错");
        }else{
            ar = dic[@"List"];
        }
        for (int i = 0; i < ar.count; i++) {
            WJBuyServiceListInfo *list    = [[WJBuyServiceListInfo alloc] init];
            if (![ar[i] isKindOfClass:[NSDictionary class]]) {
                Dlog(@"Error:获取服务器数据出错");
                return;
            }
            NSDictionary *dic_p         = ar[i];
            list.sBuyId          = FORMAT(@"%@", ([self isNull:dic_p[@"BuyId"]]?           @"": dic_p[@"BuyId"]));
            list.sBuyTime        = FORMAT(@"%@", ([self isNull:dic_p[@"BuyTime"]]?         @"": dic_p[@"BuyTime"]));
            list.sBuyer          = FORMAT(@"%@", ([self isNull:dic_p[@"Buyer"]]?           @"": dic_p[@"Buyer"]));
            list.sEndTime        = FORMAT(@"%@", ([self isNull:dic_p[@"EndTime"]]?         @"": dic_p[@"EndTime"]));
            list.sGold           = FORMAT(@"%@", ([self isNull:dic_p[@"Gold"]]?            @"": dic_p[@"Gold"]));
            list.sPersonalName   = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalName"]]?    @"": dic_p[@"PersonalName"]));
            list.sPersonalNo     = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalNo"]]?      @"": dic_p[@"PersonalNo"]));
            list.sSeller         = FORMAT(@"%@", ([self isNull:dic_p[@"Seller"]]?          @"": dic_p[@"Seller"]));
            list.status          = FORMAT(@"%@", ([self isNull:dic_p[@"Status"]]?          @"": dic_p[@"Status"])).integerValue;
            list.sUserNoBuyer    = FORMAT(@"%@", ([self isNull:dic_p[@"UserNoBuyer"]]?     @"": dic_p[@"UserNoBuyer"]));
            list.sUserNoSeller   = FORMAT(@"%@", ([self isNull:dic_p[@"UserNoSeller"]]?    @"": dic_p[@"UserNoSeller"]));
            list.sStatusText     = FORMAT(@"%@", ([self isNull:dic_p[@"StatusText"]]?      @"": dic_p[@"StatusText"]));
            [mar_list addObject:list];
        }
        block(YES, sCode, @"获取数据成功", isLastPage, mar_list);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", NO, nil);
    }];
    return op;
}

#pragma mark -- 获取购买服务详细信息(Act414)
- (AFHTTPRequestOperation *)getBuyServiceDetail:(HDUserInfo *)user buyId:(NSString *)buyId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBuyServiceDetailsInfo *detailsInfo))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || buyId.length == 0) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:@"0"                forKey:@"Culture"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:buyId               forKey:@"buyId"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act414" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act414 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"Act414 json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode          = nil;
        NSString        *sErrDesc       = nil;
        NSDictionary    *dic_p          = nil;
        NSDictionary    *dic_person     = nil;
        NSDictionary    *dic_appraise   = nil;
        WJBuyServiceDetailsInfo  *info  = [WJBuyServiceDetailsInfo new];
        dic_p           = [JSON objectForKey:@"Result"];
        dic_person      = dic_p[@"Person"];
        dic_appraise    = dic_p[@"Appraise"];
        
        sCode       = FORMAT(@"%@", ([JSON objectForKey:@"Code"]        == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        Dlog(@"dic = %@", dic_p);
        if (![sCode isEqualToString:@"0"]) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        info.sBuyId             = FORMAT(@"%@", ([self isNull:dic_p[@"buyId"]]?          @"": dic_p[@"buyId"]));
        info.sBuyTime           = FORMAT(@"%@", ([self isNull:dic_p[@"BuyTime"]]?        @"": dic_p[@"BuyTime"]));
        info.sPayTime           = FORMAT(@"%@", ([self isNull:dic_p[@"PayTime"]]?        @"": dic_p[@"PayTime"]));
        info.sAppriseTime       = FORMAT(@"%@", ([self isNull:dic_p[@"AppriseTime"]]?    @"": dic_p[@"AppriseTime"]));
        info.sBuyer             = FORMAT(@"%@", ([self isNull:dic_p[@"Buyer"]]?          @"": dic_p[@"Buyer"]));
        info.sEndTime           = FORMAT(@"%@", ([self isNull:dic_p[@"EndTime"]]?        @"": dic_p[@"EndTime"]));
        info.sGold              = FORMAT(@"%@", ([self isNull:dic_p[@"Gold"]]?           @"": dic_p[@"Gold"]));
        info.sPersonalName      = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalName"]]?   @"": dic_p[@"PersonalName"]));
        info.sPersonalNo        = FORMAT(@"%@", ([self isNull:dic_p[@"PersonalNo"]]?     @"": dic_p[@"PersonalNo"]));
        info.sSeller            = FORMAT(@"%@", ([self isNull:dic_p[@"Seller"]]?         @"": dic_p[@"Seller"]));
        info.sStatus            = FORMAT(@"%@", ([self isNull:dic_p[@"Status"]]?         @"": dic_p[@"Status"]));
        info.sUserNoBuyer       = FORMAT(@"%@", ([self isNull:dic_p[@"UserNoBuyer"]]?    @"": dic_p[@"UserNoBuyer"]));
        info.sUserNoSeller      = FORMAT(@"%@", ([self isNull:dic_p[@"UserNoSeller"]]?   @"": dic_p[@"UserNoSeller"]));
        info.sStatusText        = FORMAT(@"%@", ([self isNull:dic_p[@"StatusText"]]?     @"": dic_p[@"StatusText"]));
        info.sAvatarBuyer       = FORMAT(@"%@", ([self isNull:dic_p[@"AvatarBuyer"]]?    @"": dic_p[@"AvatarBuyer"]));
        info.sAvatarSeller      = FORMAT(@"%@", ([self isNull:dic_p[@"AvatarSeller"]]?   @"": dic_p[@"AvatarSeller"]));
        
        WJPersonalInfo *personal = [WJPersonalInfo new];
        if ((NSNull *)dic_person == [NSNull null]) {
            
        }else{
            personal.sSex               = FORMAT(@"%@", ([self isNull:dic_person[@"Sex"]]?              @"": dic_person[@"Sex"]));
            personal.sSexText           = FORMAT(@"%@", ([self isNull:dic_person[@"SexText"]]?          @"": dic_person[@"SexText"]));
            personal.sWorkYears         = FORMAT(@"%@", ([self isNull:dic_person[@"WorkYears"]]?        @"": dic_person[@"WorkYears"]));
            personal.sEduLevelText      = FORMAT(@"%@", ([self isNull:dic_person[@"EduLevelText"]]?     @"": dic_person[@"EduLevelText"]));
            personal.sAreaText          = FORMAT(@"%@", ([self isNull:dic_person[@"AreaText"]]?         @"": dic_person[@"AreaText"]));
            personal.sLastCompanyName   = FORMAT(@"%@", ([self isNull:dic_person[@"LastCompanyName"]]?  @"": dic_person[@"LastCompanyName"]));
            personal.sLastPosition      = FORMAT(@"%@", ([self isNull:dic_person[@"LastPosition"]]?     @"": dic_person[@"LastPosition"]));
        }
        info.sPerson = personal;
        
        WJAppraiseInfo *appraise = [WJAppraiseInfo new];
        if ((NSNull *)dic_appraise == [NSNull null]) {
            
        }else{
            appraise.sAppraiseTime      = FORMAT(@"%@", ([self isNull:dic_appraise[@"AppraiseTime"]]?   @"": dic_appraise[@"AppraiseTime"]));
            appraise.sEmail             = FORMAT(@"%@", ([self isNull:dic_appraise[@"Email"]]?          @"": dic_appraise[@"Email"]));
            appraise.sMPhone            = FORMAT(@"%@", ([self isNull:dic_appraise[@"MPhone"]]?         @"": dic_appraise[@"MPhone"]));
            appraise.sName              = FORMAT(@"%@", ([self isNull:dic_appraise[@"Name"]]?           @"": dic_appraise[@"Name"]));
            appraise.sPersonalNo        = FORMAT(@"%@", ([self isNull:dic_appraise[@"PersonalNo"]]?     @"": dic_appraise[@"PersonalNo"]));
            appraise.sRemark            = FORMAT(@"%@", ([self isNull:dic_appraise[@"Remark"]]?         @"": dic_appraise[@"Remark"]));
            appraise.sWX_QQ             = FORMAT(@"%@", ([self isNull:dic_appraise[@"WX_QQ"]]?          @"": dic_appraise[@"WX_QQ"]));
        }
        info.sAppraise = appraise;
        
        block(YES, sCode, @"获取成功", info);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;

}

#pragma mark -- 获取购买服务进展列表(Act415)
- (AFHTTPRequestOperation *)getBuyServiceProgress:(HDUserInfo *)user buyId:(NSString *)buyId completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || buyId == nil) {
        block(NO, nil, @"传入参数有误", nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:@"0"                forKey:@"Culture"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    [mdc_parameter setValue:buyId               forKey:@"buyId"];
    AFHTTPRequestOperation *op = [self getServer:@"Act415" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"Act415 http = %@", operation.response.URL);
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试", nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
        NSArray         *array      = [JSON objectForKey:@"Result"];
        NSMutableArray  *ary_data  = [[NSMutableArray alloc] init];
        if (![sCode isEqualToString:@"0"] || !array) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        for (int i = 0; i<array.count; i++) {
            NSDictionary *dic = array[i];
            WJServiceInfo *service = [[WJServiceInfo alloc] init];
            service.sCreatedTime    = FORMAT(@"%@",([self isNull:dic[@"CreatedTime"]]?      @"":dic[@"CreatedTime"]));
            service.sContent        = FORMAT(@"%@",([self isNull:dic[@"Content"]]?          @"":dic[@"Content"]));
            service.sProgress       = FORMAT(@"%@",([self isNull:dic[@"Progress"]]?         @"":dic[@"Progress"]));
            service.sProgressText   = FORMAT(@"%@",([self isNull:dic[@"ProgressText"]]?     @"":dic[@"ProgressText"]));
            [ary_data addObject:service];
        }
        
        block(YES, sCode, @"购买成功",ary_data );
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}

#pragma mark -- 购买简历服务(Act416)
- (AFHTTPRequestOperation *)buyResumeService:(HDUserInfo *)user personalNo:(NSString *)personalNo completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *buyId))block{
    if (user.sTocken.length == 0 || user.sHumanNo == nil || personalNo == nil) {
        block(NO, nil, @"传入参数有误",nil);
        Dlog(@"传入参数有误");
        return nil;
    }
    NSDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:@"0"                forKey:@"Culture"];
    [mdc_parameter setValue:personalNo          forKey:@"personalNo"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    AFHTTPRequestOperation *op = [self postServer:@"Act416" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Dlog(@"request http = %@", operation.response.URL);
    
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        Dlog(@"returned json = %@" , JSON);
        if (!JSON) {
            block(NO, nil, @"网络出错，请稍后再试",nil);
            return;
        }
        NSString        *sCode      = FORMAT(@"%@", ([self isNull:JSON[@"Code"]]?        @"": JSON[@"Code"]));
        NSString        *sErrDesc   = FORMAT(@"%@", ([self isNull:JSON[@"ErrorDesc"]]?   @"": JSON[@"ErrorDesc"]));
         NSString *buyid = [JSON objectForKey:@"Result"];
        if (![sCode isEqualToString:@"0"] || buyid == nil) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc), nil);
            return;
        }
        block(YES, sCode, @"购买成功", buyid);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Dlog(@"网络请求失败 failed %ld", (long)operation.response.statusCode);
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;

}

#pragma mark -- 商品系统参数（充值套餐Act608）
- (AFHTTPRequestOperation *)rechargeCombo:(HDUserInfo *)user completionBlock:(void (^)(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray))block{
    NSDictionary *mdc_parameter = [[NSMutableDictionary alloc] init];
    [mdc_parameter setValue:@"1"                forKey:@"Source"];
    [mdc_parameter setValue:PLATFORM            forKey:@"Platform"];
    [mdc_parameter setValue:[HDUtility uuid]    forKey:@"IMEI"];
    [mdc_parameter setValue:@"0"                forKey:@"Culture"];
    [mdc_parameter setValue:user.sHumanNo       forKey:@"UserID"];
    [mdc_parameter setValue:user.sTocken        forKey:@"Token"];
    
    AFHTTPRequestOperation *op = [self getServer:@"Act608" parameters:mdc_parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
         Dlog(@"Act608 http = %@", operation.response.URL);
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!JSON) {
            block(NO,nil,@"网络出错,请稍后再试", nil);
            return ;
        }
        NSString                *sCode          = nil;
        NSString                *sErrDesc       = nil;
        sCode       = FORMAT(@"%@",([JSON objectForKey:@"Code"]         == nil? @"": [JSON objectForKey:@"Code"]));
        sErrDesc    = FORMAT(@"%@", ([JSON objectForKey:@"ErrorDesc"]   == nil? @"": [JSON objectForKey:@"ErrorDesc"]));
        NSArray         *array      = [JSON objectForKey:@"Result"];
        NSMutableArray  *ary_data  = [[NSMutableArray alloc] init];

        if (![sCode isEqualToString:@"0"] || !array) {
            block(NO, sCode, (sErrDesc.length == 0? @"获取数据失败，请稍后再试": sErrDesc),nil);
            return;
        }

        for (int i = 0; i<array.count; i++) {
            NSDictionary *dic = array[i];
            WJMerchandiseListInfo *listInfo = [[WJMerchandiseListInfo alloc] init];
            listInfo.sMerchandiseName       = FORMAT(@"%@", ([self isNull:dic[@"MerchandiseName"]]?     @"":dic[@"MerchandiseName"]));
            listInfo.sMerchandiseCode       = FORMAT(@"%@", ([self isNull:dic[@"MerchandiseCode"]]?     @"":dic[@"MerchandiseCode"]));
            listInfo.sMerchandisePrice      = FORMAT(@"%@", ([self isNull:dic[@"MerchandisePrice"]]?    @"":dic[@"MerchandisePrice"]));
            listInfo.sBGPoint               = FORMAT(@"%@", ([self isNull:dic[@"BGPoint"]]?     @"":dic[@"BGPoint"]));
            listInfo.sPGPoint               = FORMAT(@"%@", ([self isNull:dic[@"PGPoint"]]?     @"":dic[@"PGPoint"]));
            listInfo.sRemark                = FORMAT(@"%@", ([self isNull:dic[@"Remark"]]?      @"":dic[@"Remark"]));
            listInfo.sStatus                = FORMAT(@"%@", ([self isNull:dic[@"Status"]]?      @"":dic[@"Status"]));
            listInfo.sShowNo                = FORMAT(@"%@", ([self isNull:dic[@"ShowNo"]]?      @"":dic[@"ShowNo"]));
            listInfo.sCreatedDT             = FORMAT(@"%@", ([self isNull:dic[@"CreatedDT"]]?   @"":dic[@"CreatedDT"]));
            listInfo.sUpdatedDT             = FORMAT(@"%@", ([self isNull:dic[@"UpdatedDT"]]?   @"":dic[@"UpdatedDT"]));
            listInfo.sAutold                = FORMAT(@"%@", ([self isNull:dic[@"Autold"]]?      @"":dic[@"Autold"]));
            listInfo.sProperty              = FORMAT(@"%@", ([self isNull:dic[@"Property"]]?    @"":dic[@"Property"]));
            [ary_data addObject:listInfo];
        }
        block(YES, sCode, @"获取成功", ary_data);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(NO, FORMAT(@"%d", (int)operation.response.statusCode), @"请求数据失败，请检查网络！", nil);
    }];
    return op;
}


@end





