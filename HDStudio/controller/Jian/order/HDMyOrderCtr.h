//
//  HDMyOrderCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/15.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface HDMyOrderCtr : UIViewController<UIScrollViewDelegate, EGORefreshTableDelegate>{
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _isReloading;
    BOOL _isLastPage;
}
@property (strong) AFHTTPRequestOperation *op;

//用来接收数据
@property (strong) NSMutableArray *ary_orderListData;

@end
