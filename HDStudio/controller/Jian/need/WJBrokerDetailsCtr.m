//
//  WJBrokerDetailsCtr.m
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBrokerDetailsCtr.h"
#import "WJBrokerCell1.h"
#import "WJBrokerCell2.h"
#import "WJPositionCell.h"
#import "WJHightTalentCtr.h"
#import "WJCheckPositionCtr.h"
#import "HDChatViewCtr.h"

@interface WJBrokerDetailsCtr ()

@property (strong, nonatomic) IBOutlet UITableView  *tbv;
@property (strong, nonatomic) IBOutlet UIView       *v_head1;
@property (strong, nonatomic) IBOutlet UIView       *v_head2;
@property (strong, nonatomic) IBOutlet UIView       *v_head3;
@property (strong, nonatomic) IBOutlet UIView       *v_foot1;
@property (strong) IBOutlet UIButton    *btn_arrow;
//展示简介按钮
@property (strong) UIButton  *btn_introduce;
//简介Cell的高度
@property (strong) NSIndexPath          *selectIndexPath;
@property (strong) NSString             *sIntroduce;//简介信息
@property (assign) CGFloat              introduceCellHeight;
@property (strong) NSString             *sId;
@property (strong) WJBrokerInfo         *brokerInfo;
@property (nonatomic) NSArray           *ary_positionData;

@end

@implementation WJBrokerDetailsCtr

- (id)initWithInfo:(WJBrokerInfo *)info{
    if (self = [super init]) {
        _sId = info.sHumanNo;
        Dlog(@"----%@",info);
        _brokerInfo = (WJBrokerInfo *)info;
    }
    return self;
}

