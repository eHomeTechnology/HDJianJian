//
//  HDPositionListView.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPositionListView.h"
#import "HDMyPositionCell_v3.h"
#import "WJPositionInfo.h"
#import "EGORefreshTableFooterView.h"
#import "EGORefreshTableHeaderView.h"
#import "HDPositionDetailCtr.h"
#import "TOWebViewController.h"
#import "HDTalentListViewCtr.h"
#import "HDHttpUtility.h"
#import "WJCheckPositionCtr.h"
#import "WJSettingRewardCtr.h"
#import "UIAlertView_WJPositionInfo.h"

@interface HDPositionListView ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EGORefreshTableDelegate,UIAlertViewDelegate>{
    
    UIViewController *owner;
}
@property (assign) BOOL isOnPosition;
@property (assign) BOOL isLastPage;
@property (assign) int  iCurPage;
@property (strong) UITableView *tbv;
@property (strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong) EGORefreshTableFooterView *refreshFooterView;
@property (assign) BOOL isReloading;

@end

@implementation HDPositionListView

- (id)initWithArray:(NSArray *)ar isOnPosition:(BOOL)isOn owner:(id)object{
    if (!ar || !object) {
        Dlog(@"传入参数有误");
        return nil;
    }
    if (self = [super init]) {
        _isOnPosition = isOn;
        _mar_value = [[NSMutableArray alloc] initWithArray:ar];
        owner = object;
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self createHeaderView];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    owner.hidesBottomBarWhenPushed = YES;
    WJPositionInfo *p = _mar_value[indexPath.row];
    if (_plDelegate && [_plDelegate respondsToSelector:@selector(positionListDidSelectPosition:isOnShelve:)]) {
        [_plDelegate positionListDidSelectPosition:p isOnShelve:_isOnPosition];
        [owner.navigationController popViewControllerAnimated:YES];
        return;
    }
    [owner.navigationController pushViewController:[[WJCheckPositionCtr alloc] initWithPositionId:p.sPositionNo] animated:YES];//WithPosition:p.sPositionNo isOnShelve:_isOnPosition] animated:YES];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 114;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _mar_value.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDOnPstList_v3Cell *cell = (HDOnPstList_v3Cell *)[tableView dequeueReusableCellWithIdentifier:@"HDOnPstList_v3Cell"];
    if (!cell) {
        cell = [HDOnPstList_v3Cell getOnCell];
    }
    if (_isOnPosition == NO) {
        [cell.btn_shelve setBackgroundImage:HDIMAGE(@"icon_reshelve") forState:UIControlStateNormal];
        cell.lc_shareWidth.constant     = 0;
        cell.lc_share2shelve.constant   = 0;
    }
    WJPositionInfo *info    = _mar_value[indexPath.row];
    cell.lb_title.text      = info.sPositionName;
    NSString *str           = info.sPublishTime.length > 0? info.sPublishTime:@"";
    NSString *s1            = info.sAreaText.length > 0? FORMAT(@"%@ | %@", str, info.sAreaText): str;
    NSString *s0            = info.sAreaText.length > 0? info.sAreaText: @"";
    str                     = str.length > 0? s1: s0;
    cell.lb_date.text       = str;
    cell.lb_company.text    = info.employerInfo.sName;
    cell.lb_hit.text        = info.sHit;
    cell.lb_upCount.text    = info.sUpCount;
    cell.lb_deposit.text    = FORMAT(@"%@荐币", info.sReward );
    cell.lb_deposit.font    = [UIFont fontWithName:@"Arial" size:17];
    cell.lb_salary.font     = [UIFont fontWithName:@"Arial" size:17];
    cell.lb_salary.text     = info.sSalaryText;
    if (info.sReward.intValue == 0 || !info.isBonus) {
        cell.lb_deposit.text    = @"";
        cell.lc_rewardWidth.constant = 0;
    }
    [cell.btn_bonus setBackgroundImage:(info.isBonus? HDIMAGE(@"btn_shang"): HDIMAGE(@"btn_shangN")) forState:UIControlStateNormal];
    [cell.btn_deposit setBackgroundImage:(info.isDeposit? HDIMAGE(@"btn_bao"): HDIMAGE(@"btn_baoN")) forState:UIControlStateNormal];
    CGSize sz_reward             = [cell.lb_deposit.text boundingRectWithSize:CGSizeMake(300, 20)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:17]}
                                                                     context:nil].size;
    CGSize sz_salary             = [cell.lb_salary.text boundingRectWithSize:CGSizeMake(300, 20)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:17]}
                                                                    context:nil].size;
    
    cell.lc_rewardWidth.constant = sz_reward.width*1.1;
    cell.lc_salaryWidth.constant = sz_salary.width*1.1;
    [cell updateConstraints];
    cell.btn_bonus.buttonStyle          = CELLButtonStyleBonus;
    cell.btn_deposit.buttonStyle        = CELLButtonStyleDeposit;
    cell.btn_preview.buttonStyle        = CELLButtonStylePreview;
    cell.btn_share.buttonStyle          = CELLButtonStyleShare;
    cell.btn_shelve.buttonStyle         = CELLButtonStyleUnshelve;
    cell.btn_ShowRecmmend.buttonStyle   = CELLButtonStyleRecommend;
    cell.btn_bonus.tag          = indexPath.row;
    cell.btn_deposit.tag        = indexPath.row;
    cell.btn_preview.tag        = indexPath.row;
    cell.btn_share.tag          = indexPath.row;
    cell.btn_shelve.tag         = indexPath.row;
    cell.btn_ShowRecmmend.tag   = indexPath.row;
    [cell.btn_bonus         addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_deposit       addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_preview       addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_share         addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_ShowRecmmend  addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_shelve        addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!_isOnPosition) {
        cell.btn_shelve.buttonStyle = CELLButtonStyleReshelve;
    }
    return cell;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    WJPositionInfo *info = alertView.positionInfo;
    switch (buttonIndex) {
        case 0:{
            WJSettingRewardCtr *setting = [[WJSettingRewardCtr alloc] initWithInfo:info];
            [owner.navigationController pushViewController:setting animated:YES];
            Dlog(@"设置悬赏金");
            break;
        }
        default:
            break;
    }
}

