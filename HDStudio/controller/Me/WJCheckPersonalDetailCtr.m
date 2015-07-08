//
//  WJCheckPersonalDetailCtr.m
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckPersonalDetailCtr.h"
#import "WJCheckPersonalDetailCell.h"
#import "WJTalentRecommendCell.h"
#import "WJOpenPersonalCtr.h"
#import "WJAddPersonalCtr.h"

@interface WJCheckPersonalDetailCtr ()
{
    HDTalentInfo *resumeInfo;
    float tv_height;
}

@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIButton    *btn_IsOpen;
@property (strong) IBOutlet UIImageView *imv_edit;
@property (strong) NSString *personalno;
@property (assign) BOOL     isOpen;
@end

@implementation WJCheckPersonalDetailCtr

- (id)initWithPersonalno:(NSString *)personalno isOpen:(BOOL)isOpen{
    self = [super init];
    if (self) {
        _personalno = personalno;
        _isOpen     = isOpen;
    }

    return self;
}

#pragma mark -
#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
    [self setNotification];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_CHECK_PERSONAL");
    BOOL isMyTalent = [resumeInfo.sUserNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
    if (!isMyTalent) {
        _imv_edit.image = HDIMAGE(@"icon_collectRed");
        [_btn_IsOpen setTitle:@"购买" forState:UIControlStateNormal];
        return;
    }
    _imv_edit.image = HDIMAGE(@"icon_editRed");
    if (_isOpen) {
        [self.btn_IsOpen setTitle:@"发布中" forState:UIControlStateNormal];
    }else{
        [self.btn_IsOpen setTitle:@"发布人选" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [self removeNotification];
}

#pragma mark -
#pragma mark - HttpRequest

- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getResumeDetails:[HDGlobalInfo instance].userInfo personalno:_personalno completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDTalentInfo *resumeDetail) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _isOpen = resumeDetail.isOpen;
        resumeInfo = resumeDetail;
        [self setup];
        [self.tbv reloadData];
    }];
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isOpen) {
        if (indexPath.section == 0) {
            return 180;
        }else if (indexPath.section == 1){
            return 80;
        }
        return tv_height;

    }else{
        if (indexPath.section == 0) {
            return 180;
        }
        return tv_height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark -- UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    if (_isOpen) {
        if (section == 1) {
            return @"推荐意向";
        }
    }
    return @"简历原文";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isOpen) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJCheckPersonalDetailCell";
        WJCheckPersonalDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJCheckPersonalDetailCell getCheckPositionDetailCell];
        }
        cell.lb_name.text           = resumeInfo.sName;
        cell.lb_workYears.text      = resumeInfo.sWorkYears;
        cell.lb_education.text      = resumeInfo.sEduLevel;
        cell.lb_sex.text            = resumeInfo.sSexText;
        cell.lb_place.text          = resumeInfo.sAreaText;
        cell.lb_curPosition.text    = resumeInfo.sCurPosition;
        cell.lb_curCompany.text     = resumeInfo.sCurCompanyName;
        if (_isOpen) {
            cell.v_service.hidden = NO;
            cell.lb_price.hidden  = NO;
            [cell.btn_service addTarget:self action:@selector(serviceOnClick) forControlEvents:UIControlEventTouchUpInside];
            if (resumeInfo.sServiceFee==nil){
                cell.lb_price.text = @"";
            }else{
                cell.lb_price.text = FORMAT(@"%@荐币",resumeInfo.sServiceFee);
            }

        }else{
            cell.v_service.hidden = YES;
            cell.lb_price.hidden  = YES;
        }
        return cell;
    }
    if (_isOpen) {
         if (indexPath.section == 1){
            static NSString *cellIdentifier = @"WJTalentRecommendCell";
            WJTalentRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [WJTalentRecommendCell getTalentRecommendCell];
            }
            cell.lb_business.textColor  = [UIColor blackColor];
            cell.lb_position.textColor  = [UIColor blackColor];
            cell.lb_workPlace.textColor = [UIColor blackColor];
            cell.lb_businessContent.textColor  = [UIColor blackColor];
            cell.lb_positionContent.textColor  = [UIColor blackColor];
            cell.lb_workPlaceContent.textColor = [UIColor blackColor];
            cell.lb_businessContent.text    = resumeInfo.sBusinessText;
            cell.lb_positionContent.text    = resumeInfo.sFunctionText;
            cell.lb_workPlaceContent.text   = resumeInfo.sWorkPlaceText;
            return cell;
         }
    }
    static NSString *cellIdentifier = @"WJTalentDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, HDDeviceSize.width-20, 40)];
    textView.delegate = self;
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.font = [UIFont systemFontOfSize:14];
    textView.text = [HDJJUtility flattenHTML:resumeInfo.sRemark string:@"\n"];
    tv_height = [HDUtility measureHeightOfUITextView:textView];
    textView.frame =CGRectMake(10, 0, HDDeviceSize.width-20, tv_height);
    [cell.contentView addSubview:textView];
    return cell;
}

#pragma mark -
#pragma mark event response

- (void)setNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequest) name:HD_NOTIFICATION_KEY_OPEN_RESUME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequest) name:HD_NOTIFICATION_KEY_EDIT_PERSONAL object:nil];
}
- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)serviceOnClick{
    [HDJJUtility jjSay:@"荐客只为您推荐该人选的完整简历信息(包括联系方式)、并提供人选评价信息,但不提供其他服务。如需更多定制服务,请与荐客协商。" delegate:self];
}

- (IBAction)share:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_SHARE_POSITION object:nil];
}

- (IBAction)edit:(UIButton *)sender {
    Dlog(@"编辑");
    HDTalentInfo *talentInfo = (HDTalentInfo *)resumeInfo;
    WJAddPersonalCtr *add = [[WJAddPersonalCtr alloc] initWithTalentInfo:talentInfo type:WJPersonalTypeEdit];
    [self.navigationController pushViewController:add animated:YES];
}

//是否发布人选
- (IBAction)isOpen:(UIButton *)sender {
    if (_isOpen){
        Dlog(@"发布中");
        return;
    }
    WJOpenPersonalCtr *open = [[WJOpenPersonalCtr alloc] initWithInfo:resumeInfo];
    [self.navigationController pushViewController:open animated:YES];
}
@end
