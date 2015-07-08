//
//  HDDiscoverCtr.m
//  JianJian
//
//  Created by liudu on 15/5/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDDiscoverCtr.h"
#import "WJDiscoverCell.h"
#import "HDFindBrokerCtr.h"
#import "WJOrderListCtr.h"
#import "WJCheckOrder.h"
#import "WJHightTalentCtr.h"
#import "WJBrokerListCtr.h"
#import "WJSearchCtr.h"
#import "WJCheckPositionCtr.h"

@interface HDDiscoverCtr ()

@property (strong, nonatomic) IBOutlet UIView *v_navgation;
@property (strong, nonatomic) IBOutlet UITableView *tbv;
@property (strong, nonatomic) IBOutlet UIView *v_head1;
@property (strong, nonatomic) IBOutlet UIView *v_head2;
@property (strong, nonatomic) IBOutlet UIView *v_head3;
@property (strong, nonatomic) IBOutlet UIView *v_foot1;

@property (strong) AFHTTPRequestOperation   *op;
@property (strong) NSMutableArray           *dataArray;

@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UIButton *btn2;
@property (strong, nonatomic) IBOutlet UIButton *btn3;
@property (strong, nonatomic) IBOutlet UIButton *btn4;
@property (strong, nonatomic) IBOutlet UILabel *lb_position1;
@property (strong, nonatomic) IBOutlet UILabel *lb_position2;
@property (strong, nonatomic) IBOutlet UILabel *lb_position3;
@property (strong, nonatomic) IBOutlet UILabel *lb_position4;
@property (strong, nonatomic) IBOutlet UILabel *lb_price1;
@property (strong, nonatomic) IBOutlet UILabel *lb_price2;
@property (strong, nonatomic) IBOutlet UILabel *lb_price3;
@property (strong, nonatomic) IBOutlet UILabel *lb_price4;

- (IBAction)checkDetails:(UIButton *)sender;

@end

@implementation HDDiscoverCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
}
- (void)viewWillAppear:(BOOL)animated{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.tabBarController.tabBar.hidden = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.tabBarController.tabBar.hidden = YES;
    }
}
- (void)setup{
    self.tbv.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1.)];
    self.v_navgation.frame = CGRectMake(20, 5, HDDeviceSize.width-40, 30);
    self.navigationItem.titleView   = self.v_navgation;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(search)];
    [self.v_navgation addGestureRecognizer:tap];
}

- (void)search{
     [self.navigationController pushViewController:[WJSearchCtr new] animated:YES];
}

- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                         @"", @"functionCode",
                         @"", @"businessCode",
                         @"", @"area",
                         @"", @"userno",
                         @"", @"rewardMin",
                         @"", @"rewardMax",
                         @"1",@"istop",
                         @"",@"isreward",nil];
    _op = [[HDHttpUtility sharedClient] checkPosition:[HDGlobalInfo instance].userInfo typeDic:dic sort:@"" pageIndex:@"1" size:@"4" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _dataArray = [NSMutableArray arrayWithArray:talents];
        [self footView];
    }];
}

- (void)footView{
    if (_dataArray.count == 0){
        return;
    }
    NSArray *ary_btnImg     = @[_btn1, _btn2, _btn3, _btn4];
    NSArray *ary_position   = @[_lb_position1, _lb_position2, _lb_position3, _lb_position4];
    NSArray *ary_money      = @[_lb_price1, _lb_price2, _lb_price3, _lb_price4];
    for (int i = 0; i < 4; i++) {
        UIButton *button = ary_btnImg[i];
        UILabel *lb_position = ary_position[i];
        UILabel *lb_price = ary_money[i];
        button.hidden       = YES;
        lb_position.hidden  = YES;
        lb_price.hidden     = YES;
    }
    for (int i = 0; i < _dataArray.count; i++) {
        UIButton *button = ary_btnImg[i];
        UILabel *lb_position = ary_position[i];
        UILabel *lb_price = ary_money[i];
        button.hidden       = NO;
        lb_position.hidden  = NO;
        lb_price.hidden     = NO;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor colorWithRed:204/250. green:204/250. blue:204/250. alpha:1.0f].CGColor;
        WJPositionInfo *info = [_dataArray objectAtIndex:i];
        [HDJJUtility getImage:info.employerInfo.sScene01 withBlock:^(NSString *code, NSString *message, UIImage *img) {
            [button setBackgroundImage:img forState:UIControlStateNormal];
            lb_position.text = info.sPositionName;
            lb_price.text   = [HDJJUtility isNull:info.sReward] ? @"": FORMAT(@"%@荐币",info.sReward);
        }];
    }

}

