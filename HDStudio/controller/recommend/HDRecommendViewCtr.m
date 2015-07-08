//
//  HDScheduleViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDRecommendViewCtr.h"
#import "HDRecommendCell.h"
#import "HDRcmdShowViewCtr.h"
#import "SDRefresh.h"
#import "AFImageRequestOperation.h"

@interface HDRecommendViewCtr (){

    
}
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) NSMutableArray           *mar_recommend;
@property (strong) SDRefreshFooterView      *refreshFooter;
@property (assign) int                      iRecommendIndex;
@end

@implementation HDRecommendViewCtr

- (id)initWithRecommendInfo:(NSArray *)ar{

    if (self = [super init]) {
        self.mar_recommend = [[NSMutableArray alloc] initWithArray:ar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iRecommendIndex = 2;
    if (!self.mar_recommend) {
        _mar_recommend = [HDGlobalInfo instance].mar_recommend;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 15)];
        [btn setImage:[UIImage imageNamed:@"iconList"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(doShowList:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    [self setupHeader];
    [self setupFooter];
}
- (void)doShowList:(id)sender{
    if ([[HDGlobalInfo instance].sideMenu isMenuVisible]) {
        [[HDGlobalInfo instance].sideMenu hideMenuAnimated:YES];
        return;
    }
    [[HDGlobalInfo instance].sideMenu showMenuAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tbv];
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:nil pageIndex:@"1" pageSize:FORMAT(@"%d", (int)self.mar_recommend.count) CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return;
                }
                //[HDGlobalInfo instance].isCommendLastPage   = isLastPage;
                self.iRecommendIndex                        = 2;
                [HDGlobalInfo instance].mar_recommend       = [[NSMutableArray alloc] initWithArray:ar_rcmd];
                self.mar_recommend                          = [HDGlobalInfo instance].mar_recommend;
               // Dlog(@"isCommendLastPage = %d", [HDGlobalInfo instance].isCommendLastPage);
                [self setupFooter];
                [self.tbv reloadData];
            }];
            
            [weakRefreshHeader endRefreshing];
        });
    };
}

- (void)setupFooter
{
    if (self.refreshFooter) {
        [self.refreshFooter removeFromSuperview];
        self.refreshFooter = nil;
    }

//    if ([HDGlobalInfo instance].isCommendLastPage) {
//        return ;
//    }
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tbv];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}

- (void)footerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:nil pageIndex:@"1" pageSize:@"24" CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
//            [HDGlobalInfo instance].isCommendLastPage = isLastPage;
//            Dlog(@"isCommendLastPage = %d", [HDGlobalInfo instance].isCommendLastPage);
            self.iRecommendIndex = self.iRecommendIndex + 1;
            self.mar_recommend = [[NSMutableArray alloc] initWithArray:ar_rcmd];
            [HDGlobalInfo instance].mar_recommend = self.mar_recommend;
            [self setupFooter];
            [self.tbv reloadData];
        }];
        
        [self.tbv reloadData];
        [self.refreshFooter endRefreshing];
    });
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HDRecommendInfo *info = self.mar_recommend[indexPath.row];
    HDRcmdShowViewCtr *ctr = [[HDRcmdShowViewCtr alloc] initWithRecommendInfo:info isMyRecommend:NO];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark -
#pragma mark UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 143;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _mar_recommend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sIdentifier = @"HDRecommendCell";
    HDRecommendCell *recommendCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
    if (!recommendCell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRecommendCell" owner:self options:nil];
        for (NSObject *obj in objects) {
            if ([obj isKindOfClass:[HDRecommendCell class]]) {
                recommendCell = (HDRecommendCell *)obj;
                break;
            }
        }
    }
    HDRecommendInfo *recommend          = self.mar_recommend[indexPath.row];
    recommendCell.lb_Name.text          = recommend.sName;
    recommendCell.lb_curPstiNCmp.text   = FORMAT(@"%@ | %@", recommend.sCurCompanyName, recommend.sCurPosition);
    recommendCell.lb_matchCount.text    = recommend.sMatchCount;
    recommendCell.lb_refereeName.text   = FORMAT(@"%@推荐", recommend.sRefereeName);
    recommendCell.lb_createdTime.text   = recommend.sCreatedTime;
    recommendCell.btn_copyIcon.tag      = indexPath.row;
    recommendCell.btn_copyText.tag      = indexPath.row;
    recommendCell.btn_shareText.tag     = indexPath.row;
    recommendCell.btn_shareIcon.tag     = indexPath.row;
    [recommendCell.btn_copyIcon addTarget:self action:@selector(doCopyRecommend:) forControlEvents:UIControlEventTouchUpInside];
    [recommendCell.btn_copyText addTarget:self action:@selector(doCopyRecommend:) forControlEvents:UIControlEventTouchUpInside];
    [recommendCell.btn_shareIcon addTarget:self action:@selector(doShareRecommend:) forControlEvents:UIControlEventTouchUpInside];
    [recommendCell.btn_shareText addTarget:self action:@selector(doShareRecommend:) forControlEvents:UIControlEventTouchUpInside];
    return recommendCell;
}

#pragma mark -

- (void)doCopyRecommend:(UIButton *)sender{
    HDRecommendInfo *info = self.mar_recommend[sender.tag];
    NSString *sUrl  = nil;
    for (WJPositionInfo *pInfo in [HDGlobalInfo instance].mar_positions){
        if ([pInfo.sPositionNo isEqualToString:info.sPositionID]) {
            sUrl    = pInfo.sUrl;
            break;
        }
    }
    UIPasteboard *past = [UIPasteboard generalPasteboard];
    [past setString:sUrl];
    [HDUtility mbSay:@"超链接已复制到粘贴板"];
}
- (void)doShareRecommend:(UIButton *)sender{
    HDRecommendInfo *info       = self.mar_recommend[sender.tag];
    WJPositionInfo  *position   = nil;
    for (WJPositionInfo *pInfo in [HDGlobalInfo instance].mar_positions){
        if ([pInfo.sPositionNo isEqualToString:info.sPositionID]) {
            position    = pInfo;
            break;
        }
    }
    if (!position) {
        [HDUtility mbSay:@"Error:数据出错,请联系管理员"];
        return;
    }
    //[HDMainViewCtr shareWithPosition:position target:self];
}

@end
