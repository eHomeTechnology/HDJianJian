//
//  HDJFriendCircleCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogViewCtr.h"
#import "HDHttpUtility.h"
#import "TOWebViewController.h"
#import "EGORefreshTableFooterView.h"
#import "EGORefreshTableHeaderView.h"
#import "HDBlogCell.h"
#import "HDBlogTextView.h"
#import "HDLoginViewCtr.h"
#import "HDBlogPositionView.h"
#import "HDNewBlogCtr.h"
#import "WJSearchCtr.h"
#import "WJOrderListCtr.h"
#import "WJBrokerDetailsCtr.h"
#import "HDChatViewCtr.h"
#import "WJSetBrokerMessageCtr.h"
#import "WJCheckPositionCtr.h"
#import "WJTalentDetailCtr.h"
#import "HDChatViewCtr.h"
#import "WJBrokerDetailsCtr.h"

@implementation HDUrlButton

@end

@interface HDBlogViewCtr ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EGORefreshTableDelegate, HDBlogCellDelegate>{
    IBOutlet UIView     *v_section;
    IBOutlet UIView     *v_logingHintBar;
    IBOutlet UIButton   *btn_login;
    IBOutlet UIView     *v_registerSuccess;
    UIPageControl       *pc;
    UIScrollView        *scv;
    HDHUD               *hud;
    BOOL                isFirstRegister;
    BOOL                isThidRegister;//是否为第三方注册
    AFHTTPRequestOperation  *op;
    NSNotificationCenter    *nc_positionOrTalent;
}
@property (strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong) EGORefreshTableFooterView *refreshFooterView;
@property (strong) IBOutlet HDTableView *tbv;
@property (strong) NSMutableArray *mar_blogs;
@property (strong) NSMutableArray *mar_broker;
@property (assign) int iCurrentPage;
@property (assign) BOOL isReloading;

@end

@implementation HDBlogViewCtr

#pragma mark -
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setNavigationItemRightButton];
    [self httpRefreshView];
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.tabBarController.tabBar.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.tabBarController.tabBar.hidden = YES;
    }
    if (op) {
        [op cancel];
        op = nil;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    BOOL hasLogined = [HDGlobalInfo instance].hasLogined;
    v_logingHintBar.hidden = hasLogined;
    if (!nc_positionOrTalent) {
        nc_positionOrTalent = [NSNotificationCenter defaultCenter];
        [nc_positionOrTalent addObserver:self selector:@selector(doSelectPositionOrResum:) name:HD_NOTIFICATION_KEY_BLOG_CELL_POSITION_ACTION object:nil];
        [nc_positionOrTalent addObserver:self selector:@selector(addRegisterSuccessView:) name:HD_NOTIFICATION_KEY_REGISTER_SUCCESS object:nil];
        [nc_positionOrTalent addObserver:self selector:@selector(addRegisterSuccessView:) name:HD_NOTIFICATION_KEY_THIRD_REGISTER_SUCCESS object:nil];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
}

- (void)viewDidLayoutSubviews{
    [self setHeaderRefreshView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HD_NOTIFICATION_KEY_REGISTER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
    if (nc_positionOrTalent) {
        [nc_positionOrTalent removeObserver:self name:HD_NOTIFICATION_KEY_BLOG_CELL_POSITION_ACTION object:nil];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (op) {
        [op cancel];
        op = nil;
    }
    if (hud) {
        [hud hiden];
        hud = nil;
    }
    [self finishReloadingData];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= _mar_broker.count) {
        return;
    }
    WJBrokerInfo *broker = _mar_broker[indexPath.row];
    [self.navigationController pushViewController:[[WJBrokerDetailsCtr alloc] initWithInfo:broker] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.;
}

#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _mar_broker.count) {
        return 65;
    }
    HDBlogInfo *info    = _mar_blogs[indexPath.row - _mar_broker.count];
    CGFloat height      = [self cellHeightWithInfo:_mar_blogs[indexPath.row - _mar_broker.count]];
    CGFloat h_top       = info.isTop? 21: 0;
    return height + h_top + 130;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _mar_blogs.count + _mar_broker.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _mar_broker.count) {
        static NSString *cellIdentifier = @"HDBrokerCell";
        HDBrokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [HDBrokerCell getBrokerCell];
        }
        cell.brokerInfo     = _mar_broker[indexPath.row];
        cell.btn_payAttention.indexPath = indexPath;
        cell.btn_avatar.indexPath       = indexPath;
        cell.btn_payAttention.hidden    = cell.brokerInfo.isFocus;
        [cell.btn_payAttention addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_avatar addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    static NSString *cellIdentifier = @"HDBlogCell";
    HDBlogCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [HDBlogCell getBlogCell];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.lb_top.text];
        [str addAttribute:NSForegroundColorAttributeName value:HDCOLOR_RED range:NSMakeRange(0, 1)];
        cell.lb_top.attributedText = str;
        cell.btn_payAttention.layer.cornerRadius    = 5.;
        cell.btn_payAttention.layer.masksToBounds   = YES;
        cell.btn_payAttention.layer.borderWidth     = 1.0;
        cell.btn_payAttention.layer.borderColor     = [UIColor grayColor].CGColor;
        cell.selectionStyle                         = UITableViewCellSelectionStyleNone;
    }
    cell.indexPath                  = indexPath;
    cell.btn_chat.indexPath         = indexPath;
    cell.btn_collect.indexPath      = indexPath;
    cell.btn_payAttention.indexPath = indexPath;
    cell.btn_avatar.indexPath       = indexPath;
    cell.btn_chatTex.indexPath      = indexPath;
    [cell.btn_payAttention addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_collect addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_chat addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_chatTex addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_avatar addTarget:self action:@selector(doCellButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate   = self;
    cell.blogInfo   = self.mar_blogs[indexPath.row - self.mar_broker.count];
    return cell;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self.navigationController pushViewController:[WJSearchCtr new] animated:YES];
    return NO;
}

