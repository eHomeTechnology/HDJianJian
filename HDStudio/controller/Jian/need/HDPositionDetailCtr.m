//
//  HDPositionDetailCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPositionDetailCtr.h"
#import "HDTableView.h"
#import "WJCheckEmployer.h"
#import "WJSettingRewardCtr.h"
#import "HDNewPositionCtr.h"

@implementation HDPositionDetailCell0

+ (HDPositionDetailCell0 *)getCell0{
    HDPositionDetailCell0 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPositionDetailCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionDetailCell0 class]]) {
            cell = (HDPositionDetailCell0 *)obj;
            break;
        }
    }
    cell.selectionStyle    = UITableViewCellSelectionStyleNone;
    return cell;
}
@end

@implementation HDPositionDetailCell1

+ (HDPositionDetailCell1 *)getCell1{
    HDPositionDetailCell1 *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPositionDetailCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionDetailCell1 class]]) {
            cell = (HDPositionDetailCell1 *)obj;
            break;
        }
    }
    return cell;
}

@end

@interface HDPositionDetailCtr (){

    CGFloat height_tv;
}

@property (strong) NSString         *sPositionId;
@property (strong) WJPositionInfo   *posionInfo;
@property (assign) BOOL             isOnShelve;

@property (strong) IBOutlet HDTableView         *tbv;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;
@property (strong) IBOutlet UIButton            *btn_shelve;
@property (strong) IBOutlet UIButton            *btn_editPosition;
@end

@implementation HDPositionDetailCtr

- (id)initWithPosition:(NSString *)positionId isOnShelve:(BOOL)isOn{
    if (positionId.length == 0) {
        Dlog(@"传入参数不能为空");
        return nil;
    }
    if (self = [super init]) {
        _isOnShelve     = isOn;
        _sPositionId    = positionId;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self httpGetPositionInfo:^(WJPositionInfo *info) {
        _posionInfo = info;
        height_tv   = [info.sRemark boundingRectWithSize:CGSizeMake(HDDeviceSize.width - 50, 9000)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:14]}
                                                 context:nil].size.height + 30;
        [_tbv reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return height_tv + 60;
    }
    return 160;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
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
    if (indexPath.section == 1) {
        HDPositionDetailCell1 *cell1;
        if (!cell1) {
            cell1 = [HDPositionDetailCell1 getCell1];
        }
        cell1.selectionStyle    = UITableViewCellSelectionStyleNone;
        cell1.tv_content.text   = _posionInfo.sRemark;
        return cell1;
    }
    
    HDPositionDetailCell0 *cell0 ;
    if (!cell0) {
        cell0 = [HDPositionDetailCell0 getCell0];
    }
    cell0.lb_title.text     = _posionInfo.sPositionName;
    cell0.lb_salary.text    = _posionInfo.sSalaryText;

    cell0.lb_company.text   = _posionInfo.employerInfo.sName;
    if (_posionInfo.employerInfo.sName.length != 0) {
        cell0.btn_company.tag   = 3;
    }
    cell0.lb_workYear.text  = _posionInfo.sWorkExpText;
    cell0.lb_education.text = _posionInfo.sEducationText;
    cell0.lb_address.text   = _posionInfo.sAreaText;
    cell0.lb_deposit0.text  = LS(@"TXT_JJ_REWORD_SETTING");
    cell0.lb_deposit1.text  = LS(@"TXT_JJ_REWORD_MONEY");
    if (_posionInfo.isBonus) {
        cell0.lb_deposit0.text  = LS(@"TXT_JJ_REWORD");
        cell0.lb_deposit1.text  = FORMAT(@"%0.2f", [_posionInfo.sReward floatValue]/100);
    }else{
        cell0.btn_setSalary.tag = 4;
    }
    cell0.btn_company.tag   = 3;
    cell0.btn_setSalary.tag = 4;
    [cell0.btn_company      addTarget:self action:@selector(doNibButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell0.btn_setSalary    addTarget:self action:@selector(doNibButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell0;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            WJSettingRewardCtr *setting = [[WJSettingRewardCtr alloc] initWithInfo:_posionInfo];
            [self.navigationController pushViewController:setting animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Event and Respond
- (void)httpGetPositionInfo:(void(^)(WJPositionInfo *info))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo pid:_sPositionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(nil);
            return ;
        }
        block(info);
    }];
}

- (IBAction)doNibButtonAction:(UIButton *)sender{
    switch (sender.tag) {
        case -1:{//上架
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
            [[HDHttpUtility sharedClient] changeShelve:[HDGlobalInfo instance].userInfo isUnshelve:NO positionId:_posionInfo.sPositionNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                [HDUtility mbSay:sMessage];
                if (!isSuccess) {
                    return ;
                }
                [sender setBackgroundImage:HDIMAGE(@"icon_unshelveRed") forState:UIControlStateNormal];
                sender.tag = 0;
            }];
            break;
        }
        case 0:{//下架
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
            [[HDHttpUtility sharedClient] changeShelve:[HDGlobalInfo instance].userInfo isUnshelve:YES positionId:_posionInfo.sPositionNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                [HDUtility mbSay:sMessage];
                if (!isSuccess) {
                    return ;
                }
                [sender setBackgroundImage:HDIMAGE(@"icon_reshelveRed") forState:UIControlStateNormal];
                sender.tag = -1;
            }];
            break;
        }
        case 1:{//分享
            NSString *sUrl = nil;
            if (_posionInfo.employerInfo.mar_urls.count > 0) {
                sUrl = _posionInfo.employerInfo.mar_urls[0];
            }
            [HDJJUtility getImage:sUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
                [HDJJUtility umshareUrl:_posionInfo.sUrl title:_posionInfo.sPositionName image:img target:self];
            }];
            break;
        }
        case 2:{//编辑
            [self.navigationController pushViewController:[[HDNewPositionCtr alloc] initWithPosition:_posionInfo] animated:YES];
            break;
        }
        case 3:{//雇主
            if (_posionInfo.employerInfo.sName.length == 0) {
                return;
            }
            WJCheckEmployer *ctr = [[WJCheckEmployer alloc] initWithInfo:_posionInfo];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 4:{//设置悬赏
            if (_posionInfo.isBonus) {
                
            }else{
//                [HDJJUtility jjSay:@"您还没有对该职位设置悬赏金,设置后可以提高信誉度和招聘效率" delegate:self];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有对该职位设置悬赏金,设置后可以提高信誉度和招聘效率" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alert show];
            }
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - getter and setter
- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_POSITION_DETAIL");
    height_tv = 30;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    v.backgroundColor = [UIColor clearColor];
    _tbv.tableHeaderView = v;
    UIImage *img = _isOnShelve? HDIMAGE(@"icon_unshelveRed"): HDIMAGE(@"icon_reshelveRed");
    [_btn_shelve setBackgroundImage:img forState:UIControlStateNormal];
}

@end
