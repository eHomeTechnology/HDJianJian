//
//  HDMyOrderCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/15.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyOrderCtr.h"
#import "WJOrderListCell.h"
#import "WJCheckOrder.h"

@interface HDMyOrderCtr ()
@property (assign) int                       iOnIndex;
@property (assign) int                       iOffIndex;
@property (assign) BOOL                      isOnLastPage;
@property (assign) BOOL                      isOffLastPage;
@property (strong) AFHTTPRequestOperation    *op_popular;
@property (strong) AFHTTPRequestOperation    *op_credibility;

//区分人气和信誉度的排序选择
@property(nonatomic,assign)BOOL isRelseaseimentSorting;
@property(nonatomic,assign)BOOL isRewardSorting;
@property (nonatomic,assign)NSString * sortStr;
@property(nonatomic,assign)int indexPage;

@property (strong, nonatomic) IBOutlet UITableView *tbv;
/**
 *  发布时间
 */
@property (strong, nonatomic) IBOutlet UIButton *btn_releaseTime;
- (IBAction)releaseTime:(UIButton *)sender;
/**
 *  赏金
 */
@property (strong, nonatomic) IBOutlet UIButton *btn_reward;
- (IBAction)reward:(UIButton *)sender;

@end

@implementation HDMyOrderCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sortStr = @"1";
    self.indexPage = 1;
    self.btn_releaseTime.selected = YES;
    [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        self.ary_orderListData = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_MY_ORDER");
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op_popular) {
        [_op_popular cancel];
        _op_popular = nil;
    }
    if (_op_credibility) {
        [_op_credibility cancel];
        _op_credibility = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)releaseTime:(UIButton *)sender {
    if (self.isRelseaseimentSorting == NO) {
        self.isRelseaseimentSorting = YES;
        [sender setTitle:@"发布时间 ↓" forState:UIControlStateNormal];
        self.sortStr = @"2";
        [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
            _isLastPage  = isLastPage;
            self.ary_orderListData = [NSMutableArray arrayWithArray:positons];
            [self.tbv reloadData];
            [self completeRefresh];
        }];
    }else{
        self.isRelseaseimentSorting = NO;
        [sender setTitle:@"发布时间 ↑" forState:UIControlStateNormal];
        self.sortStr = @"1";
        [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
            _isLastPage  = isLastPage;
            self.ary_orderListData = [NSMutableArray arrayWithArray:positons];
            [self.tbv reloadData];
            [self completeRefresh];
        }];
    }
    sender.selected = YES;
    self.btn_reward.selected = NO;
    [self.btn_reward setTitle:@"赏金 ↑" forState:UIControlStateNormal];
    self.isRewardSorting = YES;
}
- (IBAction)reward:(UIButton *)sender {
        if (self.isRewardSorting == NO) {
            self.isRewardSorting = YES;
            [sender setTitle:@"赏金 ↓" forState:UIControlStateNormal];
            self.sortStr = @"7";
            [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positions){
                self.ary_orderListData = [NSMutableArray arrayWithArray:positions];
                [self.tbv reloadData];
                [self completeRefresh];
            }];
        }else{
            self.isRewardSorting = NO;
            [sender setTitle:@"赏金 ↑" forState:UIControlStateNormal];
            sender.selected = YES;
            self.btn_releaseTime.selected = NO;
            [self.btn_releaseTime setTitle:@"发布时间 ↑" forState:UIControlStateNormal];
            self.isRelseaseimentSorting = NO;
            self.sortStr = @"8";
            [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positions){
                self.ary_orderListData = [NSMutableArray arrayWithArray:positions];
                [self.tbv reloadData];
                [self completeRefresh];
            }];
        }
    sender.selected = YES;
    self.btn_releaseTime.selected = NO;
    [self.btn_releaseTime setTitle:@"发布时间 ↑" forState:UIControlStateNormal];
    self.isRelseaseimentSorting = YES;
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    WJPositionInfo *info = [self.ary_orderListData objectAtIndex:indexPath.row];
    WJCheckOrder *order = [[WJCheckOrder alloc] init];
    order.positionID = info.sPositionNo;
    [self.navigationController pushViewController:order animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ary_orderListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJOrderListCell";
    WJOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getListCell];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    WJPositionInfo *info = [self.ary_orderListData objectAtIndex:indexPath.row];
    cell.lb_position.text       = info.sPositionName;
    cell.lb_placeAndSalary.text = [NSString stringWithFormat:@"%@ | %@", info.sAreaText, info.sSalaryText];
    cell.lb_company.text        = info.employerInfo.sName;
   // cell.lb_salary.text         = FORMAT(@"¥%@",info.sSalaryText);
    
    if (info.isBonus == YES) {
        cell.lb_reward.text                 = [NSString stringWithFormat:@"%@荐币", info.sReward];
        cell.lc_rewardWithWidth.constant    = [self viewWidth:cell.lb_reward.text uifont:17];
    }else{
        cell.btn_reward.hidden  = YES;
        cell.lb_reward.hidden   = YES;
    }
    cell.lc_placeAndSalaryWithWidth.constant    = [self viewWidth:cell.lb_placeAndSalary.text uifont:14];

    if (info.isDeposit) {
        cell.v_ensure.hidden = NO;
    }else{
        cell.v_ensure.hidden = YES;
        cell.lc_salaryWithWidth.constant = 0;
    }
    return cell;
}

- (WJOrderListCell *)getListCell{
    WJOrderListCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJOrderListCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJOrderListCell class]]) {
            cell = (WJOrderListCell *)obj;
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
    [self http:1 sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        
        self.ary_orderListData = [NSMutableArray arrayWithArray:positons];
        [self.tbv reloadData];
        [self completeRefresh];
        
    }];
    
}

//加载调用的方法
-(void)getNextPageView{
    
    [self http:++self.indexPage sort:self.sortStr block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        
        [self.ary_orderListData addObjectsFromArray:positons];
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
    _op = [[HDHttpUtility sharedClient] getMyRecommendOrder:[HDGlobalInfo instance].userInfo sort:sort pageIndex:FORMAT(@"%d",page) size:FORMAT(@"%d",24) completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        block(isLastPage,talents);
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

- (void)viewDidAppear:(BOOL)animated{
    [self.tbv reloadData];
}



@end