#pragma mark HDBlogCellDelegate
- (void)blogCell:(HDBlogCell *)blogCell{
    HDBlogInfo *info = _mar_blogs[blogCell.indexPath.row - _mar_broker.count];
    info.isExtended = !info.isExtended;
    [self.tbv reloadData];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:scv]) {
        return;
    }
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:scv]) {
        pc.currentPage = scrollView.contentOffset.x/CGRectGetWidth(scv.frame);
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:scv]) {
        pc.currentPage = scrollView.contentOffset.x/CGRectGetWidth(scv.frame);
        return;
    }
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    return _isReloading;
}

- (NSDate *)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
    return [NSDate date];
}

#pragma mark -
#pragma mark event response
- (void)doSelectPositionOrResum:(NSNotification *)noti{
    Dlog(@"noti.object = %@, noti.userInfo = %@", noti.object, noti.userInfo);
    NSDictionary *dic = noti.userInfo;
    if ([dic[@"key"] isEqualToString:@"position"]) {
        WJPositionInfo *position = noti.object;
        WJCheckPositionCtr *ctr = [[WJCheckPositionCtr alloc] initWithPositionId:position.sPositionNo];
        [self.navigationController pushViewController:ctr animated:YES];
    }
    if ([dic[@"key"] isEqualToString:@"resume"]) {
        HDTalentInfo *talent = noti.object;
        WJTalentDetailCtr *ctr = [[WJTalentDetailCtr alloc] initWithTalentId:talent.sHumanNo isMeCheckResume:NO];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

- (void)doShowAdvertise:(HDUrlButton *)btn{
    TOWebViewController *webCtr = [[TOWebViewController alloc] initWithURLString:btn.sUrl];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webCtr animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (IBAction)doSettingMyInfomation:(id)sender{
    [v_registerSuccess removeFromSuperview];
    WJSetBrokerMessageCtr *set = [[WJSetBrokerMessageCtr alloc] init];
    [self.navigationController pushViewController:set animated:YES];
}

- (IBAction)doSettingLater:(id)sender{
    [v_registerSuccess removeFromSuperview];
}

- (IBAction)goLoginController:(id)sender{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[HDLoginViewCtr new]];
    [self.navigationController.tabBarController presentViewController:nav animated:YES completion:nil];
}

- (void)doTapAction:(UITapGestureRecognizer *)tap{//拿赏金
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"keyword",
                         @"", @"functionCode",
                         @"", @"businessCode",
                         @"", @"area",
                         @"", @"userno",
                         @"1", @"rewardMin",
                         @"", @"rewardMax",
                         @"", @"istop",
                         @"1", @"isreward",nil];
    WJOrderListCtr *order = [[WJOrderListCtr alloc] initWithPositionDic:dic isOrderList:NO];
    [self.navigationController pushViewController:order animated:YES];
}

- (void)doNewBlog:(UIBarButtonItem *)sender{
    if (![HDGlobalInfo instance].hasLogined) {
        [self goLoginController:nil];
        return;
    }
    [self.navigationController pushViewController:[HDNewBlogCtr new] animated:YES];
}
- (void)doCellButtonAction:(HDIndexButton *)sender{
    if (![HDGlobalInfo instance].hasLogined) {
        [self goLoginController:nil];
        return;
    }
    if (sender.tag == 3) {//头像
        WJBrokerDetailsCtr *ctr = nil;
        if (sender.indexPath.row < _mar_broker.count) {
            WJBrokerInfo *broker = _mar_broker[sender.indexPath.row];
            ctr = [[WJBrokerDetailsCtr alloc] initWithInfo:broker];
        }else{
            HDBlogInfo *info = _mar_blogs[sender.indexPath.row - _mar_broker.count];
            ctr = [[WJBrokerDetailsCtr alloc] initWithInfoID:info.sAuthorId];
        }
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    if (sender.tag == 0) {//关注
        NSString *sUserId = nil;
        if (sender.indexPath.row < _mar_broker.count) {
            WJBrokerInfo *brokerInfo = _mar_broker[sender.indexPath.row];
            sUserId = brokerInfo.sHumanNo;
        }else{
            HDBlogInfo *blog = _mar_blogs[sender.indexPath.row - _mar_broker.count];
            sUserId = blog.sAuthorId;
        }
        [[HDHttpUtility sharedClient] attentionUser:[HDGlobalInfo instance].userInfo usernos:sUserId isfocus:@"1" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            sender.selected = YES;
            [self refreshHeaderView];
        }];
        return;
    }
    HDBlogInfo *blog = _mar_blogs[sender.indexPath.row - _mar_broker.count];
    switch (sender.tag) {
        case 1:{//收藏
            if (blog.isCollect) {
                return;
            }
            [[HDHttpUtility sharedClient] collectBlog:[HDGlobalInfo instance].userInfo blog:blog.sBlogId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                blog.isCollect      = YES;
                blog.sCollectCount  = FORMAT(@"%d", blog.sCollectCount.intValue + 1);
                [self.tbv reloadData];
            }];
            break;
        }
        case 2:{//聊天
            HDBlogInfo *blog = _mar_blogs[sender.indexPath.row - _mar_broker.count];
            HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithChatterId:blog.sAuthorId];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark priate methods
- (CGFloat)cellHeightWithInfo:(HDBlogInfo *)blog{
    if (!blog) {
        Dlog(@"Error:传参错误");
        return 200;
    }
    switch (blog.blogType) {
        case HDBlogTypeText:{
            return [HDBlogTextView heightOfTextView:blog];
        }
        case HDBlogTypePosition:{
            return [HDBlogPositionView heightOfBlogPositionView:blog];
        }
        case HDBlogTypeResume:{
            return 55;
        }
        default:
            break;
    }
    return 300;
}

- (void)http:(int)pageIndex size:(int)size block:(void (^)(BOOL isSuc, BOOL isLast, NSArray *lists))block{
    hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [self httpGetTopBrokers:^(BOOL isSuccess) {
        [self httpGetAdvertisement:^(BOOL isSuc) {
            [self httpGetBlogList:[HDGlobalInfo instance].hasLogined pageIndex:pageIndex size:size withBlock:^(BOOL isSuc, BOOL isLast, NSArray *lists) {
                [hud hiden];
                [self finishReloadingData];
                [self.tbv reloadData];
                block(isSuc, isLast, lists);
            }];
        }];
    }];
}
 
- (void)httpGetBlogList:(BOOL)hasLogined pageIndex:(int)index size:(int)size withBlock:(void (^)(BOOL isSuc, BOOL isLast, NSArray *lists))block{
    op = [[HDHttpUtility sharedClient] getBlogList:[HDGlobalInfo instance].userInfo pageIndex:index size:size completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *lists) {
        op = nil;
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(NO, NO, nil);
            return ;
        }
        block(YES, isLastPage, lists);
    }];
}

