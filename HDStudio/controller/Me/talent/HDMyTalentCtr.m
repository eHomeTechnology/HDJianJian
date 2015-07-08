//
//  HDMyTalentCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyTalentCtr.h"
#import "HDTalentCell.h"
#import "SDRefresh.h"
#import "HDRcmdShowViewCtr.h"
#import "WJMyTalentCell.h"
#import "WJCheckPersonalDetailCtr.h"
#import "WJAddPersonalCtr.h"
#import "WJEvaluateResumeCtr.h"

@interface HDMyTalentCtr (){
    SDRefreshFooterView         *refreshFooter;
    SDRefreshHeaderView         *refreshHeader;
    IBOutlet NSLayoutConstraint *lc_lineLeading;
}

@property (assign) HDWhoseTalent            whoseTalent;
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) IBOutlet UIButton        *btn_me;
@property (strong) IBOutlet UIButton        *btn_friend;
@property (strong) NSMutableArray           *mar_myTalent;
@property (strong) NSMutableArray           *mar_friendTalent;
@property (assign) int                      iPageIndex_me;
@property (assign) int                      iPageIndex_friend;
@property (assign) BOOL                     isLastPage_me;
@property (assign) BOOL                     isLastPage_friend;
@property (strong) AFHTTPRequestOperation   *op_talent;
@property (strong) AFHTTPRequestOperation   *op_recommend;
@property (strong) NSString                 *str_phone;
@property (strong) IBOutlet UIView          *v_segment;
@property (strong) IBOutlet NSLayoutConstraint *lc_segmenHeadHeight;

@property (strong) NSString *sPersonalNo;       //人才编号
@end

@implementation HDMyTalentCtr

#pragma mark - life cycle
- (id)initWithPosition:(WJPositionInfo *)position{
    if (self = [super init]) {
        _positionInfo = position;
    }
    return self;
}