- (IBAction)checkDetails:(UIButton *)sender{
    WJPositionInfo *info = _dataArray[sender.tag];
    WJCheckPositionCtr *position = [[WJCheckPositionCtr alloc] initWithPositionId:info.sPositionNo];
    [self.navigationController pushViewController:position animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                                 @"",@"functionCode",
                                 @"",@"businessCode",
                                 @"",@"area",
                                 @"",@"userno",
                                 @"1",@"rewardMin",
                                 @"",@"rewardMax",
                                 @"",@"istop",
                                 @"1",@"isreward",nil];
            WJOrderListCtr *order = [[WJOrderListCtr alloc] initWithPositionDic:dic isOrderList:NO];
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case 1:
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                                 @"",@"area",
                                 @"",@"functioncode",
                                 @"",@"businesscode",
                                 @"",@"edulevel",
                                 @"",@"startworktime",
                                 @"",@"userno",
                                 @"",@"feeMin",
                                 @"",@"feeMax",nil];
            WJHightTalentCtr *talent = [[WJHightTalentCtr alloc] initWithResumeDic:dic isTop:YES];
            [self.navigationController pushViewController:talent animated:YES];
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"keyword",
                                                                                                @"", @"functionCode",
                                                                                                @"", @"businessCode",
                                                                                                @"", @"startworkDT",
                                                                                                @"", @"area",
                                                                                                @"1",@"roleType",
                                                                                                @"1",@"istop", nil];
                    WJBrokerListCtr *broker = [[WJBrokerListCtr alloc] init];
                    broker.typeDic = dic;
                    [self.navigationController pushViewController:broker animated:YES];
                }
                    break;
                case 1:
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"keyword",
                                                @"", @"functionCode",
                                                @"", @"businessCode",
                                                @"", @"startworkDT",
                                                @"", @"area",
                                                @"2",@"roleType",
                                                @"1",@"istop", nil];
                    WJBrokerListCtr *broker = [[WJBrokerListCtr alloc] init];
                    broker.typeDic = dic;
                    [self.navigationController pushViewController:broker animated:YES];
                }
                    break;
                    case 2:
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"keyword",
                                                @"", @"functionCode",
                                                @"", @"businessCode",
                                                @"", @"startworkDT",
                                                @"", @"area",
                                                @"3",@"roleType",
                                                @"1",@"istop", nil];
                    WJBrokerListCtr *broker = [[WJBrokerListCtr alloc] init];
                    broker.typeDic = dic;
                    [self.navigationController pushViewController:broker animated:YES];
                }
                    break;
                case 3:
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"keyword",
                                                @"", @"functionCode",
                                                @"", @"businessCode",
                                                @"", @"startworkDT",
                                                @"", @"area",
                                                @"4",@"roleType",
                                                @"1",@"istop", nil];
                    WJBrokerListCtr *broker = [[WJBrokerListCtr alloc] init];
                    broker.typeDic = dic;
                    [self.navigationController pushViewController:broker animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        return 50;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0){
        return 165;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.v_head1;
    }else if (section == 1){
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
    return 2;
//    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2){
        return 4;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJDiscoverCell";
    WJDiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJDiscoverCell getDiscoverCell];
    }
    if (indexPath.section == 0) {
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
        cell.lb_title.text              = @"悬赏推荐专区";
        cell.lb_content.text            = @"推荐人才,获取高额赏金";
        cell.v_price.hidden             = NO;
        cell.lb_reward.text             = FORMAT(@"¥%@",[HDJJUtility countNumAndChangeformat:@"52231151"]);
        cell.lc_priceview.constant      = [self viewWidth:cell.lb_reward.text uifont:14];
        cell.lb_certification.hidden    = YES;
        cell.lb_message.hidden          = YES;
        return cell;
    }else if (indexPath.section == 1){
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
        cell.img_head.image                 = [UIImage imageNamed:@"v_talent"];
        cell.lb_title.text                  = @"高级人才库";
        cell.lb_content.text                = @"荐客推荐,群英荟萃,个性化招聘服务";
        cell.lc_priceview.constant = 0;
        cell.v_price.hidden                 = YES;
        cell.lb_certification.hidden        = YES;
        cell.lb_message.hidden              = YES;
        return cell;
    }
    cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    cell.img_head.frame         = CGRectMake(8, 10, 30, 30);
    cell.v_price.hidden         = YES;
    cell.lb_title.hidden        = YES;
    cell.lb_content.hidden      = YES;
    cell.img_head.image         = @[HDIMAGE(@"v_boss"),HDIMAGE(@"v_manager"),HDIMAGE(@"v_HR"),HDIMAGE(@"v_hunter")][indexPath.row];
    cell.lb_certification.text  = @[@"Boss",@"企业高管",@"企业HR",@"猎头"][indexPath.row];
    if (indexPath.row == 0) {
        cell.lb_message.hidden  = NO;
    }else{
        cell.lb_message.hidden  = YES;
    }
    return cell;
}



//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(120, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+45;
    return width;
}



@end