- (void)httpGetTopBrokers:(void(^)(BOOL isSuccess))block{
    op = [[HDHttpUtility sharedClient] getBrokerList:[HDGlobalInfo instance].userInfo dic:@{@"istop": @"1"} pageIndex:@"1" size:@"2" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *brokers) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(NO);
            return;
        }
        _mar_broker = brokers;
        [_tbv reloadData];
        op = nil;
        block(YES);
    }];
}

- (void)httpGetAdvertisement:(void (^)(BOOL isSuc))block{
    op = [[HDHttpUtility sharedClient] getAdvertisementBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar) {
        op = nil;
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(NO);
            return ;
        }
        NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:ar];
        if (mar.count > 5) {
            [mar removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, mar.count - 5)]];
        }
        for (UIView *v in scv.subviews){
            if ([v isKindOfClass:[UIButton class]]) {
                [v removeFromSuperview];
            }
        }
        for (int i = 0; i < mar.count; i++) {
            HDAdvertiseInfo *advertiseInfo = mar[i];
            HDUrlButton *btn = [[HDUrlButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(scv.frame) * i, 0, CGRectGetWidth(scv.frame), CGRectGetHeight(scv.frame))];
            [btn setBackgroundImage:HDIMAGE(@"ad_loading") forState:UIControlStateNormal];
            [HDJJUtility getImage:advertiseInfo.sImageUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
                if (code.integerValue == 0) {
                    [btn setBackgroundImage:img forState:UIControlStateNormal];
                }else{
                    [btn setBackgroundImage:HDIMAGE(@"ad_loading") forState:UIControlStateNormal];
                }
            }];
            btn.sUrl = advertiseInfo.sUrl;
            [btn addTarget:self action:@selector(doShowAdvertise:) forControlEvents:UIControlEventTouchUpInside];
            scv.pagingEnabled = YES;
            [scv addSubview:btn];
        }
        if (!pc) {
            pc   = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(scv.frame) - 20, CGRectGetWidth(scv.frame), 20)];
            pc.numberOfPages    = mar.count;
            pc.currentPage      = 0;
            pc.currentPageIndicatorTintColor = HDCOLOR_RED;
            pc.pageIndicatorTintColor = [UIColor whiteColor];
            pc.hidesForSinglePage   = YES;
            [scv.superview addSubview:pc];
        }

        scv.contentSize = CGSizeMake(CGRectGetWidth(scv.frame) * mar.count, CGRectGetHeight(scv.frame));
        block(YES);
    }];
}