- (id)initWithInfoID:(NSString *)infoId{
    if (self = [super init]) {
        _sId = infoId;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self httpGetPositions];
    if ([_brokerInfo isKindOfClass:[HDUserInfo class]]) {
        self.sIntroduce = _brokerInfo.sRemark;
        return;
    }
    [self httpGetBrokerDetails];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"%@",indexPath);
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                                 @"",@"area",
                                 @"",@"functioncode",
                                 @"",@"businesscode",
                                 @"",@"edulevel",
                                 @"",@"startworktime",
                                 _sId,@"userno",
                                 @"",@"feeMin",
                                 @"",@"feeMax",nil];
            //WJHightTalentCtr *talent = [[WJHightTalentCtr alloc] initWithUserno:_sId isTop:NO];
            WJHightTalentCtr *talent = [[WJHightTalentCtr alloc] initWithResumeDic:dic isTop:NO];
            [self.navigationController pushViewController:talent animated:YES];
        }
            break;
        case 3:
        {
            WJPositionInfo *info = [self.ary_positionData objectAtIndex:indexPath.row];
            WJCheckPositionCtr *position = [[WJCheckPositionCtr alloc] initWithPositionId:info.sPositionNo];
            [self.navigationController pushViewController:position animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120;
    }else if (indexPath.section == 1){
        return self.introduceCellHeight;
    }else if (indexPath.section == 2){
        return 65;
    }
    WJPositionInfo *info    = [self.ary_positionData objectAtIndex:indexPath.row];
    NSString *sCompany      = info.employerInfo.sName.length == 0? info.sCompnayName: info.employerInfo.sName;;
    return sCompany.length > 0? 90: 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 50;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
        return v;
    }else if (section == 1){
        [self.v_head1 addSubview:_btn_introduce];
        return self.v_head1;
    }else if (section == 2){
        return self.v_head2;
    }
    return self.v_head3;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.v_foot1;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    return v;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 3) {
        return _ary_positionData.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJBrokerCell1";
        WJBrokerCell1 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
           cell = [WJBrokerCell1 getBrokerCell1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.img_bgAttention.tag = 500;
        cell.img_add.tag = 501;
        cell.lb_addAttention.tag = 502;
        if (_brokerInfo.isFocus){
            cell.img_bgAttention.image = HDIMAGE(@"icon_anniuGray");
            cell.img_add.hidden = YES;
            cell.lb_addAttention.hidden = YES;
            [cell.btn_addAttention setTitle:@"已关注" forState:UIControlStateNormal];
        }else{
            cell.img_bgAttention.image = HDIMAGE(@"icon_anniu1");
            cell.img_add.hidden = NO;
            cell.lb_addAttention.hidden = NO;
            [cell.btn_addAttention setTitle:@"" forState:UIControlStateNormal];
            [cell.btn_addAttention addTarget:self action:@selector(doIBAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.btn_chat addTarget:self action:@selector(doIBAction:) forControlEvents:UIControlEventTouchUpInside];
        [HDJJUtility getImage:_brokerInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            cell.img_head.image = img;
        }];
        if ([_brokerInfo.sRoleType isEqualToString:@"0"]) {
            cell.img_certification.hidden = YES;
        }else{
            cell.img_certification.hidden = NO;
        }
        cell.img_grade.hidden      = NO;
        cell.lb_name.text           = _brokerInfo.sShopName;
        cell.lb_curPosition.text    = _brokerInfo.sCurPosition.length > 0? FORMAT(@"%@ |", _brokerInfo.sCurPosition): @"";
        cell.lc_curPositionWith.constant = [HDJJUtility withOfString:cell.lb_curPosition.text font:[UIFont systemFontOfSize:14] widthMax:200];
        cell.lb_curPosition.hidden = !_brokerInfo.sCurPosition.length;
        cell.lc_curPositionWith.constant = _brokerInfo.sCurPosition.length == 0? 0: cell.lc_curPositionWith.constant;
        cell.lb_place.text      = _brokerInfo.sAreaText;
        cell.lb_curCompany.text = _brokerInfo.sCurCompany;
        cell.lb_business.text   = _brokerInfo.sTradeText;
        cell.lb_function.text   = _brokerInfo.sPostText;
        cell.img_location.hidden = _brokerInfo.sAreaText.length == 0;
        if ([cell.lb_curPosition.text hasSuffix:@"|"] && _brokerInfo.sAreaText.length == 0) {
            cell.lb_curPosition.text = [cell.lb_curPosition.text substringToIndex:cell.lb_curPosition.text.length - 2];
        }
        cell.lc_nameWithWidth.constant = [HDJJUtility withOfString:_brokerInfo.sShopName font:[UIFont systemFontOfSize:17] widthMax:200];
        [cell updateConstraints];
        switch ([_brokerInfo.sMemberLevel integerValue]) {
            case 1://注册会员
            {
                cell.img_grade.hidden = YES;
            }
                break;
            case 2://铜牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_copper");
            }
                break;
            case 3://银牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_silver");
            }
                break;
            case 4://金牌会员
            {
                cell.img_grade.image = HDIMAGE(@"v_gold");
            }
                break;
            case 5://钻石会员
            {
                cell.img_grade.image = HDIMAGE(@"v_diamond");
            }
                break;
            case 6://皇冠会员
            {
                
            }
                break;
                
            default:
                break;
        }
        return cell;
    }else if (indexPath.section == 1){
        static NSString *cellIdentifier = @"HDBrokerIntroCell";
        HDBrokerIntroCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (cell == nil) {
            cell = [HDBrokerIntroCell getCell];
        }
        cell.lb_intro.textColor = [UIColor grayColor];
        cell.lb_intro.font = [UIFont systemFontOfSize:14];
        cell.lb_intro.text = self.sIntroduce;
        cell.lb_intro.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.lb_intro.numberOfLines = 0;
        return cell;
    }else if (indexPath.section == 2){
        static NSString *cellIdentifier = @"WJBrokerCell2";
        WJBrokerCell2 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
           cell = [WJBrokerCell2 getBrokerCell2];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    static NSString *cellIdentifier = @"WJPositionCell";
    WJPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJPositionCell getPositionCell];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    WJPositionInfo *info = [self.ary_positionData objectAtIndex:indexPath.row];
    cell.lb_position.text = info.sPositionName;
    NSString *str = info.sAreaText.length == 0? @"": info.sAreaText;
    str = [str stringByAppendingString:(info.sSalaryText.length == 0? @"": FORMAT(@" | %@", info.sSalaryText))];
    if ([str hasPrefix:@" | "]) {
        str = [str substringFromIndex:3];
    }
    cell.lb_date.text       = str;
    NSString *sCompany      = info.employerInfo.sName.length == 0? info.sCompnayName: info.employerInfo.sName;;
    cell.lb_company.text    = sCompany;
    cell.lb_reward.text     = FORMAT(@"%@荐币", [ HDJJUtility countNumAndChangeformat:info.sReward]);
    cell.lb_salary.hidden   = !info.isDeposit;
    [cell.btn_reward addTarget:self action:@selector(rewardOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn_reward.tag = indexPath.row;
    return cell;
}

#pragma mark -
#pragma mark evern respond
- (void)rewardOnClicked:(UIButton *)button{
    NSLog(@"赏金");
}
- (void)doIBAction:(UIButton *)sender{
    switch (sender.tag) {
        case 0:{//关注
            UIImageView *bg = (UIImageView *)[self.view viewWithTag:500];
            UIImageView *img =  (UIImageView *)[self.view viewWithTag:501];
            UILabel *lable = (UILabel *)[self.view viewWithTag:502];
            if (![HDGlobalInfo instance].hasLogined) {
                [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
                return;
            }
            if (_brokerInfo.isFocus) {
                img.hidden = NO;
                lable.hidden = NO;
                [sender setTitle:@"" forState:UIControlStateNormal];
                return;
            }
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
            [[HDHttpUtility sharedClient] attentionUser:[HDGlobalInfo instance].userInfo usernos:_brokerInfo.sHumanNo isfocus:@"1"   completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                if ([sMessage isEqualToString:@"关注成功"]) {
                    _brokerInfo.isFocus = YES;
                    bg.image = HDIMAGE(@"icon_anniuGray");
                    img.hidden = YES;
                    lable.hidden = YES;
                    [sender setTitle:@"已关注" forState:UIControlStateNormal];
                    [self.tbv reloadData];
                }else{
                    _brokerInfo.isFocus = NO;
                    [self.tbv reloadData];
                }
            }];
            break;
        }
        case 1:{//聊聊
            HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithHuman:_brokerInfo];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 
#pragma mark - private method
- (IBAction)showIntroduce:(UIButton *)sender {
    self.btn_arrow.selected = !self.btn_arrow.selected;
    if (self.btn_arrow.selected) {
        if ([_brokerInfo.sRoleType isEqualToString:@"0"]){
            self.introduceCellHeight = 0.1;
            return;
        }
        self.sIntroduce = FORMAT(@"%@\n认证信息:%@ %@", _brokerInfo.sRemark, _brokerInfo.sAuthenCompany, _brokerInfo.sAuthenPosition);
        CGFloat height = [HDJJUtility heightOfString:self.sIntroduce font:[UIFont systemFontOfSize:14] width:HDDeviceSize.width - 50 maxHeight:9999] + 30;
        self.introduceCellHeight = MAX(50, height);
    }else{
        self.sIntroduce = _brokerInfo.sRemark;
        self.introduceCellHeight = 50.0f;
    }
    [self.tbv reloadData];
}

- (void)httpGetBrokerDetails{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] getBrokerInfo:[HDGlobalInfo instance].userInfo userno:_sId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info) {
        [hud hiden];
        if (!isSuccess){
            [HDUtility mbSay:sMessage];
            return ;
        }
        _brokerInfo = info;
        self.sIntroduce = _brokerInfo.sRemark;
        [self.tbv reloadData];
    }];
}

- (void)httpGetPositions{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                         @"",@"functionCode",
                         @"",@"businessCode",
                         @"",@"area",
                         _sId,@"userno",
                         @"1",@"rewardMin",
                         @"",@"rewardMax",
                         @"",@"istop",
                         @"",@"isreward",nil];
    [[HDHttpUtility sharedClient] checkPosition:[HDGlobalInfo instance].userInfo typeDic:dic sort:@"8" pageIndex:@"1" size:@"24" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents){
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _ary_positionData = talents;
        [self.tbv reloadData];
    }];
}

#pragma mark -
#pragma mark getter and setter
- (void)setup{
    self.introduceCellHeight = 50.0f;
    self.navigationItem.title = LS(@"WJ_TITLE_BROKER_DETAILS");
}

@end

@implementation HDBrokerIntroCell

+ (HDBrokerIntroCell *)getCell{
    HDBrokerIntroCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:@"WJBrokerCell1" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDBrokerIntroCell class]]) {
            cell = (HDBrokerIntroCell *)obj;
            break;
        }
    }
    return cell;
}
@end