#pragma mark -
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

#pragma mark - 
#pragma mark 
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
- (void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    _isReloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        [self refreshView];
    }else if(aRefreshPos == EGORefreshFooter){
        [self getNextPageView];
    }
}

- (void)refreshView{
    [self http:1 isOn:_isOnPosition block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        _mar_value   = [[NSMutableArray alloc] initWithArray:positons];
        if (_isOnPosition) {
            [HDGlobalInfo instance].mar_onPosition  = _mar_value;
        }else{
            [HDGlobalInfo instance].mar_offPosition = _mar_value;
        }
        [_tbv reloadData];
        [self finishReloadingData];
        [self setFooterView];
    }];
}

-(void)getNextPageView{
    [self http:_iCurPage+1 isOn:_isOnPosition block:^(BOOL isLastPage, NSArray *positons) {
        _isLastPage  = isLastPage;
        [_mar_value addObjectsFromArray:positons];
        if (_isOnPosition) {
            [HDGlobalInfo instance].mar_onPosition  = _mar_value;
        }else{
            [HDGlobalInfo instance].mar_offPosition = _mar_value;
        }
        [_tbv reloadData];
        [self finishReloadingData];
    }];
}

-(void)removeFooterView{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
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

- (void)http:(int)page isOn:(BOOL)isOn block:(void(^)(BOOL isLastPage_, NSArray *positons))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self];
    _op = [[HDHttpUtility sharedClient] getPositionList:[HDGlobalInfo instance].userInfo pageIndex:FORMAT(@"%d", page) pageSize:FORMAT(@"%d", 24) isOffShelve:!isOn CompletionBlock:^(BOOL isSuccess, BOOL isLastPage, NSArray *positons, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(NO, nil);
            return;
        }
        _iCurPage   = page;
        block(isLastPage, positons);
    }];
}