#pragma mark -
#pragma mark - getters and setters

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_JJ_FRIEND_CIRCLE");
    self.mar_blogs = [[NSMutableArray alloc] init];
    self.tbv.tableHeaderView = [self newTableHeadView];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    v.backgroundColor           = [UIColor clearColor];
    self.tbv.tableFooterView    = v;
    btn_login.layer.borderWidth = 0.3;
    btn_login.layer.borderColor = [UIColor whiteColor].CGColor;
    _iCurrentPage               = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRefreshView) name:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
}

- (void)setNavigationItemRightButton{
    UIButton *btn_camera = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_camera.frame = CGRectMake(0, 0, 25, 25);
    [btn_camera setBackgroundImage:HDIMAGE(@"icon_takePhoto") forState:UIControlStateNormal];
    [btn_camera addTarget:self action:@selector(doNewBlog:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_camera];
}

- (UIView *)newTableHeadView{
    UIView *vHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.width/2.4 + 80)];
    vHead.backgroundColor = [UIColor colorWithRed:230./250 green:230/250. blue:230/250. alpha:1.0];
    
    scv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(vHead.frame), CGRectGetHeight(vHead.frame) - 86)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(scv.frame), CGRectGetHeight(scv.frame))];
    [btn setBackgroundImage:HDIMAGE(@"ad_default") forState:UIControlStateNormal];
    [scv addSubview:btn];
    scv.delegate = self;
    [vHead addSubview:scv];
    
    //搜索View
    UIView *v_search = [[UIView alloc] initWithFrame:CGRectMake(8, CGRectGetHeight(vHead.frame) - 80, (HDDeviceSize.width - 26) * 0.7, 44)];
    v_search.layer.cornerRadius     = 5;
    v_search.layer.masksToBounds    = YES;
    v_search.backgroundColor        = [UIColor whiteColor];
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 20, 20)];
    [imv setImage:HDIMAGE(@"icon_search")];
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(36, 2, CGRectGetWidth(v_search.frame) - 40, 40)];
    tf.text         = @"找荐客、人才、职位";
    tf.textColor    = [UIColor grayColor];
    tf.delegate     = self;
    [v_search addSubview:imv];
    [v_search addSubview:tf];
    
    UIView *v_getReward = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(v_search.frame) + 18, CGRectGetMinY(v_search.frame), (HDDeviceSize.width-26) * 0.3, 44)];
    v_getReward.layer.cornerRadius  = 5;
    v_getReward.layer.masksToBounds = YES;
    v_getReward.backgroundColor     = [UIColor whiteColor];
    UIImageView *imv_reward         = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(v_getReward.frame)-70)/2, 12, 20, 20)];
    imv_reward.image    = HDIMAGE(@"btn_getReward");
    UILabel *lb         = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(imv_reward.frame)+5+CGRectGetMinX(imv_reward.frame), 12, 45, 20)];
    lb.font             = [UIFont systemFontOfSize:15];
    lb.text             = @"拿赏金";
    lb.textColor        = [UIColor grayColor];
    lb.backgroundColor  = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapAction:)];
    [v_getReward addGestureRecognizer:tap];
    [v_getReward addSubview:lb];
    [v_getReward addSubview:imv_reward];
    
    [vHead addSubview:v_section];
    v_section.translatesAutoresizingMaskIntoConstraints = NO;
    [vHead addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v_section]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(v_section)]];
    [vHead addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v_section(30)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(v_section)]];
    
    [vHead addSubview:v_search];
    [vHead addSubview:v_getReward];
    return vHead;
}

