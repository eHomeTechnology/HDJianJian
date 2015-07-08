//
//  WJOnlinePayCtr.m
//  JianJian
//
//  Created by liudu on 15/5/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJOnlinePayCtr.h"
#import "WJPayWayCell.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WJMyWalletCtr.h"
#import "HDTableView.h"
#import "WJBuytalentSuccessCtr.h"
#import "WJCheckPositionCtr.h"

@interface WJOnlinePayCtr (){
    NSNotificationCenter    *nc_paySuccess;
}
@property (strong, nonatomic) IBOutlet HDTableView          *tbv;
@property (strong, nonatomic) IBOutlet UIView               *v_head;
@property (strong, nonatomic) IBOutlet UIView               *v_foot;
@property (strong, nonatomic) IBOutlet UIView               *v_foot1;
@property (strong, nonatomic) IBOutlet UILabel              *lb_name;
@property (strong, nonatomic) IBOutlet UILabel              *lb_balanceMoney;//余额
@property (strong, nonatomic) IBOutlet UILabel              *lb_payMoney;//充值金额
@property (strong, nonatomic) IBOutlet UITextField          *tf_payMoney;
@property (strong, nonatomic) IBOutlet UIButton             *btn_pay;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lc_payMoney;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lc_lineWithHeight;
@property (strong) AFHTTPRequestOperation                   *op;
@property (strong) NSString                                 *payType;//支付渠道 1 银联 2 支付宝
@property (strong) NSString                                 *merchandiseCode;//商品编码    保证金 100100 在线充值 100101
@property (strong) NSMutableArray                           *dataArray;

@property (strong) NSString                                 *tradeid;//交易模式编号
@property (strong) NSString                                 *shopPrice;//商品价格
@property (assign) NSInteger                                payment;//缴纳保证金 购买服务 在线充值
@property (strong) NSString                                 *buyID;
@property (strong) NSString                                 *userNO;//人选编号
@property (strong) NSString                                 *nickNo;//荐客编号

- (IBAction)pay:(UIButton *)sender;

@end

@implementation WJOnlinePayCtr

- (id)initWithTradeid:(NSString *)tradeid shopPrice:(NSString *)price payType:(NSInteger)type nickNo:(NSString *)nickNO{
    self = [super init];
    if (self) {
        _tradeid            = tradeid;
        _shopPrice          = price;
        _payment            = type;
        _nickNo             = nickNO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Dlog(@"shopPrice**********%@",_shopPrice);
    [self setup];
    [self setTableViewHead];
}

- (void)viewDidAppear:(BOOL)animated{
    if (!nc_paySuccess) {
        nc_paySuccess = [NSNotificationCenter defaultCenter];
        [nc_paySuccess addObserver:self selector:@selector(alipayInfoResult:) name:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:nil];
    }
}

//- (void)popToMyWallet{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (void)alipayInfoResult:(NSNotification *)notification{
    NSString *objectString = [notification object];
    if ([objectString isEqualToString:@"SuccessA"]) {
        switch (_payment ) {
            case WJPayRewardType:{//缴纳保证金
                for (UIViewController *ctr in self.navigationController.viewControllers) {
                    if ([ctr isKindOfClass:[WJCheckPositionCtr class]]) {
                        [self.navigationController popToViewController:ctr animated:YES];
                        return;
                    }
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
            case WJPayBuyServiceType :{
                WJBuytalentSuccessCtr *buy = [[WJBuytalentSuccessCtr alloc] initWithBuyId:@"0" userNo:_nickNo isBuyResume:YES];
                [self.navigationController pushViewController:buy animated:YES];
                return;
            }
            case WJOnlineCharge:{
                for (UIViewController *ctr in self.navigationController.viewControllers) {
                    if ([ctr isKindOfClass:[WJMyWalletCtr class]]) {
                        [self.navigationController popToViewController:ctr animated:YES];
                        return;
                    }
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [_op cancel];
    _op = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WJ_NOTIFICATION_KEY_PAY_SUCCESS object:nil];
    [super viewDidDisappear:YES];
}

- (void)setup{
    switch (_payment) {
        case WJPayRewardType:
        {
            self.navigationItem.title = LS(@"WJ_TITLE_ONLINE_PAY");
        }
            break;
        case WJPayBuyServiceType:
        {
            
            self.navigationItem.title = LS(@"WJ_TITLE_ONLINE_PAY");
        }
            break;
        case WJOnlineCharge:
        {
            self.navigationItem.title = LS(@"WJ_TITLE_ONLINE_RECHARGE");
        }
            break;
        default:
            break;
    }
    self.tf_payMoney.text = _shopPrice;
    self.tf_payMoney.userInteractionEnabled = YES;
    if (_payment == WJPayRewardType) {
        self.tf_payMoney.userInteractionEnabled = NO;
    }
    self.lb_payMoney.text = FORMAT(@"%.1f元",[_shopPrice floatValue]/10);
    if (_shopPrice == nil){
        self.lb_payMoney.text = nil;
    }

    self.merchandiseCode = @"100101";
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] getBalance:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBalanceInfo *balance) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.lb_balanceMoney.text = FORMAT(@"%@荐币",balance.sGoldCount);
    }];
    [[HDHttpUtility sharedClient] rechargeCombo:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *dataArray) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _dataArray = [NSMutableArray arrayWithArray:dataArray];
        [_tbv reloadData];
    }];
}

