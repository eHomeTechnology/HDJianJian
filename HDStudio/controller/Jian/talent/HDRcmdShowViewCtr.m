//
//  HDCandidateShowCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/10.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDRcmdShowViewCtr.h"
#import "HDHttpUtility.h"
#import "HDShowJFriendCtr.h"
#import "HDTalentViewCtr.h"
#import "WJCheckPositionCtr.h"
#import "WJRewardMessageInfo.h"
#import "HDChatViewCtr.h"
#import "WJTalentDetailCtr.h"

typedef NS_ENUM(NSInteger, HDFeedBackType) {
    
    HDFeedBackTypeSuitable = 1,         //合适的
    HDFeedBackTypeIndeterminate,        //待定的
    HDFeedBackTypeNotSuitable,          //不合适
    HDFeedBackTypeInterview,            //面试
    HDFeedBackTypeHire,                 //录用
    HDFeedBackTypeWork,                 //上岗
};

@implementation WJCheckCell


@end

@implementation HDCommendCell


@end

@implementation HDShowPartnerCell

@end

@implementation HDProgressCell

- (void)awakeFromNib{

    self.v_dot.layer.cornerRadius   = 5.;
    self.v_dot.layer.masksToBounds  = YES;
}

@end


@interface HDRcmdShowViewCtr (){

    BOOL isShowPartner;
    BOOL isShowCommend;
    NSMutableArray          *mar_feedback;
    HDHUD                   *hud;
    IBOutlet UIView         *v_head;
    IBOutlet UIView         *v_sectionHead;
    IBOutlet UILabel        *lb_rcmdName;
    IBOutlet UILabel        *lb_workYears;
    IBOutlet UIButton       *btn_mobile;
    IBOutlet UILabel        *lb_curCompany;
    IBOutlet UILabel        *lb_curPosition;
    IBOutlet UIButton       *btn_suitable;
}
@property (strong) IBOutlet UITableView         *tbv;
@property (strong) HDRecommendInfo              *recommendInfo;
@property (strong) WJPositionInfo               *positionInfo;
@property (strong) NSMutableArray               *mar_progress;
@property (strong) AFHTTPRequestOperation       *op;

@property (strong) IBOutlet UIView   *v_foot;
@property (strong) IBOutlet UIButton *btn_payReward;
@property (strong) IBOutlet UIButton *btn_update;
@property (strong) IBOutlet UILabel  *lb_payReward;
@property (strong)  NSMutableArray   *rewardAry;
@property (assign) BOOL isMyRecommend;// 判断是否为我推荐的人选进来的

- (IBAction)payReward:(UIButton *)sender;

@end

@implementation HDRcmdShowViewCtr

