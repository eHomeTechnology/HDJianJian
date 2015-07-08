//
//  WJHightTalentCtr.h
//  JianJian
//
//  Created by liudu on 15/5/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface WJHightTalentCtr : UIViewController<UIScrollViewDelegate, EGORefreshTableDelegate>{
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _isReloading;
    BOOL _isLastPage;
}
@property (strong) AFHTTPRequestOperation *op;

//- (id)initWithUserno:(NSString *)userno isTop:(BOOL)isTop;//是否置顶 是高级人才库 还是人选列表 (yes 高级)
- (id)initWithResumeDic:(NSDictionary *)dic isTop:(BOOL)isTop;

@end
