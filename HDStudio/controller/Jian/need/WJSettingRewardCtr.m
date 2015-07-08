//
//  WJSettingReward.m
//  JianJian
//
//  Created by liudu on 15/5/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSettingRewardCtr.h"
#import "WJSettingRewardCell.h"
#import "WJContributrMarginCtr.h"
#import "HDTableView.h"

@interface WJSettingRewardCtr ()
@property (strong, nonatomic) IBOutlet HDTableView  *tbv;
@property (strong, nonatomic) IBOutlet UIView       *v_foot;
@property (strong, nonatomic) IBOutlet UIView       *v_line;
@property (strong, nonatomic) IBOutlet UITextField  *tf_days;
@property (strong, nonatomic) IBOutlet UITextField  *tf_money;
@property (strong) NSString                         *tradeId;
@property (strong) WJPositionInfo                   *positionInfo;
@property (strong, nonatomic) IBOutlet UIButton *btn_sure;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;
- (IBAction)sure:(UIButton *)sender;

@end

@implementation WJSettingRewardCtr

- (id)initWithInfo:(WJPositionInfo *)info{
    if (self = [super init]) {
        _positionInfo = info;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)handleKeyboardWillShow:(NSNotification *)notification{
    [self scrollBottom];
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view updateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view updateConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tf_days.text = @"1";
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_JJ_POSITION_REWARD");
    self.v_line.frame = CGRectMake(0, 0, HDDeviceSize.width, 0.5);
    self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 185);
    [self.tbv setTableFooterView:self.v_foot];
}

- (void)httpRequest{

    if (self.tf_days.text.length == 0) {
        [HDUtility mbSay:@"请输入天数"];
        return;
    }
    if (self.tf_money.text.length == 0){
        [HDUtility mbSay:@"请输入赏金!"];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] settingPositionReward:[HDGlobalInfo instance].userInfo positionID:_positionInfo.sPositionNo delayDay:self.tf_days.text reward:self.tf_money.text CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *ID) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _tradeId = ID;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:LS(@"TXT_JJ_POSITION_SET_REWARD_SUCCESS") delegate:self cancelButtonTitle:@"缴纳保证金" otherButtonTitles:@"跳过", nil];
        alert.tag = 999;
            [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999) {
        switch (buttonIndex) {
            case 0:
            {
                Dlog(@"money------%@",self.tf_money.text);
                WJContributrMarginCtr *margin = [[WJContributrMarginCtr alloc] initWithID:_tradeId money:self.tf_money.text];
                [self.navigationController pushViewController:margin animated:YES];
            }
                break;
            case 1:
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            default:
                break;
        }

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJSettingRewardCell";
    WJSettingRewardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getSettingCell];
    }
    cell.lb_position.text = _positionInfo.sPositionName;
    
    NSString *time = FORMAT(@"%@",([HDJJUtility isNull:_positionInfo.sPublishTime]? @"":_positionInfo.sPublishTime));
    NSString *area = FORMAT(@"%@",([HDJJUtility isNull:_positionInfo.sAreaText]? @"":_positionInfo.sAreaText));
    cell.lb_timeAndPlace.text = FORMAT(@"%@ | %@",time,area);
    if ([cell.lb_timeAndPlace.text hasPrefix:@" |"]){
        cell.lb_timeAndPlace.text = area;
        
    }
    if ([cell.lb_timeAndPlace.text hasSuffix:@"| "]) {
        cell.lb_timeAndPlace.text = time;
    }
    
    
    cell.lb_company.text      = _positionInfo.employerInfo.sName;
    cell.lb_salary.text         = _positionInfo.sSalaryText;
    return cell;
}

- (WJSettingRewardCell *)getSettingCell{
    WJSettingRewardCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJSettingRewardCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJSettingRewardCell class]]) {
            cell = (WJSettingRewardCell *)obj;
            break;
        }
    }
    return cell;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)sure:(UIButton *)sender {
    [self httpRequest];
}

- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}

@end