- (id)initWithRecommendInfo:(HDRecommendInfo *)info isMyRecommend:(BOOL)isMyRecommend{
    if (!info) {
        Dlog(@"传入参数错误！");
        return nil;
    }
    if (self = [super init]) {
        self.recommendInfo   = info;
        _isMyRecommend       = isMyRecommend;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableHead];
    if (_isMyRecommend == YES) {
        self.v_foot.hidden  = YES;
    }else{
        self.v_foot.hidden = NO;
    }
    [self setUserInterface];
    [self httpGetProgressList];
    [self httpGetPositionInfo:_recommendInfo.sPositionID block:^(WJPositionInfo *info) {
        if (info) {
            _positionInfo = info;
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated{

    if (_op) {
        [_op cancel];
        _op = nil;
    }
}
- (void)httpGetProgressList{
    if (!hud) {
        hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    }
    _op = [[HDHttpUtility sharedClient] getRecommendProgress:[HDGlobalInfo instance].userInfo recommendId:_recommendInfo.sRecommendId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *progressList) {
        if (hud) {
            [hud hiden];
        }
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        if (progressList.count == 0) {
            return;
        }
        _mar_progress = [[NSMutableArray alloc] initWithArray:progressList];
        [btn_suitable setTitle:((HDProgressInfo *)_mar_progress[0]).sContent forState:UIControlStateNormal];
        if ([((HDProgressInfo *)_mar_progress[0]).sContent isEqualToString:@"已支付悬赏"]) {
            self.btn_payReward.userInteractionEnabled = NO;
            self.lb_payReward.text                    = @"已支付赏金";
            self.btn_update.userInteractionEnabled    = NO;
            btn_suitable.userInteractionEnabled       = NO;
            return;
        }
        self.btn_payReward.userInteractionEnabled = YES;
        self.btn_update.userInteractionEnabled    = YES;
        btn_suitable.userInteractionEnabled       = YES;
        self.lb_payReward.text                    = @"支付赏金";
        [self.tbv reloadData];
    }];
    
}

- (void)httpGetPositionInfo:(NSString *)positionId block:(void(^)(WJPositionInfo *info))block{
    if (!hud) {
        hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    }
    _op = [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo pid:positionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info) {
        if (hud) {
            [hud hiden];
        }
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        block(info);
    }];
}

- (void)setTableHead{
    v_head.frame                = CGRectMake(0, 0, HDDeviceSize.width, 141);
    _tbv.tableHeaderView        = v_head;
}
- (void)setUserInterface{
    isShowCommend               = NO;
    isShowPartner               = NO;
    self.navigationItem.title   = LS(@"TXT_TITLE_SHOW_RECOMMEND");
    lb_rcmdName.text            = _recommendInfo.sName;
    lb_workYears.text           = _recommendInfo.sWorkYears;
    [btn_mobile setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    if (_recommendInfo.sPhone.length == 0) {
        [btn_mobile setTitle:@"保密,请联系荐客〉" forState:UIControlStateNormal];
    }else{
        [btn_mobile setTitle:@"申请查阅〉" forState:UIControlStateNormal];
    }
   // lb_mobile.text              = _recommendInfo.sPhone;
    lb_curCompany.text          = _recommendInfo.sCurCompanyName;
    lb_curPosition.text         = _recommendInfo.sCurPosition;
    btn_suitable.layer.cornerRadius     = 17;
    btn_suitable.layer.masksToBounds    = YES;
    mar_feedback                = [HDGlobalInfo instance].mar_feedback;
}
- (void)viewWillLayoutSubviews{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)doSuitable:(id)sender{

    UIActionSheet *as   = [[UIActionSheet alloc] init];
    as.delegate         = self;
    [as addButtonWithTitle:LS(@"TXT_CANCEL")];
    for (int i = 1; i < mar_feedback.count-1; i++) {
        [as addButtonWithTitle:mar_feedback[i][@"Value"]];
    }
    [as showInView:kWindow];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            WJTalentDetailCtr *talent = [[WJTalentDetailCtr alloc] initWithTalentId:_positionInfo.sPositionNo isMeCheckResume:YES];
            [self.navigationController pushViewController:talent animated:YES];
        }
            break;
        case 1:{
            WJCheckPositionCtr *position = [[WJCheckPositionCtr alloc] initWithPositionId:_positionInfo.sPositionNo];
            [self.navigationController pushViewController:position animated:YES];

            break;
        }
        case 2:{
            HDShowJFriendCtr *ctr = [[HDShowJFriendCtr alloc] initWithInfo:self.recommendInfo];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 3) {
        return 60.;
    }
    return 0.;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 3) {
        v_sectionHead.frame = CGRectMake(0, 0, HDDeviceSize.width, 50);
        return v_sectionHead;
    }
    return nil;
}
#pragma mark -
#pragma mark UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return 76;
    }
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 3) {
        return _mar_progress.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *sIdentifer = @"WJCheckCell";
        WJCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifer];
        if (!cell) {
            cell = [self getCheckCell];
        }
        return cell;
    }
    
    if (indexPath.section == 1) {
        static NSString *sIdentifier = @"HDCommendCell";
        HDCommendCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
        if (!cell) {
            cell = [self getCommendCell];
        }
        cell.lb_position.text   = _recommendInfo.sPositionName;
        return cell;
    }
    if (indexPath.section == 2) {
        static NSString *sIdentifier = @"HDShowPartnerCell";
        HDShowPartnerCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
        if (!cell) {
            cell = [self getShowPartnerCell];
        }
        return cell;
    }
    if (indexPath.section == 3) {
        HDProgressInfo *info = _mar_progress[indexPath.row];
        HDProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDProgressCell"];
        if (!cell) {
            cell = [self getProgressCell];
        }
        cell.v_lineH.hidden     = indexPath.row == _mar_progress.count - 1;
        cell.v_lineV.hidden     = indexPath.row == _mar_progress.count - 1;
        cell.lb_content.text    = info.sContent;
        cell.lb_time.text       = info.sCreatedTime;
        return cell;
    }
    return nil;
}
- (WJCheckCell *)getCheckCell{
    WJCheckCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRcmdShowCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJCheckCell class]]) {
            cell = (WJCheckCell *)obj;
            break;
        }
    }
    return cell;
}

