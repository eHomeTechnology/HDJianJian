//
//  HDNewsViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewsViewCtr.h"
#import "HDHttpUtility.h"
#import "UIImageView+HDDownloadImage.h"
#import "HDChatViewCtr.h"
#import "HDNewPositionCtr.h"
#import "HDAddTalentCtr.h"
#import "HDAddFriendCtr.h"
#import "HDTableView.h"
#import "EaseMob.h"
#import "EGORefreshTableHeaderView.h"
#import "HDContactViewCtr.h"

#define TICKS_NEWS FORMAT(@"%@_NEWS_TICKS", [HDGlobalInfo instance].userInfo.sHumanNo)
@implementation HDNewsCell

+ (HDNewsCell *)getCell{
    HDNewsCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDNewsCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDNewsCell class]]) {
            cell = (HDNewsCell *)obj;
            break;
        }
    }
    cell.v_redDot.layer.cornerRadius    = 5.;
    cell.v_redDot.layer.masksToBounds   = YES;
    return cell;
}

- (void)setSubscriberInfo:(HDSubscriberInfo *)subscriberInfo{
    self.v_redDot.hidden    = ![subscriberInfo.sCount intValue];
    self.lb_title.text      = subscriberInfo.sSubscriberName;
    self.lb_value.text      = subscriberInfo.sContent;
    if (subscriberInfo.formatType == HDNewsFormatTypeResume) {
        self.lb_value.text  = @"[简历]";
    }
    if (subscriberInfo.formatType == HDNewsFormatTypePosition) {
        self.lb_value.text  = @"[职位]";
    }
    if (subscriberInfo.formatType == HDNewsFormatTypeImage) {
        self.lb_value.text  = @"[图片]";
    }
    /*荐荐服务器的时间戳是耶稣公元纪年的时间戳，所以要转换成计算机1970年后*/
    NSDate *date            = [HDJJUtility dateWithTimeIntervalSiceChristionEra:[subscriberInfo.sCreateTime doubleValue]];
    if (subscriberInfo.platformType == HDMessagePlatformTypeEasMobe) {
        date = [[NSDate alloc] initWithTimeIntervalSince1970:subscriberInfo.sCreateTime.doubleValue/1000];
    }
    NSString *sTime         = [HDUtility returnHumanizedTime:date];
    self.lb_time.text       = sTime;
    [HDJJUtility getImage:subscriberInfo.sSubscriberLogo withBlock:^(NSString *code, NSString *message, UIImage *img) {
        [self.imv_head setImage:img];
    }];
}
@end

@interface HDNewsViewCtr ()<EMChatManagerDelegate>{
    HDHUD *hud;
}

@property (strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (strong) NSString         *sTicks;
@property (assign) BOOL             isLastPage;
@property (assign) BOOL isReloading;
@end

@implementation HDNewsViewCtr

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHead];
    [self registerNotification];
}
- (void)viewWillAppear:(BOOL)animated{
    [self refreshData];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.tabBarController.tabBar.hidden = NO;
    }
}
- (void)viewDidLayoutSubviews{
    [self setHeaderRefreshView];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.tabBarController.tabBar.hidden = YES;
    }
}
- (void)dealloc{
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[HDContactViewCtr new] animated:YES];
        return;
    }
    HDSubscriberInfo *info  = _mar_subscribers[indexPath.row];
    info.sCount             = @"";
    HDChatViewCtr *ctr      = [[HDChatViewCtr alloc] initWithJianJianConversation:info];
    [self wipeUnreadEmNews:indexPath.row];
    [self calculateJianNewsCount];
    [self.navigationController pushViewController:ctr animated:YES];
    [self refreshData];
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return sectionIndex == 0? 1: _mar_subscribers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    HDNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDNewsCell getCell];
    }
    cell.lb_time.hidden     = indexPath.section == 0;
    cell.accessoryType      = indexPath.section == 0? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        cell.v_redDot.hidden= YES;
        cell.imv_head.image = HDIMAGE(@"icon_jianyoulu");
        cell.lb_title.text  = @"荐友录";
        cell.lb_value.text  = @"您的好友都在这里哦！";
        return cell;
    }
    HDSubscriberInfo *info  = _mar_subscribers[indexPath.row];
    cell.subscriberInfo     = info;
    return cell;
}

#pragma mark - EMChatManagerChatDelegate
-(void)didUnreadMessagesCountChanged
{
    [self refreshData];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}
#pragma mark EGORefreshTableDelegate
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
- (void)registerNotification{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:HD_NOTIFICATION_KEY_REFRESH_CONVERSATION_LIST object:nil];
}

