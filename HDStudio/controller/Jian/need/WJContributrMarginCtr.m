//
//  WJContributrMarginCtr.m
//  JianJian
//
//  Created by liudu on 15/5/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJContributrMarginCtr.h"
#import "HDPositionDetailCtr.h"
#import "WJOnlinePayCtr.h"

@interface WJContributrMarginCtr ()
@property (strong, nonatomic) IBOutlet UIView   *v_line;
@property (strong, nonatomic) IBOutlet UIButton *btn_mobilePay;
@property (strong, nonatomic) IBOutlet UIButton *btn_remit;
@property (strong) NSString *ID;
@property (strong) NSString *money;

- (IBAction)mobilePay:(UIButton *)sender;
- (IBAction)remit:(UIButton *)sender;
@end

@implementation WJContributrMarginCtr

- (id)initWithID:(NSString *)tradeid money:(NSString *)Money{
    self = [super init];
    if (self) {
        _ID     = tradeid;
        Dlog(@"#######%@",Money);
        _money  = Money;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp{
    self.navigationItem.title = LS(@"TXT_JJ__MONEY_REMIT");
  
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0,0 , 103,44)];
    [leftBtn addTarget:self action:@selector(toHDPosition) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 13, 24)];
    leftImage.image = [UIImage imageNamed:@"icon_leftBack"];
    [leftBtn addSubview:leftImage];
    
    UILabel * leftLab = [[UILabel alloc]initWithFrame:CGRectMake(leftImage.frame.origin.x+leftImage.frame.size.width+5, 7, 90, 30)];
    leftLab.text = @"职位详情";
    leftLab.textColor = [UIColor whiteColor];
    leftLab.font = [UIFont systemFontOfSize:17];
    [leftBtn addSubview:leftLab];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    self.v_line.frame = CGRectMake(0, 0, HDDeviceSize.width, 0.5);
}

- (void)toHDPosition{
    Dlog(@"----");
    NSArray *controllers = self.navigationController.viewControllers;
    [self.navigationController popToViewController:controllers[controllers.count - 3] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)mobilePay:(UIButton *)sender {
    Dlog(@"money=======%@",_money);
    WJOnlinePayCtr *online  = [[WJOnlinePayCtr alloc] initWithTradeid:self.ID shopPrice:_money payType:WJPayRewardType nickNo:nil];
    
    [self.navigationController pushViewController:online animated:YES];
}

- (IBAction)remit:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"汇款信息" message:@"汇款账号:6524 6545 6525 6322\n收款人:福州六度伯乐有限公司\n汇款请备注您的帐号以便我们及时为您充值" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

@end