- (void)addRegisterSuccessView:(NSNotification *)noti{
    NSNumber *nu = noti.object;
   // NSDictionary *d = noti.userInfo;
    isFirstRegister = nu.boolValue;
    [self.view addSubview:v_registerSuccess];
    v_registerSuccess.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v_registerSuccess]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(v_registerSuccess)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v_registerSuccess]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(v_registerSuccess)]];
}

#pragma mark refresh模块
-(void)setHeaderRefreshView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self.tbv addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(void)setFooterRefreshView:(BOOL)isLast{
    if (_refreshFooterView && [_refreshFooterView superview]) {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
    if (isLast) {
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
        [self httpRefreshView];
    }else if(aRefreshPos == EGORefreshFooter){
        [self httpGetNextPageView];
    }
}

- (void)httpRefreshView{
    BOOL hasLogin = [HDGlobalInfo instance].hasLogined;
    v_logingHintBar.hidden = hasLogin;
    [self http:1 size:24 block:^(BOOL isSuc, BOOL isLast, NSArray *lists) {
        self.mar_blogs = [[NSMutableArray alloc] initWithArray:lists];
        [self.tbv reloadData];
        _iCurrentPage = 2;
        [self setFooterRefreshView:isLast];
    }];
}

-(void)httpGetNextPageView{
    [self http:_iCurrentPage size:24 block:^(BOOL isSuc, BOOL isLast, NSArray *lists) {
        [self.mar_blogs addObjectsFromArray:lists];
        [self.tbv reloadData];
        _iCurrentPage = _iCurrentPage + 1;
        [self setFooterRefreshView:isLast];
    }];
}

- (void)finishReloadingData{
    _isReloading = NO;
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv];
    }
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv];
    }
}

@end
