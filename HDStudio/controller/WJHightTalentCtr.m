//
//  WJHightTalentCtr.m
//  JianJian
//
//  Created by liudu on 15/5/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJHightTalentCtr.h"
#import "WJHightTalentCell.h"
#import "WJTalentDetailCtr.h"
#import "WJCheckPersonalDetailCtr.h"

@interface WJHightTalentCtr ()
@property (strong) IBOutlet UITableView *tbv;
@property (assign) int indexpage;
@property (strong) NSMutableArray *dataArray;
@property (strong) IBOutlet UIImageView *v_null;
@property (strong) IBOutlet UILabel *lb_null;

@property (strong) NSDictionary *resumeDic; //人才搜索对应的参数
@property (assign) BOOL     isTop;

@end

@implementation WJHightTalentCtr

- (id)initWithResumeDic:(NSDictionary *)dic isTop:(BOOL)isTop{
    self = [super init];
    if (self) {
        _resumeDic = dic;
        _isTop     = isTop;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
}

- (void)viewWillLayoutSubviews{
    [self createHeaderView];
}
- (void)setup{
    if (_isTop){
        self.navigationItem.title = LS(@"WJ_TITLE_HIGHT_TALENT");
    }else{
        self.navigationItem.title = LS(@"WJ_TITLE_TALENT_LIST");
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

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDTalentInfo    *talentInfo = [_dataArray objectAtIndex:indexPath.row];
    if ([talentInfo.sUserNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo]){
        WJCheckPersonalDetailCtr *personal = [[WJCheckPersonalDetailCtr alloc] initWithPersonalno:talentInfo.sHumanNo isOpen:YES];
        [self.navigationController pushViewController:personal animated:YES];
        return;
    }
    WJTalentDetailCtr *detail = [[WJTalentDetailCtr alloc] initWithTalentId:talentInfo.sHumanNo isMeCheckResume:NO];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier  = @"WJHightTalentCell";
    WJHightTalentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJHightTalentCell getHightTalentCell];
    }
    HDTalentInfo *talenInfo   = [_dataArray objectAtIndex:indexPath.row];
    if ([talenInfo.sSexText isEqualToString:@"1"]){
        cell.img_head.image = HDIMAGE(@"v_boy");
    }else if ([talenInfo.sSexText isEqualToString:@"2"]){
        cell.img_head.image = HDIMAGE(@"v_girl");
    }else{
        cell.img_head.image = HDIMAGE(@"v_boy");
    }
    cell.lb_position.text   = talenInfo.sCurPosition;
    NSString *str = talenInfo.sAreaText.length > 0? talenInfo.sAreaText: @"";
    NSArray *ar = @[talenInfo.sEduLevel? talenInfo.sEduLevel: @"", talenInfo.sSexText? talenInfo.sSexText: @"", talenInfo.sWorkYears? talenInfo.sWorkYears: @""];
    for (int i = 0; i < ar.count; i++) {
        NSString *s = ar[i];
        str = [str stringByAppendingString:s.length > 0? FORMAT(@" | %@", s): @""];
    }
    if ([str hasPrefix:@" | "]) {
        str = [str substringFromIndex:3];
    }
    cell.lb_message.text    = str;
    cell.lb_company.text    = talenInfo.sCurCompanyName;
    cell.lb_price.text      = FORMAT(@"%@荐币",talenInfo.sServiceFee);
    cell.lb_name.text       = talenInfo.sNickName;
    cell.lc_name.constant   = [HDJJUtility withOfString:talenInfo.sNickName font:[UIFont systemFontOfSize:14] widthMax:150]; 
    cell.lc_price.constant  = [HDJJUtility withOfString:cell.lb_price.text font:[UIFont systemFontOfSize:17] widthMax:150];
    if ([talenInfo.sRoleType isEqualToString:@"0"]) {
        cell.img_certification.hidden = YES;
    }else {
        cell.img_certification.hidden = NO;
    }
    switch ([talenInfo.sMemberLevel integerValue]) {
        case 1://注册会员
        {
            cell.lc_silver.constant = 0;
        }
            break;
        case 2://铜牌会员
        {
            cell.img_grade.image = HDIMAGE(@"v_copper");
        }
            break;
        case 3://银牌会员
        {
            cell.img_grade.image = HDIMAGE(@"v_silver");
        }
            break;
        case 4://金牌会员
        {
            cell.img_grade.image = HDIMAGE(@"v_gold");
        }
            break;
        case 5://钻石会员
        {
            cell.img_grade.image = HDIMAGE(@"v_diamond");
        }
            break;
        case 6://皇冠会员(保留级别 暂未开发)
        {
            
        }
            break;
            
        default:
            break;
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


#pragma mark - Event and Respond
- (void)getDescription{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"荐币用于人才服务的交易,1元=10荐币。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)httpRequest{
    _indexpage = 1;
    [self http:1 block:^(BOOL isLastPage, NSArray *resumes) {
        _isLastPage     = isLastPage;
        _dataArray      = [NSMutableArray arrayWithArray:resumes];
        [self.tbv reloadData];
        [self completeRefresh];
    }];
}

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
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    _op = [[HDHttpUtility sharedClient]searchResume:[HDGlobalInfo instance].userInfo dic:_resumeDic pageIndex:FORMAT(@"%d",_indexpage) size:FORMAT(@"%d",24) completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _isLastPage = isLastPage;
        self.tbv.hidden     = !talents.count;
        self.v_null.hidden  = talents.count;
        self.lb_null.hidden = talents.count;
        block(isLastPage, talents);
    }];
}


@end
