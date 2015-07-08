//
//  HDShopInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 15/3/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDShopInfo : NSObject

@property (strong) NSString     *sShopName;             //才铺名称
@property (strong) NSString     *sAnnounce;             //公告
@property (strong) NSString     *sUrlBackground;        //招牌背景url
@property (strong) NSString     *sUrlLogo;              //logo的网络url
@property (strong) NSString     *sPathBackground;       //招牌背景本地地址
@property (strong) NSString     *sPathLogo;             //logo本地地址
@property (strong) NSString     *sMPhone;               //联系电话
@property (strong) NSString     *sCreateDate;           //才铺创建时间
@property (strong) NSString     *sUpdateDate;           //才铺更新时间
@property (strong) NSString     *sProperty;             //不知道什么
@property (strong) NSString     *sQQ;                   //qq
@property (strong) NSString     *sUserNumber;           //用户ID
@property (strong) NSString     *sWXUserName;           //微信
@property (strong) NSString     *sUrl;                  //才铺网络预览地址

- (void)sift;

@end

/*
 
 Code = 0;
 Result =     {
     Announce = "\U6211\U7684\U5de5\U4f53";
     BackGround = "http://fuzhouliudu.eicp.net:30001/TempFiles/ShopLogo/b169c237-0ff2-40ed-b736-dd41529f283b.jpg";
     CreatedDT = "/Date(1423561365510)/";
     Logo = "http://fuzhouliudu.eicp.net:30001/TempFiles/ShopLogo/98f92826-bd42-45d3-95d4-08bd67295ddf.jpg";
     MPhone = 13799422804;
     Property = 1;
     QQ = 584864;
     ShopName = "\U5815\U843d\U6c38\U6052";
     UpdatedDT = "/Date(1425263019270)/";
     UserNo = 100002;
     WXUserName = 123456;
 }
 */