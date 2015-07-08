//
//  WJMyWalletCtr.m
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJMyWalletCtr.h"
#import "HDJianCell.h"
#import "WJTotalOutList.h"
#import "WJOnlinePayCtr.h"
#import "WJWithdrawCtr.h"

@interface WJMyWalletCtr ()
@property (strong, nonatomic) IBOutlet UIView               *v_head;
@property (strong, nonatomic) IBOutlet UITableView          *tbv;
@property (strong)  WJBalanceInfo                           *balanceInfo;
@property (strong, nonatomic) IBOutlet UILabel              *lb_allBalance;
@property (strong, nonatomic) IBOutlet UILabel              *lb_marginBalance;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lc_marginBalanceWithWidth;

@end

@implementation WJMyWalletCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"WJ_TITLE_WALLET");
     [self setTableViewHead];
    [self.view updateConstraints];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getBalance:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _balanceInfo = balance;
        self.lb_allBalance.text = FORMAT(@"%@荐币",_balanceInfo.sGoldCount);
        self.lb_marginBalance.text = FORMAT(@"%@",_balanceInfo.sDeposit);
        self.lc_marginBalanceWithWidth.constant = [self viewWidth:self.lb_marginBalance.text uifont:17];
        [self.view updateConstraints];
    }];
}

- (void)setTableViewHead{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 135);
    [self.tbv setTableHeaderView:self.v_head];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    WJTotalOutList *list = [[WJTotalOutList alloc] init];
                    list.type = @"1";
                    list.money = _balanceInfo.sTotalOut;
                    [self.navigationController pushViewController:list animated:YES];
                }
                    break;
                case 1:
                {
                    WJTotalOutList *list = [[WJTotalOutList alloc] init];
                    list.type = @"2";
                    list.money = _balanceInfo.sTotalIn;
                    [self.navigationController pushViewController:list animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSLog(@"提现");
                   // [HDJJUtility jjSay:@"该功能暂未开发,敬请期待!" delegate:self];
                    [self.navigationController pushViewController:[WJWithdrawCtr new] animated:YES];
                }
                    break;
                case 1:
                {
                    NSLog(@"充值");
                    WJOnlinePayCtr *pay = [[WJOnlinePayCtr alloc] initWithTradeid:@"0" shopPrice:nil payType:WJOnlineCharge nickNo:nil];
                    [self.navigationController pushViewController:pay animated:YES];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"HDJianCell";
    HDJianCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self getJianCell];
        cell.imv_value.hidden   = YES;
        cell.v_redDot.hidden    = YES;
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.lb_title.text  = @[@[@"支付清单",@"收入清单"],@[@"提现",@"充值"]][indexPath.section][indexPath.row];
    cell.imv_head.image = @[@[HDIMAGE(@"icon_payList"),HDIMAGE(@"icon_revenue")],@[HDIMAGE(@"icon_withdraw"),HDIMAGE(@"icon_recharge")]][indexPath.section][indexPath.row];
    return cell;
}

- (HDJianCell *)getJianCell{
    HDJianCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDJianCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJianCell class]]) {
            cell = (HDJianCell *)obj;
            break;
        }
    }
    return cell;
}

//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(200, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+2;
    return width;
}

@end
