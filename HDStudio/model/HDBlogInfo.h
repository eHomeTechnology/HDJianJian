//
//  HDBlogInfo.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HDBlogType){

    HDBlogTypeText = 0,
    HDBlogTypePosition,
    HDBlogTypeResume,
};

@interface HDAdvertiseInfo : NSObject

@property (strong) NSString *sDescription;
@property (strong) NSString *sImageUrl;
@property (strong) NSString *sUrl;
@property (strong) NSString *sOrderBy;

@end

@interface HDBlogTextInfo : NSObject

@property (strong) NSString *sText;
@property (strong) NSArray  *ar_picUrls;

@end

@interface HDBlogInfo : NSObject

@property (strong) NSString *sBlogId;       //博客ID
@property (strong) NSString *sAuthorName;   //作者名字
@property (strong) NSString *sAuthorId;     //作者ID
@property (strong) NSString *sAuthorAvatar; //作者头像
@property (strong) NSString *sQuoteCount;   //转发次数
@property (strong) NSString *sCommentCount; //回复次数
@property (strong) NSString *sCollectCount; //收藏次数
@property (strong) NSString *sLikeCount;    //点赞次数
@property (strong) NSString *sCreateTime;   //添加时间
@property (assign) BOOL     isLike;         //是否点赞：true点赞，false未点赞
@property (assign) BOOL     isCollect;      //是否收藏：true收藏，false未收藏
@property (assign) BOOL     isTop;          //是否置顶：1是，0否
@property (assign) BOOL     isAttention;    //是否关注
@property (assign) BOOL     isExtended;     //position类型是否展开

@property (assign) HDBlogType       blogType;
@property (strong) HDBlogTextInfo   *blogTextInfo;
@property (strong) NSArray          *ar_positions;
@property (strong) NSArray          *ar_talents;
@end
