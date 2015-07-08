//
//  WJOrderListView.h
//  JianJian
//
//  Created by liudu on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface WJOrderListCtr : UIViewController<UIScrollViewDelegate, EGORefreshTableDelegate>{
    //EGOHeader
    EGORefreshTableHeaderView *_refreshHeaderView;
    //EGOFoot
    EGORefreshTableFooterView *_refreshFooterView;
    //
    BOOL _isReloading;
    BOOL _isLastPage;
}
@property (strong) AFHTTPRequestOperation *op;

- (id)initWithPositionDic:(NSDictionary *)dic isOrderList:(BOOL)isOrderList;//dic 搜索对应的参数 (YES 订单列表  NO悬赏专区)

////用来接收数据
//@property (strong) NSMutableArray *ary_orderListData;
////搜索对应到参数
//@property (strong,nonatomic) NSArray *typeAry;
//@property (assign)          BOOL  isOrderList;  //(YES 订单列表  NO悬赏专区)

@property (strong, nonatomic) IBOutlet UITableView *tbv;
/**
 *  发布时间
 */
@property (strong, nonatomic) IBOutlet UIButton *btn_releaseTime;
- (IBAction)releaseTime:(UIButton *)sender;

/**
*   赏金
*/
@property (strong, nonatomic) IBOutlet UIButton *btn_reward;
- (IBAction)reward:(UIButton *)sender;

@end
