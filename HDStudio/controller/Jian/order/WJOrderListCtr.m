//
//  WJOrderListView.m
//  JianJian
//
//  Created by liudu on 15/4/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJOrderListCtr.h"
#import "WJOrderListCell.h"
#import "WJPositionInfo.h"
#import "WJCheckOrder.h"
#import "WJCheckPositionCtr.h"

@interface WJOrderListCtr ()
@property (assign) int                       iOnIndex;
@property (assign) int                       iOffIndex;
@property (assign) BOOL                      isOnLastPage;
@property (assign) BOOL                      isOffLastPage;
@property (strong) AFHTTPRequestOperation    *op_popular;
@property (strong) AFHTTPRequestOperation    *op_credibility;
@property (strong) IBOutlet UIImageView *v_null;
@property (strong) IBOutlet UILabel *lb_null;

@property (strong) NSDictionary *typeDic ;
@property (assign) BOOL         isOrderList;
@property (strong) NSMutableArray *ary_OrderList;

//区分人气和信誉度的排序选择
@property(nonatomic,assign)BOOL isRelseaseimentSorting;
@property(nonatomic,assign)BOOL isRewardSorting;
@property (nonatomic,assign)NSString * sortStr;
@property(nonatomic,assign)int indexPage;

@end

@implementation WJOrderListCtr

- (id)initWithPositionDic:(NSDictionary *)dic isOrderList:(BOOL)isOrderList{
    self = [super init];
    if (self) {
        _typeDic        = dic;
        _isOrderList    = isOrderList;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    //[self setHidesBottomBarWhenPushed:NO];
    if (_op_popular) {
        [_op_popular cancel];
        _op_popular = nil;
    }
    if (_op_credibility) {
        [_op_credibility cancel];
        _op_credibility = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indexPage = 1;
    self.btn_releaseTime.selected = YES;
    self.sortStr = @"0";
    [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        self.ary_OrderList = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    [self setup];
}

- (void)viewDidLayoutSubviews{
    [self createHeaderView];
}

- (void)setup{
    if (_isOrderList) {
        self.navigationItem.title = LS(@"WJ_TITLE_ORDER_LIST");
    }else{
        self.navigationItem.title = LS(@"WJ_TITLE_POST_REWARD");
    }
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 65, 25);
    rightButton.layer.masksToBounds = YES;
    rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    rightButton.layer.borderWidth = 0.5;
    rightButton.layer.cornerRadius = 10.0;
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"荐币说明" forState:UIControlStateNormal];
    
    [rightButton addTarget:self action:@selector(getDescription) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)getDescription{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"荐币用于人才服务的交易,1元=10荐币。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)releaseTime:(UIButton *)sender {
    [self.tbv setContentOffset:CGPointMake(0, 0) animated:NO];
    self.sortStr = @"0";
    [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        [sender setTitle:@"综合排序" forState:UIControlStateNormal];
        _isLastPage = isLastPage;
        self.ary_OrderList = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    sender.selected = YES;
    self.btn_reward.selected = NO;
    [self.btn_reward setTitle:@"赏金(荐币) ↑" forState:UIControlStateNormal];
    self.isRewardSorting = YES;
}

- (IBAction)reward:(UIButton *)sender {
    [self.tbv setContentOffset:CGPointMake(0, 0) animated:NO];
    if (self.isRewardSorting == NO) {
        self.isRewardSorting = YES;
        [sender setTitle:@"赏金(荐币) ↓" forState:UIControlStateNormal];
        self.sortStr = @"6";
        [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positions){
            self.ary_OrderList = [NSMutableArray arrayWithArray:positions];
            [self.tbv reloadData];
            [self completeRefresh];
        }];
    }else{
        self.isRewardSorting = NO;
        [sender setTitle:@"赏金(荐币) ↑" forState:UIControlStateNormal];
        sender.selected = YES;
        self.btn_releaseTime.selected = NO;
        [self.btn_releaseTime setTitle:@"综合排序" forState:UIControlStateNormal];
        self.isRelseaseimentSorting = NO;
        self.sortStr = @"5";
        [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positions){
            self.ary_OrderList = [NSMutableArray arrayWithArray:positions];
            [self.tbv reloadData];
            [self completeRefresh];
        }];
    }
    sender.selected = YES;
    self.btn_releaseTime.selected = NO;
    [self.btn_releaseTime setTitle:@"综合排序" forState:UIControlStateNormal];
    self.isRelseaseimentSorting = YES;
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    WJPositionInfo *info = [self.ary_OrderList objectAtIndex:indexPath.row];
    WJCheckPositionCtr *position = [[WJCheckPositionCtr alloc] initWithPositionId:info.sPositionNo];
    [self.navigationController pushViewController:position animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ary_OrderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJOrderListCell";
    WJOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [WJOrderListCell getListCell];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    WJPositionInfo *info = [self.ary_OrderList objectAtIndex:indexPath.row];
    cell.lb_position.text         = info.sPositionName;
    NSString *str = info.sAreaText.length > 0? info.sAreaText: @"";
    str = [str stringByAppendingString:(info.sSalaryText.length > 0? FORMAT(@" | %@", info.sSalaryText): @"")];
    if ([str hasPrefix:@" | "]) {
        str = [str substringFromIndex:3];
    }
    cell.lb_placeAndSalary.text   = str;
    cell.lb_company.text          = info.employerInfo.sName;
    if (info.sReward.length == 0) {
        cell.btn_reward.hidden  = YES;
        cell.lb_reward.hidden   = YES;
    }else{
        cell.lb_reward.text = info.sReward;
        cell.lc_rewardWithWidth.constant = [self viewWidth:cell.lb_reward.text uifont:17];
    }
    cell.lc_placeAndSalaryWithWidth.constant    = [self viewWidth:cell.lb_placeAndSalary.text uifont:14];
    if (info.isDeposit) {
        cell.v_ensure.hidden = NO;
        cell.lc_salaryWithWidth.constant = [self viewWidth:@"全额保证金" uifont:14];
    }else{
        cell.v_ensure.hidden = YES;
        cell.lc_salaryWithWidth.constant = 0;
    }
    [cell updateConstraints];

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
    [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        self.ary_OrderList = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
}

//加载调用的方法
-(void)getNextPageView{
    [self http:++self.indexPage sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        [self.ary_OrderList addObjectsFromArray:positons];
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

- (void)http:(int)page sort:(NSString *)sort block:(void(^)(BOOL isLastPage, NSArray *positons))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    _op = [[HDHttpUtility sharedClient] checkPosition:[HDGlobalInfo instance].userInfo typeDic:_typeDic sort:sort pageIndex:FORMAT(@"%d",page) size:FORMAT(@"%d", 24) completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents){
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.tbv.hidden     = !talents.count;
        self.v_null.hidden  = talents.count;
        self.lb_null.hidden = talents.count;
        block(isLastPage, talents);
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
    CGSize constraint = CGSizeMake(120, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+2;
    return width;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tbv reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
