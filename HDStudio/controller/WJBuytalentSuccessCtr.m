//
//  WJBuytalentSuccessCtr.m
//  JianJian
//
//  Created by liudu on 15/6/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJBuytalentSuccessCtr.h"
#import "WJBuyMoreServiceCell.h"
#import "WJHightTalentCtr.h"
#import "WJOrderListCtr.h"
#import "HDNewPositionCtr.h"
#import "HDChatViewCtr.h"
#import "WJTalentDetailCtr.h"
#import "WJAddPersonalCtr.h"
#import "WJSellOrderCtr.h"

@interface WJBuytalentSuccessCtr ()

@property (strong) IBOutlet UITableView *tbv;
@property (strong) IBOutlet UIView  *v_head;
@property (strong) IBOutlet UIView  *v_head1;
@property (strong) IBOutlet UILabel *lb_buySuccess;
@property (strong) IBOutlet UILabel *lb_name;
@property (strong) IBOutlet UILabel *lb_money;
@property (strong) IBOutlet UILabel *lb_wait;
@property (strong) IBOutlet UILabel *lb_time;
@property (strong) IBOutlet UILabel *lb_content;
@property (strong) NSMutableArray *ary_data;

@property (strong) NSString *buyId;
@property (strong) NSString *nickno;//荐客id
@property (assign) BOOL     isBuyResume;

@end

@implementation WJBuytalentSuccessCtr

- (id)initWithBuyId:(NSString *)buyID userNo:(NSString *)userNo isBuyResume:(BOOL)isBuyResume{
    self = [super init];
    if (self) {
        _buyId          = buyID;
        _nickno         = userNo;
        _isBuyResume    = isBuyResume;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpRequest];
    [self setLeftNavigationBarButton];
}

- (void)setup{
    self.tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = LS(@"WJ_TITLE_SERVICE_SUCCESS");
}

- (void)setLeftNavigationBarButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
}
- (void)doBack:(id)sender{
    for (UIViewController *ctr in self.navigationController.viewControllers) {
        if ([ctr isKindOfClass:[WJTalentDetailCtr class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WJ_NOTIFICATION_KEY_BUY_SERVICE_SUCCESS object:nil];
            [self.navigationController popToViewController:ctr animated:YES];
        }
        if ([ctr isKindOfClass:[WJSellOrderCtr class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WJ_NOTIFICATION_KEY_DONE_SERVICE" object:nil];
            [self.navigationController popToViewController:ctr animated:YES];
        }
    }
}
- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] getBuyServiceProgress:[HDGlobalInfo instance].userInfo buyId:_buyId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.ary_data = dataArray;
        [self.tbv reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 
#pragma mark --UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 90;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 30;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 10)];
        v.backgroundColor = [UIColor whiteColor];
        return v;
    }
    if (section == 1) {
        return self.v_head1;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 10)];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 1:
            if (_isBuyResume) {//人选列表
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                                                                               @"",@"area",
                                                                               @"",@"functioncode",
                                                                               @"",@"businesscode",
                                                                               @"",@"edulevel",
                                                                               @"",@"startworktime",
                                                                               @"",@"userno",
                                                                               @"",@"feeMin",
                                                                               @"",@"feeMax",nil];
                WJHightTalentCtr *talent = [[WJHightTalentCtr alloc] initWithResumeDic:dic isTop:NO];
                [self.navigationController pushViewController:talent animated:YES];
            }else{//联系雇主
                HDChatViewCtr *chat = [[HDChatViewCtr alloc] initWithChatterId:_nickno];
                [self.navigationController pushViewController:chat animated:YES];
            }
            break;
        case 2:
            if (_isBuyResume) {//聊聊
                HDChatViewCtr *chat = [[HDChatViewCtr alloc] initWithChatterId:_nickno];
                [self.navigationController pushViewController:chat animated:YES];
            }else{//发布人选
                WJAddPersonalCtr *ctr = [[WJAddPersonalCtr alloc] initWithTalentInfo:nil type:WJPersonalTypeAdd];
                [self.navigationController pushViewController:ctr animated:YES];
            }
            break;
        case 3:
            if (_isBuyResume) {//发布职位
                HDNewPositionCtr *newPosition = [[HDNewPositionCtr alloc] init];
                [self.navigationController pushViewController:newPosition animated:YES];
            }else{//订单列表
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"keyword",
                                     @"",@"functionCode",
                                     @"",@"businessCode",
                                     @"",@"area",
                                     @"",@"userno",
                                     @"1",@"rewardMin",
                                     @"",@"rewardMax",
                                     @"",@"istop",
                                     @"1",@"isreward",nil];
                WJOrderListCtr *order = [[WJOrderListCtr alloc] initWithPositionDic:dic isOrderList:YES];
                [self.navigationController pushViewController:order animated:YES];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.ary_data.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WJServiceSuccessCell";
        WJServiceSuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJServiceSuccessCell getServiceSuccessCell];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell getServiceSuccessData:[self.ary_data objectAtIndex:indexPath.row]];
        if (indexPath.row == self.ary_data.count-1) {
            cell.v_grayLine.hidden = YES;
            cell.v_greenLine.hidden = YES;
            cell.img_select.image = [UIImage imageNamed:@"v_selectGray"];
        }
        if (self.ary_data.count == 3&&indexPath.row == 0) {
            cell.v_grayLine.backgroundColor = [UIColor colorWithRed:0.58f green:0.85f blue:0.53f alpha:1.00f];
        }
        return cell;
    }
    static NSString *cellIdentifier = @"WJBuyMoreServiceCell";
    WJBuyMoreServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJBuyMoreServiceCell getBuyMoreServiceCell];
    }
    cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    if (_isBuyResume) {
        cell.img_head.image     = @[HDIMAGE(@"v_search"), HDIMAGE(@"v_broker"), HDIMAGE(@"v_position")][indexPath.section-1];
        cell.lb_title.text      = @[@"更多相似人选", @"联系荐客", @"发布职位"][indexPath.section-1];
        cell.lb_content.text    = @[@"为您匹配推荐更多相似人选,赶紧去抢人吧!",
                                    @"急于入手这个人选?去跟荐客聊聊吧",
                                    @"一个个找人才累?发布职位,荐客上门送人选"][indexPath.section-1];
    }else{
        cell.img_head.image    = @[HDIMAGE(@"v_search"), HDIMAGE(@"v_broker"), HDIMAGE(@"v_position")][indexPath.section-1];
        cell.lb_title.text     = @[@"联系雇主", @"发布人选", @"推荐陈晨"][indexPath.section-1];
        cell.lb_content.text   = @[@"去吱一下雇主吧,客户的满意度就是咱家多口碑啊",
                                   @"发布更多人选,更多订单上门",
                                   @"适合陈晨的职位不少,去看看吧"][indexPath.section-1];
    }    return cell;
}

@end
