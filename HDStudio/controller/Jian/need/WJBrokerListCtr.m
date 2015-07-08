//
//  WJBrokerList.m
//  JianJian
//
//  Created by liudu on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerListCtr.h"
#import "WJBrokerCell.h"
#import "WJBrokerInfo.h"
#import "UIImageView+AFNetworking.h"
#import "WJBrokerDetailsCtr.h"
#import "HDChatViewCtr.h"

@interface WJBrokerListCtr ()
@property (nonatomic,assign)NSString * sortStr;
@property(nonatomic,assign)int indexPage;
@property (strong, nonatomic) IBOutlet UITableView *tbv_brokerList;
@property (strong, nonatomic) IBOutlet UILabel *lb_null;
@property (strong, nonatomic) IBOutlet UIImageView *v_null;
@property (strong, nonatomic) WJBrokerInfo *brokerInfo;
@end

@implementation WJBrokerListCtr

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    switch ([[self.typeDic objectForKey:@"roleType"] integerValue]) {
        case 0:
             self.navigationItem.title = LS(@"TXT_JJ_BROKERLIST");
            break;
        case 1:
            self.navigationItem.title = LS(@"WJ_TITLE_BOSS");
            break;
        case 2:
            self.navigationItem.title = LS(@"WJ_TITLE_ENTERPRISE_MANAGER");
            break;
        case 3:
            self.navigationItem.title = LS(@"WJ_TITLE_ENTERPRISE_HR");
            break;
        case 4:
            self.navigationItem.title = LS(@"WJ_TITLE_HEADHUNTER");
            break;
        default:
            break;
    }
    self.tbv_brokerList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.indexPage = 1;
    [self createHeaderView];
    if ([[self.typeDic objectForKey:@"istop"] integerValue] == 1) {
        [self http:1 block:^(BOOL isLastPage, NSArray *positons) {
            self.brokerDataAry = [NSMutableArray arrayWithArray:positons];
            [self.tbv_brokerList reloadData];
            [self completeRefresh];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    //[self setHidesBottomBarWhenPushed:NO];
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self.tbv_brokerList reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WJBrokerInfo *info = [_brokerDataAry objectAtIndex:indexPath.row];
    WJBrokerDetailsCtr *details = [[WJBrokerDetailsCtr alloc] initWithInfo:info];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - 
#pragma mark - UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.brokerDataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"WJBrokerCell";
    WJBrokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [WJBrokerCell getBrokerCell];
    }
    _brokerInfo = [self.brokerDataAry objectAtIndex:indexPath.row];
    cell.lb_name.text = _brokerInfo.sName;
    cell.lc_nameWithWidth.constant = [self viewWidth:_brokerInfo.sName uifont:17];
    cell.lb_place.text = _brokerInfo.sAreaText;
    if (_brokerInfo.sAreaText.length == 0) {
        cell.img_location.hidden = YES;
    }else{
        cell.img_location.hidden = NO;
    }
    cell.lb_industry.text = FORMAT(@"%@ | %@",_brokerInfo.sCurPosition,_brokerInfo.sCurCompany);
    if (_brokerInfo.sCurPosition.length ==0 && _brokerInfo.sCurCompany.length == 0) {
        cell.lb_industry.text = @"";
    }
    cell.lb_position.text = _brokerInfo.sPostText;
    [HDJJUtility getImage:_brokerInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        cell.imv_head.image = img;
    }];
    if ([_brokerInfo.sRoleType isEqualToString:@"0"]) {
        cell.img_certification.hidden = YES;
    }else{
        cell.img_certification.hidden = NO;
    }
    if (_brokerInfo.isFocus) {
        cell.img_add.image  = HDIMAGE(@"icon_chatRed");
        cell.lb_add.text    = @"聊天";
        cell.btn_addAttention.tag = indexPath.row;
        [cell.btn_addAttention addTarget:self action:@selector(addAttention:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        cell.img_add.image  = HDIMAGE(@"icon_addAttention");
        cell.lb_add.text    = @"加关注";
        cell.btn_addAttention.tag = indexPath.row;
        [cell.btn_addAttention addTarget:self action:@selector(addAttention:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;

}


- (void)addAttention:(UIButton *)btn{
   _brokerInfo = [self.brokerDataAry objectAtIndex:btn.tag];
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    if (_brokerInfo.isFocus) {
        HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithHuman:_brokerInfo];
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] attentionUser:[HDGlobalInfo instance].userInfo usernos:_brokerInfo.sHumanNo isfocus:@"1"   completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        if ([sMessage isEqualToString:@"关注成功"]) {
            _brokerInfo.isFocus = YES;
            [self.tbv_brokerList reloadData];
        }else{
            _brokerInfo.isFocus = NO;
            [self.tbv_brokerList reloadData];
        }
    }];
}

#pragma mark - EGODelegate
-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self.tbv_brokerList addSubview:_refreshHeaderView];
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
    CGFloat height = MAX(self.tbv_brokerList.contentSize.height, self.tbv_brokerList.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.tbv_brokerList.frame.size.width,
                                              self.view.bounds.size.height);
    }else{
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height, self.tbv_brokerList.frame.size.width, self.view.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.tbv_brokerList addSubview:_refreshFooterView];
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
    [self http:1 block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        
        self.brokerDataAry = [NSMutableArray arrayWithArray:positons];
        [self.tbv_brokerList reloadData];
        [self completeRefresh];
        
    }];
    
}

//加载调用的方法
-(void)getNextPageView{
    
    [self http:++self.indexPage block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        
        [self.brokerDataAry addObjectsFromArray:positons];
        [self.tbv_brokerList reloadData];
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
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv_brokerList];
    }
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv_brokerList];
        [self setFooterView];
    }
}

- (void)http:(int)page block:(void(^)(BOOL isLastPage, NSArray *positons))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    _op = [[HDHttpUtility sharedClient] getBrokerList:[HDGlobalInfo instance].userInfo dic:self.typeDic pageIndex:FORMAT(@"%d", page)  size:FORMAT(@"%d", 24)  completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.tbv_brokerList.hidden  = !talents.count;
        self.v_null.hidden          = talents.count;
        self.lb_null.hidden         = talents.count;
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
    CGFloat width = size.width+1;
    return width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
