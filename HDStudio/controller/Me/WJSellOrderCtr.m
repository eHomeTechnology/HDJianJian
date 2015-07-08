//
//  WJSellOrder.m
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSellOrderCtr.h"
#import "WJSellOrderCell.h"
#import "WJCheckServiceCtr.h"
#import "WJRecommendPersonalCtr.h"

@interface WJSellOrderCtr ()

@property (strong) IBOutlet UITableView  *tbv;
@property (strong) IBOutlet UIImageView  *v_null;
@property (strong) IBOutlet UILabel      *lb_null;
@property (assign) int                    indexpage;
@property (strong) NSMutableArray        *dataArray;
@property (assign) BOOL                   isSellService;

@end

@implementation WJSellOrderCtr

- (id)initWithIsSellService:(BOOL)isSellService{
    self = [super init];
    if (self) {
        _isSellService = isSellService;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:WJ_NOTIFICATION_KEY_DONE_SERVICE object:nil];
}

- (void)reloadData{
    [self httpRequest];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WJ_NOTIFICATION_KEY_DONE_SERVICE object:nil];
}

- (void)viewWillLayoutSubviews{
    [self createHeaderView];
}

- (void)setup{
    self.tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_isSellService) {
        self.navigationItem.title = LS(@"WJ_TITLE_SELL_SERVICE_LIST");
        return;
    }
    self.navigationItem.title = LS(@"WJ_TITLE_BUY_SERVICE_LIST");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 164;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0.1;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    WJBuyServiceListInfo *listInfo = [_dataArray objectAtIndex:section];
    if (_isSellService) {
        if (listInfo.status == HDBuyServiceStatusPayed) {
            return 44;
        }
        return 20;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_isSellService) {
        WJBuyServiceListInfo *listInfo = [_dataArray objectAtIndex:section];
        if (listInfo.status == HDBuyServiceStatusPayed) {
            static NSString *cellIdentifier = @"2222";
            UIView *v_foot = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
            if (!v_foot) {
                v_foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 44)];
                v_foot.backgroundColor = [UIColor whiteColor];
                UIView *v_line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, HDDeviceSize.width-20, 0.5)];
                v_line.backgroundColor = [UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f];
                [v_foot addSubview:v_line];
                
                UIButton *btn_status = [UIButton buttonWithType:UIButtonTypeCustom];
                btn_status.frame = CGRectMake(HDDeviceSize.width - 90, 7, 80, 30);
                [btn_status setTitle:@"推荐人选" forState:UIControlStateNormal];
                btn_status.titleLabel.font = [UIFont systemFontOfSize:14];
                [btn_status setBackgroundColor:[UIColor redColor]];
                btn_status.layer.cornerRadius   = 5;
                btn_status.layer.masksToBounds  = YES;
                btn_status.tag = section;
                [btn_status addTarget:self action:@selector(doRecomendPersonal:) forControlEvents:UIControlEventTouchUpInside];
                [v_foot addSubview:btn_status];
                 return v_foot;
            }
           
        }else{
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
            return v;
        }
    }
    static NSString *cellIdentifier = @"11111";
    UIView *v_foot = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (!v_foot) {
        v_foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 44)];
        v_foot.backgroundColor = [UIColor whiteColor];
        
        UIView *v_line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, HDDeviceSize.width-20, 1)];
        v_line.backgroundColor = [UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f];
        [v_foot addSubview:v_line];
        
        UIButton *btn_status = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_status.frame = CGRectMake(HDDeviceSize.width-90, 5,80, 30);
        [btn_status setTitle:@"查看" forState:UIControlStateNormal];
        btn_status.titleLabel.font = [UIFont systemFontOfSize:15];
        btn_status.layer.cornerRadius = 5.0;
        btn_status.layer.masksToBounds  = YES;
        [btn_status setBackgroundColor:[UIColor redColor]];
        btn_status.tag = section;
        [btn_status addTarget:self action:@selector(checkService:) forControlEvents:UIControlEventTouchUpInside];
        [v_foot addSubview:btn_status];
    }
    
    return v_foot;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJSellOrderCell";
    WJSellOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJSellOrderCell getSellOrderCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WJBuyServiceListInfo *listInfo = [_dataArray objectAtIndex:indexPath.section];
    cell.lb_buyId.text          = listInfo.sBuyId;
    cell.lb_status.text         = listInfo.sStatusText;
    cell.lb_personalName.text   = listInfo.sPersonalName;
    cell.lb_buyer.text          = listInfo.sSeller;
    cell.lb_buyTime.text        = listInfo.sBuyTime;
    cell.lb_endTime.text        = listInfo.sEndTime;
    cell.lb_gold.text           = listInfo.sGold;
    return cell;
}

