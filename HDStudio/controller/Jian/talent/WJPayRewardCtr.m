//
//  WJPayRewardCtr.m
//  JianJian
//
//  Created by liudu on 15/5/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPayRewardCtr.h"
#import "WJPayRewardCell.h"
#import "BaseFunc.h"
#import "LDCry.h"

@interface WJPayRewardCtr ()
@property (strong, nonatomic) IBOutlet UITableView      *tbv;
@property (strong, nonatomic) IBOutlet UIView           *v_foot;
@property (strong, nonatomic) IBOutlet UITextField      *tf_password;
@property (strong, nonatomic) IBOutlet UIButton         *btn_pay;
@property (strong) AFHTTPRequestOperation               *op;
@property (strong) WJRewardMessageInfo                  *rewardInfo;
- (IBAction)pay:(UIButton *)sender;

@end

@implementation WJPayRewardCtr

- (id)initWithInfo:(WJRewardMessageInfo *)info{
    if (!info) {
        Dlog(@"传入参数错误！");
        return nil;
    }
    if (self = [super init]) {
        _rewardInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableViewFoot];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_PAY_REWARD");
}

- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    Dlog(@"密码----%@",self.tf_password.text);
    Dlog(@"推荐ID---%@",self.recommendId);
    [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
        if (!isSuccess){
            [HDUtility say:message];
            return ;
        }
        NSString *sRealKey = [BaseFunc getRadomKey:key];
        if (sRealKey.length != 16) {
            [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
            return;
        }
        NSString *sEncryUserId = [LDCry encrypt:self.tf_password.text password:sRealKey];
        _op = [[HDHttpUtility sharedClient] passwordPayReward:[HDGlobalInfo instance].userInfo  psd:sEncryUserId recommendId:self.recommendId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            [HDUtility mbSay:@"支付成功"];
            if ([_delegate respondsToSelector:@selector(payRewardSuccess:)]) {
                [_delegate payRewardSuccess:YES];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];

    }];
    
}

- (void)setTableViewFoot{
    self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 110);
    [self.tbv setTableFooterView:self.v_foot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJPayRewardCell";
    WJPayRewardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getPayRewardCell];
    }
    cell.lb_recommendName.text  = _rewardInfo.sRName;
    cell.lb_name.text           = _rewardInfo.sPName;
    cell.lb_RPosition.text      = _rewardInfo.sPositionName;
    cell.lb_reward.text         = FORMAT(@"%@荐币",_rewardInfo.sReward);
    cell.lb_deposit.text        = FORMAT(@"%@荐币",_rewardInfo.sDeposit);
    cell.lb_spread.text         = FORMAT(@"%d荐币",[_rewardInfo.sReward intValue]-[_rewardInfo.sDeposit intValue]);
    return cell;
}

- (WJPayRewardCell *)getPayRewardCell{
    WJPayRewardCell *cell = nil;
    NSArray         *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPayRewardCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJPayRewardCell class]]) {
            cell = (WJPayRewardCell *)obj;
            break;
        }
    }
    return cell;
}

- (IBAction)pay:(UIButton *)sender {
       [self httpRequest];
}
@end
