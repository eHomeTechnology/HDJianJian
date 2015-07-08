//
//  WJMyRecommendPersonalCtr.m
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJMyRecommendPersonalCtr.h"
#import "HDRcmdShowViewCtr.h"
#import "WJMyTalentCell.h"
#import "WJAddPersonalCtr.h"

@interface WJMyRecommendPersonalCtr ()

@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIView      *v_null;
@property (strong) IBOutlet UILabel     *lb_null;
@property (assign) int indexpage;
@property (strong) NSMutableArray *dataArray;

@end

@implementation WJMyRecommendPersonalCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
    [self setTableViewHead];
    [self setNavigationBarRightButton];
}

- (void)setNavigationBarRightButton{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 25)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setBackgroundImage:HDIMAGE(@"icon_addTalent") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doAddTalent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_MY_RECOMEND_PERSONAL");
}

- (void)doAddTalent:(id)sender{
    WJAddPersonalCtr *personal = [[WJAddPersonalCtr alloc] init];
    [self.navigationController pushViewController:personal animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTableViewHead{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tbv setTableHeaderView:v];
}

#pragma mark - 
#pragma mark - HttpRequest
- (void)httpRequest{
    _indexpage = 1;
    [self createHeaderView];
    [self http:1 block:^(BOOL isLastPage, NSArray *resumes) {
        _isLastPage = isLastPage;
        _dataArray  = [NSMutableArray arrayWithArray:resumes];
        [self.tbv reloadData];
    }];
}


#pragma mark - 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDRecommendInfo *recommendInfo = [_dataArray objectAtIndex:indexPath.row];
    HDRcmdShowViewCtr *ctr  = [[HDRcmdShowViewCtr alloc] initWithRecommendInfo:recommendInfo isMyRecommend:YES];
    [self.navigationController pushViewController:ctr animated:YES];
}



#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJMyTalentCell";
    WJMyTalentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJMyTalentCell getMyTalentCell];
    }
    HDRecommendInfo *recommendInfo = (HDRecommendInfo *)[_dataArray objectAtIndex:indexPath.row];
    cell.lb_progressState.text              = @"进展状态";
    cell.lb_progressState.textColor         = [UIColor blackColor];
    [cell.btn_progressState setTitle:recommendInfo.sProgressText forState:UIControlStateNormal];
    cell.btn_progressState.backgroundColor  = [UIColor colorWithRed:0.31f green:0.79f blue:0.61f alpha:1.00f];
    cell.lb_name.text                       = recommendInfo.sName;
    cell.lb_message.text                    = FORMAT(@"%@|%@|%@", recommendInfo.sEduLevel, recommendInfo.sSexText, recommendInfo.sWorkYears);
    cell.lb_curPosition.text                = recommendInfo.sCurPosition;
    
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

- (void)http:(int)page block:(void(^)(BOOL isLastPage, NSArray *resumes))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getMeRecommendResumeList:[HDGlobalInfo instance].userInfo pageIndex:FORMAT(@"%d",_indexpage) size:FORMAT(@"%d",24) CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
        [hud hiden];
        _isLastPage = isLastPage;
        if (ar_rcmd.count == 0) {
            [HDUtility mbSay:@"没有找到相关记录!"];
            self.tbv.backgroundColor = [UIColor clearColor];
            return ;
        }
        self.v_null.hidden  = YES;
        self.lb_null.hidden = YES;
        block(isLastPage, ar_rcmd);
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


@end
