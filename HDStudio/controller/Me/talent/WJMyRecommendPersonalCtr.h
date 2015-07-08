//
//  WJMyRecommendPersonalCtr.h
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface WJMyRecommendPersonalCtr : UIViewController<UIScrollViewDelegate, EGORefreshTableDelegate>
{
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _isReloading;
    BOOL _isLastPage;
}
@property (strong) AFHTTPRequestOperation *op;

@end