- (void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshData{
    [self httpGetSubscriberListWithPageIndex:1 pageSize:100];
    [self emGetMessageList];
}
- (NSMutableArray *)loadDataSource
{
    NSMutableArray *mar_result = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray *ar_sorte = [conversations sortedArrayUsingComparator:^(EMConversation *obj1, EMConversation *obj2){
        EMMessage *message1 = [obj1 latestMessage];
        EMMessage *message2 = [obj2 latestMessage];
        if(message1.timestamp > message2.timestamp) {
          return(NSComparisonResult)NSOrderedAscending;
        }else {
          return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    mar_result = [[NSMutableArray alloc] initWithArray:ar_sorte];
    return mar_result;
}
- (void)emGetMessageList{
    NSArray *ar = [self loadDataSource];
    for (int i = 0; i < ar.count; i++) {
        EMConversation *conversation = ar[i];
        [HDSubscriberInfo subscriberInfoFromEmConversation:conversation block:^(HDSubscriberInfo *subInfo) {
            if (!subInfo) {
                Dlog(@"转化数据失败！");
                return ;
            }
            int i = [self hasTheSubInfo:subInfo];
            if (i >= 0) {
                [_mar_subscribers replaceObjectAtIndex:i withObject:subInfo];
            }else{
                [_mar_subscribers insertObject:subInfo atIndex:0];
            }
            NSArray *ar_sorte = [_mar_subscribers sortedArrayUsingComparator:^(HDSubscriberInfo *obj1, HDSubscriberInfo *obj2){
                if(obj1.sCreateTime.integerValue > obj2.sCreateTime.integerValue) {
                    return(NSComparisonResult)NSOrderedAscending;
                }else {
                    return(NSComparisonResult)NSOrderedDescending;
                }
            }];
            _mar_subscribers = [[NSMutableArray alloc] initWithArray:ar_sorte];
            [self.tbv reloadData];
            [self finishReloadingData];
            [self calculateJianNewsCount];
        }];
    }
}

- (BOOL)wipeUnreadEmNews:(NSUInteger)index{
    HDSubscriberInfo *info = _mar_subscribers[index];
    NSArray *ar = [self loadDataSource];
    EMConversation *conversation = nil;
    for (EMConversation *c in ar) {
        if ([c.chatter isEqualToString:info.sSubscriberID]) {
            conversation = c;
            break;
        }
    }
    if (conversation) {
        BOOL isSuc = [conversation markAllMessagesAsRead:YES];
        Dlog(@"isSuc = %d", isSuc);
        return isSuc;
    }else{
        return NO;
    }
}

- (void)httpGetSubscriberListWithPageIndex:(int)index pageSize:(int)size{
    [[HDHttpUtility sharedClient] getSubscribeNews:[HDGlobalInfo instance].userInfo pageIndex:index pageSize:size lastTicks:_sTicks completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage, NSString *tick) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        for (int i = 0; i < list.count; i++) {
            HDSubscriberInfo *sub = list[i];
            int j = [self hasTheSubInfo:sub];
            if (j >= 0) {
                HDSubscriberInfo *info = _mar_subscribers[j];
                sub.sCount = @(info.sCount.intValue + sub.sCount.intValue).stringValue;
                [_mar_subscribers replaceObjectAtIndex:j withObject:sub];
            }else{
                [_mar_subscribers addObject:sub];
            }
        }
        _isLastPage         = isLastPage;
        _sTicks             = tick;
        [[NSUserDefaults standardUserDefaults] setObject:tick forKey:TICKS_NEWS];
        [self finishReloadingData];
        [self calculateJianNewsCount];
        [_tbv reloadData];
    }];
}

- (int)hasTheSubInfo:(HDSubscriberInfo *)sub{
    for (int j = 0; j < _mar_subscribers.count; j++) {
        HDSubscriberInfo *info = _mar_subscribers[j];
        if ([info.sSubscriberID isEqualToString:sub.sSubscriberID]) {
            return j;
        }
    }
    return -1;
}

- (void)calculateJianNewsCount{
    int iCount = 0;
    for (int i = 0; i < _mar_subscribers.count; i++) {
        HDSubscriberInfo *info = _mar_subscribers[i];
        [info insert_update2DB];
        iCount = iCount + [info.sCount intValue];
    }
    self.navigationController.tabBarItem.badgeValue =  FORMAT(@"%d", iCount);
    if (iCount == 0) {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - getter and setter
- (void)setup{
    self.navigationItem.title   = LS(@"TXT_TITLE_NEWS");
    NSString *sTicks            = [[NSUserDefaults standardUserDefaults] objectForKey:TICKS_NEWS];
    _sTicks                     = sTicks.length == 0? @"0": sTicks;
    [self.tbv setTableHeaderView:self.searchDisplayController.searchBar];
}
- (void)setTableHead{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1.)];
    v.backgroundColor = [UIColor clearColor];
    self.tbv.tableHeaderView = v;
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

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    _isReloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
        [self refreshData];
    }
}

- (void)finishReloadingData{
    _isReloading = NO;
    if (_refreshHeaderView) {
        [hud hiden];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbv];
    }
}

@end