- (HDCommendCell *)getCommendCell{
    HDCommendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRcmdShowCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDCommendCell class]]) {
            cell = (HDCommendCell *)obj;
            break;
        }
    }
    return cell;
}
- (HDShowPartnerCell *)getShowPartnerCell{
    HDShowPartnerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRcmdShowCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDShowPartnerCell class]]) {
            cell = (HDShowPartnerCell *)obj;
            break;
        }
    }
    return cell;
}
- (HDProgressCell *)getProgressCell{
    HDProgressCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRcmdShowCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDProgressCell class]]) {
            cell = (HDProgressCell *)obj;
            break;
        }
    }
    return cell;
}
#pragma mark -
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    Dlog(@"buttonIndex = %d", (int)buttonIndex);
    if (buttonIndex == 0) {
        return;
    }
    [[HDHttpUtility sharedClient] setFeedbackType:[HDGlobalInfo instance].userInfo recommendId:_recommendInfo.sRecommendId feedbackType:(int)buttonIndex completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        [btn_suitable setTitle:mar_feedback[buttonIndex][@"Value"] forState:UIControlStateNormal];
        [self httpGetProgressList];
    }];
}

- (IBAction)edit:(UIButton *)sender {
    [self.navigationController pushViewController:[HDTalentViewCtr new] animated:YES];
}

- (IBAction)payReward:(UIButton *)sender {

    [[HDHttpUtility sharedClient] getRewardMessage:[HDGlobalInfo instance].userInfo recommendId:_recommendInfo.sRecommendId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray) {
        if (!isSuccess) {
            //[HDUtility mbSay:sMessage];
            [HDUtility mbSay:@"推荐的职位未设置悬赏金,请设置后再支付"];
            return ;
        }
        _rewardAry = [NSMutableArray arrayWithArray:dataArray];
        [self getshowAlert];
    }];
}

- (void)getshowAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:FORMAT(@"您设置的悬赏模式是:%@",_positionInfo.tradeInfo.sTradeDesc) delegate:self cancelButtonTitle:@"继续支付" otherButtonTitles:@"取消", nil];
    alert.tag = 9999;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 9999:
        {
            if (buttonIndex == 0) {
                WJRewardMessageInfo *info = [_rewardAry objectAtIndex:0];
                WJPayRewardCtr *reward = [[WJPayRewardCtr alloc] initWithInfo:info];
                reward.delegate        = self;
                reward.recommendId = self.recommendInfo.sRecommendId;
                [self.navigationController pushViewController:reward animated:YES];
            }
        }
            break;
        case 8888:
        {
            if (buttonIndex == 0) {
                [btn_mobile setTitle:_recommendInfo.sPhone forState:UIControlStateNormal];
                [btn_mobile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
            }
        }
            break;
        case 7777:
        {
            if (buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_recommendInfo.sPhone]]];
            }
        }
        default:
            break;
    }
}

- (void)payRewardSuccess:(BOOL)isSuccess{
    if (isSuccess) {
        [self httpGetProgressList];
    }
}

- (IBAction)doCheckPersonalMobile:(UIButton *)sender {
    if ([btn_mobile.titleLabel.text isEqualToString:@"申请查阅〉"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"申请查阅意味着人选上岗您将支付赏金" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.tag = 8888;
        [alert show];
    }else if ([btn_mobile.titleLabel.text isEqualToString:@"保密,请联系荐客〉"]){
        HDChatViewCtr *chat = [[HDChatViewCtr alloc] initWithChatterId:_recommendInfo.sRefereeId];
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话?" message:_recommendInfo.sPhone delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alert.tag = 7777;
        [alert show];
    }
}
@end