- (void)cellAction:(CELLButton *)sender{
    WJPositionInfo *info = _mar_value[sender.tag];
    switch (sender.buttonStyle) {
        case CELLButtonStyleBonus:{
            return;
            Dlog(@"赏");
            if (info.isBonus) {
                [HDUtility mbSay:FORMAT(@"人选上岗%@天后给赏金%0.1f元",[HDJJUtility isNull:info.sDelayDay]?@"0":info.sDelayDay,[info.sReward floatValue]/10)];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.positionInfo  = info;
                alert = [alert initWithTitle:@"提示" message:@"您还没有对该职位设置悬赏金,设置后可以提高信誉度和招聘效率" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                alert.tag = 999;
                [alert show];
            }
            return;
        }
        case CELLButtonStyleDeposit:{
            return;
            Dlog(@"保");
            if (info.isDeposit) {
                 [HDUtility mbSay:@"雇主已全额缴纳保证金"];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.positionInfo = info;
                alert = [alert initWithTitle:@"提示" message:@"您还没有对该职位设置悬赏金,设置后可以提高信誉度和招聘效率" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                alert.tag = 888;
                [alert show];
            }
            return;
        }
        case CELLButtonStylePreview:{
            TOWebViewController *web = [[TOWebViewController alloc] initWithURLString:info.sUrl];
            [owner.navigationController pushViewController:web animated:YES];
            return;
        }
        case CELLButtonStyleShare:{
            if (![HDGlobalInfo instance].hasLogined) {
                [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_SHARE_POSITION object:info];
            
            return;
        }
        case CELLButtonStyleUnshelve:{
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:owner.view];
            [[HDHttpUtility sharedClient] changeShelve:[HDGlobalInfo instance].userInfo isUnshelve:YES positionId:info.sPositionNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                [HDUtility mbSay:sMessage];
                if (!isSuccess) {
                    return ;
                }
                for (WJPositionInfo *pInfo in self.mar_value) {
                    if ([pInfo.sPositionNo isEqualToString:info.sPositionNo]) {
                        [self.mar_value removeObject:pInfo];
                        break;
                    }
                }
                self.isOffPositionNeedRefresh = YES;
                [self.tbv reloadData];
            }];
            return;
        }
        case CELLButtonStyleReshelve:{
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:owner.view];
            [[HDHttpUtility sharedClient] changeShelve:[HDGlobalInfo instance].userInfo isUnshelve:NO positionId:info.sPositionNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                [HDUtility mbSay:sMessage];
                if (!isSuccess) {
                    return ;
                }
                for (WJPositionInfo *pInfo in self.mar_value) {
                    if ([pInfo.sPositionNo isEqualToString:info.sPositionNo]) {
                        [self.mar_value removeObject:pInfo];
                        break;
                    }
                }
                self.isOnPositionNeedRefresh = YES;
                [self.tbv reloadData];
            }];
            return;
        }
        case CELLButtonStyleRecommend:{
            if (info.sUpCount.intValue < 1) {
                return;
            }
            NSMutableArray *mar = [NSMutableArray new];
            for (HDRecommendInfo *rInfo in [HDGlobalInfo instance].mar_recommend) {
                if ([info.sPositionNo isEqualToString:rInfo.sPositionID]) {
                    [mar addObject:rInfo];
                }
            }
            if (mar.count > 0) {
                owner.hidesBottomBarWhenPushed = YES;
                HDTalentListViewCtr *ctr = [[HDTalentListViewCtr alloc] initWithRecommendList:mar];
                [owner.navigationController pushViewController:ctr animated:YES];
                return;
            }
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:owner.view];
            [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:info.sPositionNo pageIndex:@"1" pageSize:@"10" CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                if (ar_rcmd.count > 0) {
                    owner.hidesBottomBarWhenPushed = YES;
                    HDTalentListViewCtr *ctr = [[HDTalentListViewCtr alloc] initWithRecommendList:ar_rcmd];
                    [owner.navigationController pushViewController:ctr animated:YES];
                    return;
                }
                [HDUtility say:LS(@"TXT_CANNOT_GET_THE_DATA")];
            }];
            return;
        }
        default:
            return;
    }
}

#pragma mark - Getter and Setter
- (void)setup{
    _isOnPositionNeedRefresh    = NO;
    _isOffPositionNeedRefresh   = NO;
    _iCurPage               = 1;
    _tbv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tbv.delegate           = self;
    _tbv.dataSource         = self;
    [self addSubview:_tbv];
    UIView *v               = [UIView new];
    v.backgroundColor       = [UIColor grayColor];
    v.alpha                 = 0.1;
    v.frame                 = CGRectMake(0, 0, HDDeviceSize.width, 0.1);
    _tbv.tableHeaderView    = v;
    UIView *v2              = [[UIView alloc] initWithFrame:v.frame];
    v2.backgroundColor      = [UIColor grayColor];
    v2.alpha                = 0.1;
    _tbv.tableFooterView    = v2;
    _tbv.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tbv]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_tbv)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tbv]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_tbv)]];
}

-(void)createHeaderView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self.tbv addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)setFooterView{
    if (_refreshFooterView) {
        [self removeFooterView];
    }
    if (_isLastPage) {
        return;
    }
    CGFloat height = MAX(self.tbv.contentSize.height, self.tbv.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview]) {
        _refreshFooterView.frame = CGRectMake(0.0f,
                                              height,
                                              self.tbv.frame.size.width,
                                              self.bounds.size.height);
    }else{
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:
                              CGRectMake(0.0f, height, self.tbv.frame.size.width, self.bounds.size.height)];
        _refreshFooterView.delegate = self;
        [self.tbv addSubview:_refreshFooterView];
    }
    if (_refreshFooterView) {
        [_refreshFooterView refreshLastUpdatedDate];
    }
}


@end