- (void)setTableViewHead{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 181);
    HDUserInfo *info = [HDGlobalInfo instance].userInfo;
    self.lb_name.text = info.sName;
    [self.tbv setTableHeaderView:self.v_head];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_payment == WJPayRewardType) {
        return 80;
    }
    if (indexPath.section == 0) {
        return 44;
    }
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 44;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        self.lc_lineWithHeight.constant = 0.1;
        return self.v_foot1;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.01)];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIButton *btn_combo1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *btn_combo2 = (UIButton *)[self.view viewWithTag:201];
    UIButton *btn_combo3 = (UIButton *)[self.view viewWithTag:202];
    UIButton *btn_combo4 = (UIButton *)[self.view viewWithTag:203];
    if (indexPath.section == 0) {
        WJMerchandiseListInfo *info = [_dataArray objectAtIndex:indexPath.row];
        switch (indexPath.row) {
            case 0:
            {
                self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
                self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
                self.tradeid        = info.sMerchandiseCode;
                self.merchandiseNum = @"1";
                btn_combo1.selected = YES;
                btn_combo2.selected = NO;
                btn_combo3.selected = NO;
                btn_combo4.selected = NO;
            }
                break;
            case 1:
            {
                self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
                self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
                self.tradeid        = info.sMerchandiseCode;
                self.merchandiseNum = @"1";
                btn_combo2.selected = YES;
                btn_combo1.selected = NO;
                btn_combo3.selected = NO;
                btn_combo4.selected = NO;
            }
                break;
            case 2:
            {
                self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
                self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
                self.tradeid        = info.sMerchandiseCode;
                self.merchandiseNum = @"1";
                btn_combo3.selected = YES;
                btn_combo1.selected = NO;
                btn_combo2.selected = NO;
                btn_combo4.selected = NO;
            }
                break;
            case 3:
            {
                self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
                self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
                self.tradeid        = info.sMerchandiseCode;
                self.merchandiseNum = @"1";
                btn_combo4.selected = YES;
                btn_combo1.selected = NO;
                btn_combo2.selected = NO;
                btn_combo3.selected = NO;
            }
                break;
            default:
                break;
        }
        return;
    }