- (id)initWithType:(HDWhoseTalent)type{
    self = [super init];
    if (self){
        _whoseTalent = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_TITLE_MY_TALENT");
    if (self.positionInfo) {
        [self setSegmentViewHide];
    }
    [self setupHeader];
    [self setTableViewHead];
    [self setNavigationBarRightButton];
    if (_whoseTalent > 0) {
        [self performSelector:@selector(doChoose:) withObject:@[_btn_me, _btn_friend][_whoseTalent - 1] afterDelay:0.5];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op_recommend) {
        [_op_recommend cancel];
        _op_recommend = nil;
    }
    if (_op_talent) {
        [_op_talent cancel];
        _op_talent = nil;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [self.tbv reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    if (refreshFooter) {
        [refreshFooter removeFromSuperview];
        refreshFooter = nil;
    }
    if (refreshHeader) {
        [refreshHeader removeFromSuperview];
        refreshHeader = nil;
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.positionInfo) {
        [self doCellButtonAction:nil];
        return;
    }
    HDRecommendInfo *info = nil;
    if (_whoseTalent == HDWhoseTalentFriend) {
        info = _mar_friendTalent[indexPath.row];
    }else{
        info = _mar_myTalent[indexPath.row];
    }
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(myTalentDidSelectTalent:isMeAddTalent:)]) {
        [_myDelegate myTalentDidSelectTalent:info isMeAddTalent:NO];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_whoseTalent == HDWhoseTalentFriend) {
        HDRcmdShowViewCtr *ctr = [[HDRcmdShowViewCtr alloc] initWithRecommendInfo:info isMyRecommend:NO];
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    WJCheckPersonalDetailCtr *details = [[WJCheckPersonalDetailCtr alloc] initWithPersonalno:info.sHumanNo isOpen:info.isOpen];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.whoseTalent == HDWhoseTalentMe) {
        return _mar_myTalent.count;
    }
    return _mar_friendTalent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"talent";
    WJMyTalentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJMyTalentCell getMyTalentCell];
    }
    if (_whoseTalent == HDWhoseTalentFriend) {
      HDRecommendInfo *info = (HDRecommendInfo *)_mar_friendTalent[indexPath.row];
        cell.lb_progressState.text              = @"进展状态";
        cell.lb_progressState.textColor         = [UIColor blackColor];
        [cell.btn_progressState setTitle:info.sProgressText forState:UIControlStateNormal];
        cell.btn_progressState.backgroundColor  = [UIColor colorWithRed:0.31f green:0.79f blue:0.61f alpha:1.00f];
        cell.lb_name.text                       = info.sName;
        NSString *str = info.sEduLevel.length > 0? info.sEduLevel: @"";
        str = [str stringByAppendingString:info.sSexText.length > 0? FORMAT(@" | %@", info.sSexText): @""];
        str = [str stringByAppendingString:info.sWorkYears.length > 0? FORMAT(@" | %@", info.sWorkYears): @""];
        if ([str hasPrefix:@" | "]) {
            str = [str substringFromIndex:3];
        }
        cell.lb_message.text                    = str;
        cell.lb_curPosition.text                = info.sCurPosition;
    }else{
        HDTalentInfo *talent = (HDTalentInfo *)_mar_myTalent[indexPath.row];
        cell.lb_name.text          = talent.sName;
        NSArray *ar = @[talent.sEduLevel? talent.sEduLevel: @"", talent.sSexText? talent.sSexText: @"", talent.sWorkYears? talent.sWorkYears: @""];
        NSString *str = talent.sAreaText.length > 0? talent.sAreaText: @"";
        for (int i = 0; i < ar.count; i++) {
            NSString *s = ar[i];
            str = [str stringByAppendingString:s.length > 0? FORMAT(@" | %@", s): @""];
        }
        if ([str hasPrefix:@" | "]) {
            str = [str substringFromIndex:3];
        }
        cell.lb_message.text       = str;
        cell.lb_curPosition.text   = talent.sCurPosition;
        cell.btn_progressState.tag = indexPath.row;
        [cell.btn_progressState addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.positionInfo) {
            [cell.btn_progressState setTitle:@"推荐" forState:UIControlStateNormal];
            cell.btn_progressState.backgroundColor = [UIColor colorWithRed:0.31f green:0.79f blue:0.61f alpha:1.00f];
            cell.lb_progressState.hidden    = YES;
            return cell;
        }
        if (talent.isOpen) {
            [cell.btn_progressState setTitle:@"发布中" forState:UIControlStateNormal];
            cell.btn_progressState.backgroundColor = [UIColor colorWithRed:0.31f green:0.79f blue:0.61f alpha:1.00f];
            cell.lb_progressState.text      = FORMAT(@"%@荐币", talent.sServiceFee);
            cell.lb_progressState.textColor = [UIColor redColor];
            cell.lc_progressState.constant  = 27;
            cell.lb_progressState.hidden    = NO;
        }else{
            [cell.btn_progressState setTitle:@"发布人选" forState:UIControlStateNormal];
            cell.btn_progressState.backgroundColor = [UIColor redColor];
            cell.lc_progressState.constant  = 18;
            cell.lb_progressState.hidden    = YES;
        }
    }
    return cell;
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] closeResume:[HDGlobalInfo instance].userInfo personalno:self.sPersonalNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [self setupHeader];
    }];
}

#pragma mark - Event and Respond
- (void)doCellButtonAction:(UIButton *)button{
    HDTalentInfo *info = _mar_myTalent[button.tag];
    if (self.positionInfo) {
        [self httpRecommendTalent:info];
        return;
    }
    self.sPersonalNo = info.sHumanNo;
    if (info.isOpen) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确认关闭简历搜索？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.tag = 1;
        [alert show];
        return;
    }
    Dlog(@"发布人选");
    WJCheckPersonalDetailCtr *details = [[WJCheckPersonalDetailCtr alloc] initWithPersonalno:info.sHumanNo isOpen:info.isOpen];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)httpMyTalent:(NSString *)index size:(NSString *)size{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op_talent = [[HDHttpUtility sharedClient] getMyTalent:[HDGlobalInfo instance].userInfo pageIndex:index size:size completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _isLastPage_me   = isLastPage;
        if ([index intValue] == 1) {
            _mar_myTalent = [[NSMutableArray alloc] initWithArray:talents];
        }
        if (index.intValue > 1) {
            [_mar_myTalent addObjectsFromArray:talents];
        }
        [self.tbv reloadData];
        [self setupFooter];
    }];
}

- (void)httpRecommend:(NSString *)index size:(NSString *)size{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op_recommend = [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:nil pageIndex:index pageSize:size CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _isLastPage_friend = isLastPage;
        if ([index intValue] == 1) {
            self.mar_friendTalent = [[NSMutableArray alloc] initWithArray:ar_rcmd];
        }
        if (index.intValue > 1) {
            [self.mar_friendTalent addObjectsFromArray:ar_rcmd];
        }
        [HDGlobalInfo instance].mar_recommend = _mar_friendTalent;
        [self.tbv reloadData];
        [self setupFooter];
    }];
}

