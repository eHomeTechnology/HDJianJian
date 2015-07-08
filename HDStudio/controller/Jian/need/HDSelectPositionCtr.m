//
//  HDSelectPositionCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDSelectPositionCtr.h"
#import "HDImportPositionCell.h"
#import "HDHttpUtility.h"
#import "HDIMCompleteCtr.h"

@interface HDSelectPositionCtr (){

    IBOutlet UIView     *v_head;
    IBOutlet UIButton   *btn_selectAll;
}

@property (strong) HDCompanyInfo    *companyInfo;
@property (strong) NSMutableArray   *mar_positions;
@property (strong) IBOutlet UITableView      *tbv;

@end



@implementation HDSelectPositionCtr

- (id)initWithCompanyInfo:(HDCompanyInfo *)info{
    if (!info) {
        Dlog(@"传入参数错误");
        return nil;
    }
    if (self = [super init]) {
        _companyInfo    = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_TITLE_SELECT_POSITION");
    v_head.frame = CGRectMake(0, 0, _tbv.frame.size.width, 90);
    _tbv.tableHeaderView = v_head;
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.navigationController.view];
    NSString *sUrl = [HDGlobalInfo instance].addressInfo.sCloudsite_webroot;
    [[HDHttpUtility instanceWithUrl:sUrl] queryForPositionList:_companyInfo.sId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        if (ar.count == 0) {
            [HDUtility mbSay:@"未搜索到任何职位"];
        }
        _mar_positions = [[NSMutableArray alloc] initWithArray:ar];
        [_tbv reloadData];
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.tabBarController.tabBar.hidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)doRelease:(id)sender{
    NSMutableArray *mar_selected = [[NSMutableArray alloc] init];
    for (int i = 0; i < _mar_positions.count; i++) {
        HDIMPositionInfo *info = _mar_positions[i];
        if (info.isSelected) {
            [mar_selected addObject:info];
        }
    }
    if (mar_selected.count == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_SELECT_POSITION")];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.navigationController.view];
    [[HDHttpUtility sharedClient] releasePositions:[HDGlobalInfo instance].userInfo positions:mar_selected enterpriceId:_companyInfo.sId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        HDIMCompleteCtr *ctr = [[HDIMCompleteCtr alloc] initWithPositions:mar_selected];
        [self.navigationController pushViewController:ctr animated:YES];
    }];
}
- (IBAction)doSelectAll:(id)sender{
    BOOL isSelectAll = NO;
    for (HDIMPositionInfo *info in _mar_positions) {
        if (info.isSelected == NO) {
            isSelectAll = YES;
            break;
        }
    }
    if (isSelectAll) {
        for (HDIMPositionInfo *info in _mar_positions) {
            info.isSelected = YES;
        }
        [_tbv reloadData];
        return;
    }
    for (HDIMPositionInfo *info in _mar_positions) {
        info.isSelected = NO;
    }
    [_tbv reloadData];
}

- (void)doSelected:(UIButton *)sender{
    
    HDIMPositionInfo *info = _mar_positions[sender.tag];
    info.isSelected = !info.isSelected;
    [_tbv reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDIMPositionInfo *info = _mar_positions[indexPath.section];
    info.isSelected = !info.isSelected;
    [_tbv reloadData];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mar_positions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"inportPositionCell";
    HDImportPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDImportPositionCell getImportPositionCell];
    }
    HDIMPositionInfo *info      = _mar_positions[indexPath.section];
    cell.lb_positionName.text   = info.sName;
    cell.lb_times.text          = info.sPublishTime;
    cell.lb_ageLimit.text       = info.sWorkTime.length > 0? info.sWorkTime: @"不限";
    cell.lb_education.text      = info.sEducation.length > 0? info.sEducation: @"不限";
    cell.lb_locus.text          = info.sAreaText;
    cell.btn_select.tag         = indexPath.section;
     UIImage *img = info.isSelected? HDIMAGE(@"icon_complete"): HDIMAGE(@"icon_completeNot");
    [cell.btn_select setBackgroundImage:img forState:UIControlStateNormal];
    [cell.btn_select addTarget:self action:@selector(doSelected:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end
