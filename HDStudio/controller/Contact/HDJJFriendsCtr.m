//
//  HDJJFriendsCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDJJFriendsCtr.h"
#import "HDJFriendInfo.h"
#import "SDRefresh.h"
#import "HDJFriendDetailCtr.h"

@implementation HDJJFriendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@interface HDJJFriendsCtr (){
    
    SDRefreshHeaderView *refreshHeader;
    SDRefreshFooterView *refreshFooter;
}
@property (assign) int iPageIndex;
@property (strong) AFHTTPRequestOperation *op_jj;
@property (assign) BOOL isLastPage;
@property (strong) IBOutlet UITableView *tbv;
@property (strong) NSMutableArray *mar_jFriends;

@end

@implementation HDJJFriendsCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_CONTACT_J_FRIEND");
    _isLastPage = NO;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    [self.tbv setTableHeaderView:v];
}
- (void)httpGetJJFriendList:(NSString *)sIndex size:(NSString *)sSize{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op_jj = [[HDHttpUtility sharedClient] getMyJFriends:[HDGlobalInfo instance].userInfo index:sIndex size:sSize completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar_friends, BOOL isLast) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _isLastPage = isLast;
        _mar_jFriends = [[NSMutableArray alloc] initWithArray:ar_friends];
        [_tbv reloadData];
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
    __weak HDJJFriendsCtr  *weakSelf                = self;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.iPageIndex   = 1;
            [weakSelf httpGetJJFriendList:@"1" size:@"24"];
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
    __weak HDJJFriendsCtr *weakSelf = self;
    refreshFooter.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            weakSelf.iPageIndex   = weakSelf.iPageIndex + 1;
            [weakSelf httpGetJJFriendList:FORMAT(@"%d", weakSelf.iPageIndex) size:@"24"];
            [footer endRefreshing];
        });
    };
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op_jj) {
        [_op_jj cancel];
        _op_jj = nil;
    }
}

- (void)cellAction:(UIButton *)sender{
    HDJFriendInfo *info = _mar_jFriends[sender.tag];
    UIAlertView *alert = [HDUtility say2:FORMAT(@"%@%@%@", LS(@"TXT_ARE_U_SURE_DIALING"),info.sRMPhone, @"?") Delegate:self];
    alert.tag = sender.tag;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    Dlog(@"buttonIndex = %d, %d", (int)buttonIndex, (int)alertView.tag);
    if (buttonIndex != 1) {
        return;
    }
    HDJFriendInfo *info = _mar_jFriends[alertView.tag];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORMAT(@"tel://%@", info.sRMPhone)]];
}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HDJFriendInfo *info = _mar_jFriends[indexPath.section];
    HDJFriendDetailCtr *ctr = [[HDJFriendDetailCtr alloc] initWithJFriendInfo:info];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mar_jFriends.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HDJJFriendCell";
    HDJJFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self getCell];
    }
    HDJFriendInfo *info     = _mar_jFriends[indexPath.section];
    cell.lb_name.text       = info.sRName;
    cell.lb_company.text    = info.sRCompany;
    cell.lb_time.text       = info.sCreatedDt;
    cell.lb_phone.text      = info.sRMPhone;
    cell.lb_position.text   = info.sRPosition;
    cell.btn_dialing.tag    = indexPath.section;
    [cell.btn_dialing addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (HDJJFriendCell *)getCell{
    HDJJFriendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDJJFriendCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJJFriendCell class]]) {
            cell = (HDJJFriendCell *)obj;
            break;
        }
    }
    return cell;
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
@end
