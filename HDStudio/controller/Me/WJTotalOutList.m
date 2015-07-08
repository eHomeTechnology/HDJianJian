//
//  WJTotalOutList.m
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJTotalOutList.h"
#import "WJPayListCell.h"
#import "WJPayDetails.h"

@interface WJTotalOutList ()
@property (strong, nonatomic) IBOutlet UITableView  *tbv;
@property (strong, nonatomic) IBOutlet UIView       *v_head;
@property (strong, nonatomic) IBOutlet UILabel      *lb_totalOutMoney;
@property (strong, nonatomic) IBOutlet UILabel *lb_type;
@property (strong)  NSMutableArray                  *dataArray;
@property(nonatomic,assign)int indexPage;

@end

@implementation WJTotalOutList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indexPage = 1;
    self.lb_totalOutMoney.text = FORMAT(@"%@荐币",_money);
    [self setup];
    [self setTableViewHead];
    [self httpRequest];
}

- (void)viewWillDisappear:(BOOL)animated{
    //[self setHidesBottomBarWhenPushed:NO];
    [_op cancel];
    _op = nil;
}

- (void)setup{
    if([self.type isEqualToString:@"1"]){
        self.navigationItem.title = LS(@"WJ_TITLE_TOTALOUT_LIST");
        self.lb_type.text = @"共支付(荐币)";
    }else{
        self.navigationItem.title = LS(@"WJ_TITLE_TOTALIN_LIST");
        self.lb_type.text = @"共收入(荐币)";
    }

}

- (void)httpRequest{
    [self http:1 block:^(BOOL isLastPage, NSArray *money) {
        _isLastPage = isLastPage;
        self.dataArray = [NSMutableArray arrayWithArray:money];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    
}

- (void)setTableViewHead{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 105);
    [self.tbv setTableHeaderView:self.v_head];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    WJPayDetails *details = [[WJPayDetails alloc] initWithInfo:[self.dataArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJPayListCell";
    WJPayListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getPayListCell];
    }
    WJTradeRecordListInfo *tradeInfo = [_dataArray objectAtIndex:indexPath.row];
    if (tradeInfo.sOtherNickName.length == 0) {
        cell.lb_name.text = tradeInfo.sOtherNickName;
    }else{
        cell.lb_name.text = FORMAT(@"%@--",tradeInfo.sOtherNickName);
    }
    cell.lc_nameWithWidth.constant = [self viewWidth:cell.lb_name.text uifont:14];
    cell.lb_position.text = tradeInfo.sContent;
    if ([self.type isEqualToString:@"1"]) {
        cell.lb_price.text = FORMAT(@"-%@荐币",tradeInfo.sAmount);
    }else{
        cell.lb_price.text = FORMAT(@"+%@荐币",tradeInfo.sAmount);
    }
    cell.lb_time.text = tradeInfo.sCreatedTime;
    cell.lb_reward.text = tradeInfo.sTransactTypeText;

    return cell;
}

- (WJPayListCell *)getPayListCell{
    WJPayListCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPayListCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJPayListCell class]]) {
            cell = (WJPayListCell *)obj;
            break;
        }
    }
    return cell;
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
    [self http:1 block:^(BOOL isLastPage, NSArray *money) {
        _isLastPage = isLastPage;
        
        self.dataArray = [NSMutableArray arrayWithArray:money];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
}

//加载调用的方法
-(void)getNextPageView{
    [self http:++self.indexPage block:^(BOOL isLastPage, NSArray *money) {
        _isLastPage = isLastPage;
        [self.dataArray addObjectsFromArray:money];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    
    [self removeFooterView];
    [self completeRefresh];
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

- (void)http:(int)page block:(void(^)(BOOL isLastPage, NSArray *money))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    NSDate *date = [NSDate date];
    NSTimeInterval aInterval =[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", aInterval];

    _op = [[HDHttpUtility sharedClient] getTradeRecordList:[HDGlobalInfo instance].userInfo lastTicks:timeString szType:self.type index:FORMAT(@"%d",page) size:FORMAT(@"%d",24) completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *list) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
        }
        block(isLastPage,list);
    }];
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


//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(200, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+2;
    return width;
}

@end
