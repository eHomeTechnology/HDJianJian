//
//  HDContactViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDContactViewCtr.h"
#import "HDTalentListViewCtr.h"
#import "HDJJFriendsCtr.h"
#import "HDNewFriendCtr.h"
#import "HDTradeGroupCtr.h"
#import "HDPhoneContactCtr.h"
#import "MJNIndexView.h"
#import "PinYin4Objc.h"
#import "HDChatViewCtr.h"

@implementation HDContactCell

+ (HDContactCell *)getCell{
    HDContactCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDContactCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDContactCell class]]) {
            cell = (HDContactCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@interface HDContactViewCtr ()<MJNIndexViewDataSource>{
    
    
}
@property (strong) MJNIndexView         *indexView;
@property (strong) NSMutableDictionary  *mdc_value;
@property (strong) IBOutlet UITableView *tbv;
@property (strong) WJPositionInfo       *positionInfo;
@end

@implementation HDContactViewCtr
- (id)initWithSharePosition:(WJPositionInfo *)position{
    if (self = [super init]) {
        self.positionInfo = position;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setLeftBarButton];
    [self setExtraCellLineHidden:self.tbv];
    [self httpGetContactData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews{
    
}
- (void)viewDidAppear:(BOOL)animated{
    
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HDHumanInfo *info = [_mdc_value allValues][indexPath.section][indexPath.row];
    HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithChatterId:info.sHumanNo];
    if (self.positionInfo) {
        [ctr sendPosition:self.positionInfo];
        [HDUtility mbSay:@"分享成功"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark UITableView Datasource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_mdc_value allKeys][section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_mdc_value allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return ((NSArray *)_mdc_value[[_mdc_value allKeys][sectionIndex]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    HDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDContactCell getCell];
    }
    HDHumanInfo *info     = [_mdc_value allValues][indexPath.section][indexPath.row];
    cell.lb_title.text    = info.sName;
    [HDJJUtility getImage:info.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        if ([code intValue] != 0) {
            cell.imv_head.image = HDIMAGE(@"icon_headFalse");
            return ;
        }
        cell.imv_head.image = img;
    }];
    return cell;
}

#pragma mark -
#pragma mark MJNIndexViewDataSource

- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    NSArray *ar = [_mdc_value allKeys];
    return ar;
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    [self.tbv scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0  inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - Event and Respond
- (void)httpGetContactData{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getMyContactList:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *lists) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        for (int i = 0; i < lists.count; i++) {
            HDHumanInfo *info = lists[i];
            NSString *s = [PinyinHelper getFirstCharFromPinyinStringWithString:[info.sName characterAtIndex:0]];
            s = [s uppercaseString];
            Dlog(@"s = %@, info.sName = %@", s, info.sName);
            if (!s) {
                Dlog(@"Error:联系人名字转拼音错误");
                return;
            }
            NSMutableArray *mar = [_mdc_value valueForKey:s];
            if (!mar) {
                mar = [NSMutableArray new];
            }
            [mar addObject:info];
            [_mdc_value setValue:mar forKey:s];
        }
        [self createIndexView];
        [_tbv reloadData];
    }];
}

- (void)doCancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - getter and setter
- (void)setup{
    self.navigationItem.title   = LS(@"TXT_TITLE_CONTACT");
    _mdc_value = [NSMutableDictionary new];
}
-(void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)setLeftBarButton{
    if (self.positionInfo) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    }
}
- (void)createIndexView{
    self.indexView = [[MJNIndexView alloc] initWithFrame:self.tbv.frame];
    self.indexView.dataSource   = self;
    self.indexView.fontColor    = [UIColor blueColor];
    [self.view addSubview:self.indexView];
    [self.view bringSubviewToFront:self.indexView];
}

@end
