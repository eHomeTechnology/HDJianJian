//
//  WJBrokerList.h
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface WJBrokerListCtr : UIViewController<UIScrollViewDelegate, EGORefreshTableDelegate>{
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _isReloading;
    BOOL _isLastPage;
}
@property (strong) AFHTTPRequestOperation *op;

/**
 *  荐客列表数据
 */
@property (strong, nonatomic)NSMutableArray * brokerDataAry;

//搜索对应到参数
@property (strong,nonatomic) NSDictionary *typeDic;

@end
