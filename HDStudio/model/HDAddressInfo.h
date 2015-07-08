//
//  HDAddressInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDAddressInfo : NSObject

@property (strong) NSString     *sClientDownload;       //app客户端下载地址
@property (strong) NSString     *sDataVersion;          //数据版本
@property (strong) NSString     *sWebsite_waproot;      //我的店铺网络地址
@property (strong) NSString     *sWebsite_webroot;
@property (strong) NSString     *sWebsite_approot;
@property (strong) NSString     *sCloudsite_webroot;
@property (strong) NSString     *sLogo_shop;
@property (strong) NSString     *sLogo_position;
@property (strong) NSString     *sLogo_app;
/*
    {"CLIENTDOWNDRESS":"http://fuzhouliudu.eicp.net:30001/app/Microhunter.apk","DATAVERSION":"20140901","WEBSITE_WAPROOT":"http://fuzhouliudu.eicp.net:30002/","WEBSITE_WEBROOT":"","WEBSITE_APPROOT":"http://fuzhouliudu.eicp.net:30001/","CLOUDSITE_WEBROOT":"http://export.liudu.com/api/","LOGO_SHOP":"http://fuzhouliudu.eicp.net:30001/Images/Logo/Shop.jpg","LOGO_POSITION":"http://fuzhouliudu.eicp.net:30001/Images/Logo/App.png","LOGO_APP":"http://fuzhouliudu.eicp.net:30001/Images/Logo/App.png"
    }
 */


@end
