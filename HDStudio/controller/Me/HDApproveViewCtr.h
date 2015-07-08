//
//  HDApproveViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HDApproveStatus) {

    HDApproveStatusUnknown = 0,     //未审核
    HDApproveStatusPassed,          //审核通过
    HDApproveStatusNotPassed,       //审核未通过
};

typedef NS_ENUM(NSInteger, HDApproveType) {

    HDApproveTypePersonal   = 100,
    HDApproveTypeEnterprise = 200,
};

@interface HDApproveInfo : NSObject

@property (strong) NSString     *sUserNo;       //用户编号
@property (strong) NSString     *sAutoId;       //认证ID
@property (strong) NSString     *sCompanyName;  //认证公司名称
@property (strong) NSString     *sCreatedDT;    //添加时间
@property (strong) NSString     *sPosition;     //认证职位
@property (strong) NSString     *sRealName;     //真实姓名
@property (strong) NSString     *sRemark;       //备注
@property (strong) NSString     *sScene01;      //企业认证图片

@property (assign) HDApproveStatus approveStatus;    //状态：0，未审核；1，通过；2，不通过
@property (assign) HDApproveType   approveType;      //认证类型：100，个人认证；200，企业认证


@end

@interface HDApproveViewCtr : UIViewController

@end