- (void)httpRecommendTalent:(HDTalentInfo *)info{
    [[HDHttpUtility sharedClient] recommendMyTalent:[HDGlobalInfo instance].userInfo position:self.positionInfo.sPositionNo talent:info.sHumanNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDRecommendInfo *info) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        WJEvaluateResumeCtr *ctr = [[WJEvaluateResumeCtr alloc] initWithRecommendTalent:info.sHumanNo recommenNo:info.sRecommendId];
        [self.navigationController pushViewController:ctr animated:YES];
    }];
}

- (void)doAddTalent:(id)sender{
    WJAddPersonalCtr *personal = [[WJAddPersonalCtr alloc] initWithTalentInfo:nil type:WJPersonalTypeAdd];
    [self.navigationController pushViewController:personal animated:YES];
}
- (IBAction)doChoose:(UIButton *)sender{
    if ([sender isEqual:_btn_me]) {
        self.whoseTalent = HDWhoseTalentMe;
        [_btn_me setTitleColor:HDCOLOR_RED forState:UIControlStateNormal];
        [_btn_friend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        lc_lineLeading.constant     = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        if (self.mar_myTalent.count == 0) {
            [self setupHeader];
        }
    }else{
        self.whoseTalent = HDWhoseTalentFriend;
        [_btn_friend setTitleColor:HDCOLOR_RED forState:UIControlStateNormal];
        [_btn_me setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        lc_lineLeading.constant     = HDDeviceSize.width/2;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        if (self.mar_friendTalent.count == 0) {
            [self setupHeader];
        }
    }
    [self.tbv reloadData];
}

#pragma mark - setter and getter
- (void)setNavigationBarRightButton{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 25)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setBackgroundImage:HDIMAGE(@"icon_addTalent") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doAddTalent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setSegmentViewHide{
    self.lc_segmenHeadHeight.constant = 0.;
    self.v_segment.hidden = YES;
    [self.view updateConstraints];
}
- (void)setTableViewHead{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tbv setTableHeaderView:v];
}
- (void)setupHeader
{
    if (refreshHeader) {
        [refreshHeader removeFromSuperview];
        refreshHeader = nil;
    }
    refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tbv];
    [refreshHeader beginRefreshing];
    __weak SDRefreshHeaderView *weakRefreshHeader   = refreshHeader;
    __weak HDMyTalentCtr  *weakSelf                = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (weakSelf.whoseTalent) {
                case HDWhoseTalentMe:{
                    weakSelf.iPageIndex_me   = 1;
                    [weakSelf httpMyTalent:@"1" size:@"24"];
                    break;
                }
                case HDWhoseTalentFriend:{
                    weakSelf.iPageIndex_friend  = 1;
                    [weakSelf httpRecommend:@"1" size:@"24"];
                    break;
                }
                default:
                    break;
            }
            [weakRefreshHeader endRefreshing];
        });
    };
}

- (void)setupFooter
{
    if (refreshFooter) {
        [refreshFooter removeFromSuperview];
        refreshFooter = nil;
    }
    switch (_whoseTalent) {
        case HDWhoseTalentMe:{
            if (self.isLastPage_me) {
                return ;
            }else {
                break;
            }
        }
        case HDWhoseTalentFriend:{
            if (self.isLastPage_friend) {
                return ;
            }else{
                break ;
            }
        }
        default:
            return;
    }
    
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tbv];
    __weak SDRefreshFooterView *footer = refreshFooter;
    __weak HDMyTalentCtr *weakSelf = self;
    refreshFooter.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (weakSelf.whoseTalent) {
                case HDWhoseTalentMe:{
                    weakSelf.iPageIndex_me   = weakSelf.iPageIndex_me + 1;
                    [weakSelf httpMyTalent:FORMAT(@"%d", weakSelf.iPageIndex_me) size:@"24"];
                    break;
                }
                case HDWhoseTalentFriend:{
                    weakSelf.iPageIndex_friend  = weakSelf.iPageIndex_friend + 1;
                    [weakSelf httpRecommend:FORMAT(@"%d", weakSelf.iPageIndex_friend) size:@"24"];
                    break;
                }
                default:
                    break;
            }
            [footer endRefreshing];
        });
    };
}


@end
