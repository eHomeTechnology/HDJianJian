//
//  HDTalentInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDHumanInfo : NSObject
@property (strong) NSString *sName;             //人才姓名
@property (strong) NSString *sHumanNo;          //人才编号
@property (strong) NSString *sPhone;            //人才手机号
@property (strong) NSString *sSexText;          //性别
@property (strong) NSString *sAvatarUrl;        //头像URL地址
@property (assign) BOOL     isMale;             //YES:男, NO:女
@end

@interface HDTalentInfo : HDHumanInfo
@property (strong) NSString *sAreaText;         //工作地点
@property (strong) NSString *sCreatedTime;      //添加人才时间
@property (strong) NSString *sCurCompanyName;   //人才目前公司名称
@property (strong) NSString *sCurPosition;      //人才目前职位名称
@property (strong) NSString *sEduLevel;         //学历
@property (strong) NSString *sEduLecelKey;
@property (strong) NSString *sWorkYears;        //人才工作年限,工作经验
@property (strong) NSString *sMatchCount;       //
@property (strong) NSString *sStartWorkTime;    //开始工作时间,发布时间
@property (strong) NSString *sRemark;           //简介,文本简历
@property (strong) NSString *sPersonalDesc;     //人选描述
@property (strong) NSString *sProperty;         //属性
@property (strong) NSString *sArea;             //居住地编号,key
@property (strong) NSString *sFunctionText;     //推荐职位
@property (strong) NSString *sBusinessText;     //推荐行业
@property (strong) NSString *sWorkPlaceText;    //推荐地区
@property (strong) NSString *sNickName;         //荐客昵称
@property (strong) NSString *sUserNo;           //荐客编号
@property (strong) NSString *sShopType;         //荐客类别
@property (strong) NSString *sRoleType;         //角色类别
@property (strong) NSString *sMemberLevel;      //会员级别
@property (strong) NSString *sServiceFee;       //服务费用
@property (strong) NSString *sSex;
@property (assign) BOOL     isOpen;             //简历是否发布
@property (assign) BOOL     isFocus;            //是否关注
@property (assign) BOOL     isBuy;              //是否购买
@property (assign) BOOL     isCollect;          //是否收藏
@end

@interface HDRecommendInfo : HDTalentInfo

@property (strong) NSString     *sRecommendId;          //推荐编号
@property (strong) NSString     *sPositionID;           //职位编号
@property (strong) NSString     *sPositionName;         //职位名称
@property (strong) NSString     *sPositionDes;          //职位描述
@property (strong) NSString     *sEnterpriseID;         //雇主公司编号
@property (strong) NSString     *sEnterpriseText;       //雇主公司名称
@property (strong) NSString     *sProgress;             //反馈状态
@property (strong) NSString     *sRefereeId;            //推荐人编号
@property (strong) NSString     *sRefereeName;          //推荐人名字
@property (strong) NSString     *sRefereeCompanyName;   //推荐人公司名字
@property (strong) NSString     *sRefereePosition;      //推荐人职位
@property (strong) NSString     *sRefereeMPhone;        //推荐人电话
@property (strong) NSString     *sEducation;
@property (strong) NSString     *sProgressText;         //反馈状态文本
@property (assign) BOOL          isBonus;
@property (assign) BOOL          isDeposit;
@property (assign) BOOL          isFromCloud;
@property (assign) BOOL          isHaveBonus;
@end