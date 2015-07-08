//
//  HDNewShopViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewShopViewCtr.h"
#import "HDUserInfo.h"
#import "HDCompleteViewCtr.h"

@interface HDNewShopViewCtr (){

    IBOutlet UITextField    *tf_shopName;
    IBOutlet UITextField    *tf_phone;
    IBOutlet UITextField    *tf_weixin;
    IBOutlet UITextField    *tf_qq;
    HDUserInfo              *userInfo;
}

@end

@implementation HDNewShopViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = @"创建才铺";
    NSString *sAccount = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER];
    NSArray *ar = [HDUserInfo dbObjectsWhere:FORMAT(@"sAccount == %@", sAccount) orderby:nil];
    if (ar.count > 0) {
        userInfo = ar[0];
        if (!userInfo) {
            Dlog(@"Error:读取数据库用户数据出错");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doNext:(id)sender{
    if (tf_qq.text.length > MAX_QQ_NAME || tf_weixin.text.length > MAX_WEIXIN_NAME) {
        [HDUtility say:@"qq和微信名称不正确"];
        return;
    }
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"请输入正确的手机号"];
        return;
    }
    if (tf_shopName.text.length == 0) {
        [HDUtility say:@"请输入才铺名称"];
        return;
    }
    if (tf_shopName.text.length > MAX_SHOP_NAME) {
        [HDUtility say:FORMAT(@"才铺名称最大不超过%d个字符", MAX_SHOP_NAME)];
        return;
    }
    
    userInfo.sShopName  = tf_shopName.text;
    userInfo.sPhone     = tf_phone.text;
    userInfo.sQQ        = tf_qq.text;
    userInfo.sWeixin    = tf_weixin.text;
    HDHUD *hud = [HDHUD showLoading:@"创建中..." on:self.navigationController.view];
    [[HDHttpUtility sharedClient] createShop:userInfo CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (isSuccess) {
            if ([userInfo updatetoDb]) {
                [self.navigationController pushViewController:[HDCompleteViewCtr new] animated:YES];
            }
        }else{
            [HDUtility say:FORMAT(@"%@%@", sCode, sMessage)];
        }
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_phone       resignFirstResponder];
    [tf_qq          resignFirstResponder];
    [tf_shopName    resignFirstResponder];
    [tf_weixin      resignFirstResponder];
}

@end