//    UIButton *btn_unionpay  = (UIButton *)[self.view viewWithTag:100];
//    UIButton *btn_alipay    = (UIButton *)[self.view viewWithTag:101];
//    UIButton *btn_wChat     = (UIButton *)[self.view viewWithTag:102];
//    switch (indexPath.row) {
//        case 0:
//        {
//            btn_unionpay.selected   = YES;
//            btn_alipay.selected     = NO;
//            btn_wChat.selected      = NO;
//            [HDJJUtility jjSay:@"改功能暂未开发,敬请期待" delegate:self];
//        }
//            break;
//        case 1:
//        {
//            btn_alipay.selected     = YES;
//            btn_unionpay.selected   = NO;
//            btn_wChat.selected      = NO;
//            self.payType            = @"2";
//        }
//            break;
//        case 2:
//        {
//            btn_wChat.selected      = YES;
//            btn_unionpay.selected   = NO;
//            btn_alipay.selected     = NO;
//            [HDJJUtility jjSay:@"改功能暂未开发,敬请期待" delegate:self];
//        }
//            break;
//            
//        default:
//            break;
//    }
   
    self.payType            = @"2";
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_payment == WJPayRewardType) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_payment == WJPayRewardType) {
        return 1;
    }
    if (section == 0) {
       // return 3;
        return _dataArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_payment == WJPayRewardType) {
        static NSString *cellIdentifer = @"WJPayWayCell";
        WJPayWayCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if (cell == nil) {
            cell = [WJPayWayCell getPayWayCell];
        }
        self.tbv.separatorStyle = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //    cell.img_head.image         = @[HDIMAGE(@"icon_Unionpay"),HDIMAGE(@"icon_Alipay"),HDIMAGE(@"icon_wChat")][indexPath.row];
        //    cell.lb_card.text           = @[LS(@"WJ_ME_PAY_UNIONPAY"),LS(@"WJ_ME_PAY_ALIPAY"),LS(@"WJ_ME_PAY_WCHAT")][indexPath.row];
        //    cell.lb_cardContent.text    = @[LS(@"WJ_ME_PAY_UNIONPAY_CONTENT"),LS(@"WJ_ME_PAY_ALIPAY_CONTENT"),LS(@"WJ_ME_PAY_WCHAT_CONTENT")][indexPath.row];
        //    cell.btn_select.tag = 100 + indexPath.row;
        cell.img_head.image         = HDIMAGE(@"icon_Alipay");
        cell.lb_card.text           = LS(@"WJ_ME_PAY_ALIPAY");
        cell.lb_cardContent.text    = LS(@"WJ_ME_PAY_ALIPAY_CONTENT");
        cell.btn_select.tag         = 101;
        cell.btn_select.selected    = YES;
        [cell.btn_select addTarget:self action:@selector(selectOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    if (indexPath.section == 0){
        static NSString *cellIdentifier = @"WJGiveCell";
        WJGiveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJGiveCell getGiveCell];
        }
        self.tbv.separatorStyle = NO;
        //cell.lb_content.text = @[@"1000送5套餐",@"5000送50套餐",@"10000送120套餐"][indexPath.row];
        WJMerchandiseListInfo *listInfo = [_dataArray objectAtIndex:indexPath.row];
        cell.lb_content.text = listInfo.sMerchandiseName;
        cell.btn_selectCombo.tag = 200 + indexPath.row;
        [cell.btn_selectCombo addTarget:self action:@selector(selectComboOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
   
    static NSString *cellIdentifer = @"WJPayWayCell";
    WJPayWayCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [WJPayWayCell getPayWayCell];
    }
    self.tbv.separatorStyle = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.img_head.image         = @[HDIMAGE(@"icon_Unionpay"),HDIMAGE(@"icon_Alipay"),HDIMAGE(@"icon_wChat")][indexPath.row];
//    cell.lb_card.text           = @[LS(@"WJ_ME_PAY_UNIONPAY"),LS(@"WJ_ME_PAY_ALIPAY"),LS(@"WJ_ME_PAY_WCHAT")][indexPath.row];
//    cell.lb_cardContent.text    = @[LS(@"WJ_ME_PAY_UNIONPAY_CONTENT"),LS(@"WJ_ME_PAY_ALIPAY_CONTENT"),LS(@"WJ_ME_PAY_WCHAT_CONTENT")][indexPath.row];
//    cell.btn_select.tag = 100 + indexPath.row;
    cell.img_head.image         = HDIMAGE(@"icon_Alipay");
    cell.lb_card.text           = LS(@"WJ_ME_PAY_ALIPAY");
    cell.lb_cardContent.text    = LS(@"WJ_ME_PAY_ALIPAY_CONTENT");
    cell.btn_select.tag         = 101;
    cell.btn_select.selected    = YES;
    [cell.btn_select addTarget:self action:@selector(selectOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)selectComboOnClicked:(UIButton *)button{
    UIButton *btn_combo1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *btn_combo2 = (UIButton *)[self.view viewWithTag:201];
    UIButton *btn_combo3 = (UIButton *)[self.view viewWithTag:202];
    UIButton *btn_combo4 = (UIButton *)[self.view viewWithTag:203];
    WJMerchandiseListInfo *info = _dataArray[button.tag -200];

    switch (button.tag) {
        case 200:
        {
            self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
            self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
            self.tradeid        = info.sMerchandiseCode;
            self.merchandiseNum = @"1";
            btn_combo1.selected = YES;
            btn_combo2.selected = NO;
            btn_combo3.selected = NO;
            btn_combo4.selected = NO;
        }
            break;
        case 201:
        {
            self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
            self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
            self.tradeid        = info.sMerchandiseCode;
            self.merchandiseNum = @"1";
            btn_combo2.selected = YES;
            btn_combo1.selected = NO;
            btn_combo3.selected = NO;
            btn_combo4.selected = NO;
        }
            break;
        case 202:
        {
            self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
            self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
            self.tradeid        = info.sMerchandiseCode;
            self.merchandiseNum = @"1";
            btn_combo3.selected = YES;
            btn_combo1.selected = NO;
            btn_combo2.selected = NO;
            btn_combo4.selected = NO;
        }
            break;
        case 3:
        {
            self.tf_payMoney.text = FORMAT(@"%d",[info.sBGPoint intValue]+[info.sPGPoint intValue]);
            self.lb_payMoney.text = FORMAT(@"%0.1f元",[info.sBGPoint floatValue]/10);
            self.tradeid        = info.sMerchandiseCode;
            self.merchandiseNum = @"1";
            btn_combo4.selected = YES;
            btn_combo1.selected = NO;
            btn_combo2.selected = NO;
            btn_combo3.selected = NO;
        }
            break;
        default:
            break;
    }
}

- (void)selectOnClicked:(UIButton *)button{
//    UIButton *btn_unionpay  = (UIButton *)[self.view viewWithTag:100];
//    UIButton *btn_alipay    = (UIButton *)[self.view viewWithTag:101];
//    UIButton *btn_wChat     = (UIButton *)[self.view viewWithTag:102];
//    switch (button.tag) {
//        case 100:
//        {
//            btn_unionpay.selected   = YES;
//            btn_alipay.selected     = NO;
//            btn_wChat.selected      = NO;
//            [HDJJUtility jjSay:@"改功能暂未开发,敬请期待" delegate:self];
//        }
//            break;
//        case 101:
//        {
//            btn_alipay.selected     = YES;
//            btn_unionpay.selected   = NO;
//            btn_wChat.selected      = NO;
//            self.payType            = @"2";
//        }
//            break;
//        case 102:
//        {
//            btn_wChat.selected      = YES;
//            btn_unionpay.selected   = NO;
//            btn_alipay.selected     = NO;
//            [HDJJUtility jjSay:@"改功能暂未开发,敬请期待" delegate:self];
//        }
//            break;
//            
//        default:
//            break;
//    }

    self.payType    = @"2";
}

//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(200, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+2;
    return width;
}

#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UIButton *btn_combo1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *btn_combo2 = (UIButton *)[self.view viewWithTag:201];
    UIButton *btn_combo3 = (UIButton *)[self.view viewWithTag:202];
    btn_combo1.selected = NO;
    btn_combo2.selected = NO;
    btn_combo3.selected = NO;
    if (![string isEqualToString:@""]) {
        if ([self isPureInt:string]) {
            if (textField.text.length == 0) {
                self.lb_payMoney.text = FORMAT(@"0.%@元",string);
            }else {
            self.lb_payMoney.text = FORMAT(@"%@.%@元",textField.text,string);
            }
        }else{
            [HDUtility mbSay:@"请输入整数"];
            return NO;
        }
    }else{
        if ([textField.text substringToIndex:textField.text.length-1].length == 0) {
            self.lb_payMoney.text = @"";
        }else{
            self.lb_payMoney.text = FORMAT(@"%0.1f元",[[textField.text substringToIndex:textField.text.length-1] floatValue]/10.);
        }
    }
    self.lc_payMoney.constant = [self viewWidth:self.lb_payMoney.text uifont:17];
    return YES;
}

//判断是否为整形
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (IBAction)pay:(UIButton *)sender {
    UIButton *btn_unionpay  = (UIButton *)[self.view viewWithTag:100];
    UIButton *btn_alipay    = (UIButton *)[self.view viewWithTag:101];
    UIButton *btn_wChat     = (UIButton *)[self.view viewWithTag:102];
    if (self.tf_payMoney.text.length == 0){
        [HDUtility mbSay:@"请输入充值金额"];
        return;
    }else if(btn_alipay.selected == NO&&btn_unionpay.selected == NO&&btn_wChat.selected == NO){
        [HDUtility mbSay:@"请选择支付方式"];
        return;
    }else{
        NSString *number = nil;
        if ([self.merchandiseNum isEqualToString:@"1"]) {
            number = @"1";
        }else{
            number = FORMAT(@"%d",[self.tf_payMoney.text intValue]*10);
        }
        HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
        _op = [[HDHttpUtility sharedClient] createPayOrder:[HDGlobalInfo instance].userInfo tradeid:self.tradeid merchandiseCode:self.merchandiseCode number:number channeltype:self.payType completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *payID) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            self.payID = payID;
            [self GotoAlipayClick];
        }];
    }
}

- (void)GotoAlipayClick
{
    //partner和seller获取失败,提示
    if ([PartnerID length] == 0 || [SellerID length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *url = FORMAT(@"%@inpay/alip/NotifyCallback.aspx",[HDGlobalInfo instance].addressInfo.sWebsite_approot);
    Dlog(@"url----%@",url);
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner                       = PartnerID;        //合作者身 份ID
    order.seller                        = SellerID;         //卖家支付宝账号
    order.tradeNO                       = self.payID;       //订单ID(由商家自行定制)
    order.productName                   = @"麦斯特";         //商品标题
    order.productDescription            = @"猎头公司";       //商品描述
    order.amount                        = FORMAT(@"%.2f",[self.lb_payMoney.text floatValue]);
    order.notifyURL                     = url;
    order.service                       = @"mobile.securitypay.pay";//接口名称
    order.paymentType                   = @"1";         //支付类型
    order.inputCharset                  = @"utf-8";
    order.itBPay                        = @"30m";       //未付款交 易的超时 时间
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"JianJian";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
