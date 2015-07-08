//
//  HDTalentViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDTalentListViewCtr.h"
#import "HDTalentCell.h"
#import "SDRefresh.h"
#import "HDTalentViewCtr.h"
#import "HDRcmdShowViewCtr.h"

@interface HDTalentListViewCtr (){
    SDRefreshHeaderView *refreshHeader;
    SDRefreshFooterView *refreshFooter;
    
}
@property (strong) AFHTTPRequestOperation   *op_talent;
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) NSMutableArray           *mar_recommends;
@property (strong) NSMutableArray           *mar_talents;
@property (assign) int                      iPageIndex;
@property (assign) BOOL                     isLastPage;
@end

@implementation HDTalentListViewCtr

- (id)initWithRecommendList:(NSArray *)ar_{
    if (self = [super init]) {
        _mar_recommends = [[NSMutableArray alloc] initWithArray:ar_];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    
    if (_mar_recommends) {
        return;
    }
    [self setupHeader];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_TALENT_LIST");
    if (_mar_recommends) {
        self.navigationItem.title = LS(@"TXT_TITLE_RECOMMEND_LIST");
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    [self.tbv setTableHeaderView:v];
}
- (void)httpGetTalentList:(NSString *)index size:(NSString *)size{
    _op_talent = [[HDHttpUtility sharedClient] getAllTalent:[HDGlobalInfo instance].userInfo pageIndex:index size:size completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        if (!isSuccess) {
            [HDUtility say:sMessage];
            return ;
        }
        _mar_talents    = talents;
        _isLastPage     = isLastPage;
        [self.tbv reloadData];
        [self setupFooter];
    }];
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
    __weak HDTalentListViewCtr  *weakSelf                = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.iPageIndex   = 1;
            [weakSelf httpGetTalentList:@"1" size:@"24"];
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
    if (self.isLastPage) {
        return ;
    }
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tbv];
    __weak SDRefreshFooterView *footer = refreshFooter;
    __weak HDTalentListViewCtr *weakSelf = self;
    refreshFooter.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            weakSelf.iPageIndex   = weakSelf.iPageIndex + 1;
            [weakSelf httpGetTalentList:FORMAT(@"%d", weakSelf.iPageIndex) size:@"24"];
            [footer endRefreshing];
        });
    };
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op_talent) {
        [_op_talent cancel];
        _op_talent = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_mar_recommends) {
        HDRecommendInfo *info = _mar_recommends[indexPath.section];
        HDRcmdShowViewCtr *ctr = [[HDRcmdShowViewCtr alloc] initWithRecommendInfo:info isMyRecommend:NO];
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    HDTalentInfo *info = _mar_talents[indexPath.section];
    HDTalentViewCtr *ctr = [[HDTalentViewCtr alloc] initWithInfo:info];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 141;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_mar_recommends) {
        return _mar_recommends.count;
    }
    return _mar_talents.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    HDTalentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self getTalentsCell];
    }
    HDTalentInfo *info = nil;
    if (_mar_recommends) {
        info = _mar_recommends[indexPath.section];
    }else{
        info = _mar_talents[indexPath.section];
    }
    cell.lb_title.text          = info.sName;
    cell.lb_curCompany.text     = info.sCurCompanyName;
    cell.lb_curPosition.text    = info.sCurPosition;
    cell.lb_MPhone.text         = info.sPhone;
    cell.lb_createTime.text     = info.sCreatedTime;
    cell.lb_workYear.text       = info.sWorkYears;
    return cell;
}

- (HDTalentCell *)getTalentsCell{
    HDTalentCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDTalentCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDTalentCell class]]) {
            cell = (HDTalentCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)dealloc{

    if (refreshHeader) {
        [refreshHeader removeFromSuperview];
        refreshHeader = nil;
    }
    if (refreshFooter) {
        [refreshFooter removeFromSuperview];
        refreshFooter = nil;
    }
}

@end
