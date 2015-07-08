//
//  WJTalentDetailCtr.m
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJTalentDetailCtr.h"
#import "WJTalentDetailCell.h"
#import "WJTalentRecommendCell.h"
#import "WJBuyServiceCtr.h"
#import "WJBrokerDetailsCtr.h"

@interface WJTalentDetailCtr ()
{
    HDTalentInfo *resumeInfo;
    float tv_height;
}

@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIView *v_head1;
@property (strong) IBOutlet UIView *v_head2;
@property (strong) IBOutlet UIView *v_footBackground;
@property (strong) IBOutlet UIButton *btn_collect;
@property (strong) IBOutlet UIButton *btn_buyService;

@property (assign) BOOL isMeCheckResume; //用来判断是“我”--我购买服务--查看详情---查看简历(隐藏底部按钮)

@property (strong) IBOutlet NSLayoutConstraint *lc_tbvToViewWithHeight;//tableview距离self.view底部距离
- (IBAction)collect:(UIButton *)sender;
- (IBAction)buyService:(UIButton *)sender;

@end

@implementation WJTalentDetailCtr


#pragma mark - Life Cycle

- (id)initWithTalentId:(NSString *)sId isMeCheckResume:(BOOL)isMeCheckResume{
    if (self = [super init]) {
        _personalno         = sId;
        _isMeCheckResume    = isMeCheckResume;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self httpRequest];
    if (_isMeCheckResume) {
        self.v_footBackground.hidden = YES;
        self.lc_tbvToViewWithHeight.constant = 0;
    }else{
        self.v_footBackground.hidden = NO;
        self.lc_tbvToViewWithHeight.constant = 49;
    }
    [self.view updateConstraints];
    self.navigationItem.title = LS(@"WJ_TITLE_PERSONAL_DETAILS");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:WJ_NOTIFICATION_KEY_BUY_SERVICE_SUCCESS object:nil];
}

- (void)reloadData{
     [self httpRequest];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WJ_NOTIFICATION_KEY_BUY_SERVICE_SUCCESS object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 190;
    }else if (indexPath.section == 1){
        return 80;
    }
    return tv_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
        return v;
    }else if (section == 1){
        return self.v_head1;
    }
    return self.v_head2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    return v;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJTalentDetailCell";
        WJTalentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJTalentDetailCell getTalentDetailCell];
        }
        cell.lb_workYears.text      = resumeInfo.sWorkYears;
        cell.lb_education.text      = resumeInfo.sEduLevel;
        cell.lb_sex.text            = resumeInfo.sSexText;
        cell.lb_place.text          = resumeInfo.sAreaText;
        cell.lb_curPosition.text    = resumeInfo.sCurPosition;
        cell.lb_curCompany.text     = resumeInfo.sCurCompanyName;
        [cell.btn_service addTarget:self action:@selector(serviceOnClick) forControlEvents:UIControlEventTouchUpInside];
        if (resumeInfo.sServiceFee==nil){
            cell.lb_price.text = @"";
        }else{
            cell.lb_price.text          = FORMAT(@"%@荐币",resumeInfo.sServiceFee);
        }
        


        cell.lb_brokerName.text = resumeInfo.sNickName;
        cell.lc_attentionWidth.constant     = resumeInfo.isFocus? 0: 70;
        cell.v_attention.hidden             = resumeInfo.isFocus;
        cell.lc_brokerNameWidth.constant    = [HDJJUtility withOfString:resumeInfo.sNickName font:[UIFont systemFontOfSize:14] widthMax:1000];
        [cell updateConstraints];
        NSArray *ar = @[HDIMAGE(@"v_copper"), HDIMAGE(@"v_silver"), HDIMAGE(@"v_gold"), HDIMAGE(@"v_diamond")];
        int iLevel = resumeInfo.sMemberLevel.intValue;
        UIImage *image = nil;
        if (iLevel >= 2 && iLevel <= 5) {
            image = ar[iLevel - 2];
        }
        if (iLevel == 1) {
            cell.imv_level.hidden = YES;
        }
        cell.imv_level.image = image;
        cell.imv_v.hidden    = !resumeInfo.sRoleType.boolValue;
        
        [cell.btn_checkBroker addTarget:self action:@selector(checkBrokerDetails:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_chat addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_payAtention addTarget:self action:@selector(addAttention:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else if (indexPath.section == 1){
        static NSString *cellIdentifier = @"WJTalentRecommendCell";
        WJTalentRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJTalentRecommendCell getTalentRecommendCell];
        }
        cell.lb_businessContent.text = resumeInfo.sBusinessText;
        cell.lb_positionContent.text = resumeInfo.sFunctionText;
        cell.lb_workPlaceContent.text = resumeInfo.sWorkPlaceText;
        return cell;
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


#pragma mark - Event and Respond
- (IBAction)collect:(UIButton *)sender {
    [HDJJUtility jjSay:@"收藏成功" delegate:self];
}

- (IBAction)buyService:(UIButton *)sender {
    if (![HDGlobalInfo instance].hasLogined){
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    if (resumeInfo.isBuy) {
        [HDJJUtility jjSay:@"您已购买过此服务" delegate:self];
    }else{
        WJBuyServiceCtr *buy = [[WJBuyServiceCtr alloc] initWithResumeInfo:resumeInfo];
        [self.navigationController pushViewController:buy animated:YES];

    }
}

- (IBAction)chat:(UIButton *)sender {
    HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithChatterId:resumeInfo.sUserNo];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)addAttention:(UIButton *)sender {
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    WJTalentDetailCell *cell = (WJTalentDetailCell *)[self.tbv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (resumeInfo.isFocus){
        cell.v_attention.hidden = YES;
        cell.lc_attentionWidth.constant = 0;
        [cell setNeedsUpdateConstraints];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] attentionUser:[HDGlobalInfo instance].userInfo usernos:resumeInfo.sUserNo isfocus:@"1" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        cell.lc_attentionWidth.constant = 0;
        cell.v_attention.hidden = YES;
        [cell setNeedsUpdateConstraints];
    }];
}

- (IBAction)checkBrokerDetails:(UIButton *)sender {
    WJBrokerDetailsCtr *details = [[WJBrokerDetailsCtr alloc] initWithInfoID:resumeInfo.sUserNo];
    [self.navigationController pushViewController:details animated:YES];
}

- (void)serviceOnClick{
    [HDJJUtility jjSay:@"荐客只为您推荐该人选的完整简历信息(包括联系方式)、并提供人选评价信息,但不提供其他服务。如需更多定制服务,请与荐客协商。" delegate:self];
}

#pragma mark - Private method
- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];

    [[HDHttpUtility sharedClient] getResumeDetails:[HDGlobalInfo instance].userInfo personalno:_personalno completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDTalentInfo *resumeDetail) {
    
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        resumeInfo = resumeDetail;
        [self.tbv reloadData];
    }];
}

@end