#pragma mark -- HttpRequest
- (void)httpRequest{
    _indexpage = 1;
    [self http:1 block:^(BOOL isLastPage, NSArray *list) {
        _isLastPage = isLastPage;
        _dataArray  = [NSMutableArray arrayWithArray:list];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
}

#pragma mark - EGODelegate
-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self.tbv addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)setFooterView{
    if (_refreshFooterView &&[_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
    if (_isLastPage) {
        return;
    }
    CGFloat height = MAX(self.tbv.contentSize.height, self.tbv.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.tbv.frame.size.width,
                                              self.view.bounds.size.height);
    }else{
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height, self.tbv.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.tbv addSubview:_refreshFooterView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    _isReloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        [self refreshView];
    }else if(aRefreshPos == EGORefreshFooter){
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:2.0];
    }
}

- (void)refreshView{
    [self http:1  block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        _dataArray = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
        
    }];
    
}

//加载调用的方法
-(void)getNextPageView{
    
    [self http:++self.indexpage  block:^(BOOL isLastPage, NSArray *resumes) {
        _isLastPage  = isLastPage;
        
        [_dataArray addObjectsFromArray:resumes];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    
    
    [self removeFooterView];
    
    [self completeRefresh];
}

- (void)http:(int)page block:(void(^)(BOOL isLastPage, NSArray *list))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    NSDate *date = [NSDate date];
    NSTimeInterval aInterval =[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", aInterval];
    
    NSString *isBuyer = nil;
    if (_isSellService) {
        isBuyer = @"0";
    }else{
        isBuyer = @"1";
    }
    _op = [[HDHttpUtility sharedClient] getBuyServiceList:[HDGlobalInfo instance].userInfo lastTicks:timeString isBuyer:isBuyer isBigger:@"1" pageIndex:FORMAT(@"%d",_indexpage) size:FORMAT(@"%d",24) completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *orderList) {
        [hud hiden];
        _isLastPage = isLastPage;
        if (orderList.count == 0) {
            [HDUtility mbSay:@"没有找到相关记录!"];
            self.tbv.backgroundColor = [UIColor clearColor];
            return ;
        }
        self.v_null.hidden  = YES;
        self.lb_null.hidden = YES;
        block(isLastPage, orderList);
    }];
    
}

-(void)removeFooterView{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
}

-(void)completeRefresh{
    [self finishReloadingData];
    [self setFooterView];
}

- (void)finishReloadingData{
    _isReloading = NO;
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv];
    }
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv];
        [self setFooterView];
    }
}


#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - EGODelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    return _isReloading;
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
    return [NSDate date];
}


#pragma mark -- ButtonOnClick
- (void)checkService:(UIButton *)button{
    WJBuyServiceListInfo *info = [_dataArray objectAtIndex:button.tag];
    WJCheckServiceCtr *check = [[WJCheckServiceCtr alloc] initWithBuyId:info.sBuyId status:info.sStatusText personal:info.sUserNoSeller];
    [self.navigationController pushViewController:check animated:YES];
}

- (void)doRecomendPersonal:(UIButton *)button{
    WJBuyServiceListInfo *info = [_dataArray objectAtIndex:button.tag];
    [self.navigationController pushViewController:[[WJRecommendPersonalCtr alloc] initWithBuyServiceListInfo:info] animated:YES];
}

@end
