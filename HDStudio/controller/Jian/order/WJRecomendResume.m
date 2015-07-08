//
//  WJRecomendResume.m
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecomendResume.h"
#import "WJRecommendResumeCell.h"
#import "WJEvaluateResumeCtr.h"
#import "HDValueItem.h"
#import "HDTableView.h"

@interface WJRecomendResume ()
@property (strong) UITextField *tf_name;
@property (strong) UITextField *tf_currentposition;
@property (strong) UITextField *tf_currentEnterprise;
@property (strong) UITextField *tf_workTime;
@property (strong) UITextField *tf_mobile;

@property (strong) IBOutlet HDTableView  *tbv;
@property (strong) IBOutlet UIView       *v_head;
@property (strong) IBOutlet UIView       *v_foot;
@property (strong) IBOutlet UIButton     *btn_recommend;
@property (strong) IBOutlet NSLayoutConstraint      *lc_tbvBottom;

- (IBAction)recommend:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *btn_select;
- (IBAction)select:(UIButton *)sender;

@end

@implementation WJRecomendResume

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_JJ_RECOMMEND_RESUME");
    self.tbv.backgroundColor = [UIColor colorWithRed:0.91f green:0.92f blue:0.92f alpha:1.00f];
    [self.btn_select setBackgroundImage:[UIImage imageNamed:@"iconRead"] forState:UIControlStateNormal];
    [self.btn_select setBackgroundImage:[UIImage imageNamed:@"iconReadHi"] forState:UIControlStateSelected];
}

- (void)viewWillLayoutSubviews{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 105);
    self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 90);
    [self.tbv setTableHeaderView:self.v_head];
    [self.tbv setTableFooterView:self.v_foot];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJRecommendResumeCell";
    WJRecommendResumeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [WJRecommendResumeCell getRecommendResumeCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *ary = [NSArray arrayWithObjects:@"人选姓名", @"目前职位", @"目前公司", @"工作年限", @"联系方式", nil];
    if (indexPath.row != 3) {
        cell.lc_workYearsWidth.constant = 0;
        cell.lb_workYears.text = nil;
    }
    [cell updateConstraints];
    cell.lb_title.text = ary[indexPath.row];
    cell.tf_content.tag = 100+indexPath.row;
    cell.tf_content.delegate = self;
    return cell;
}

#pragma mrak -- 
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)recommend:(UIButton *)sender {
    [self getHttpRequest];
}

- (void)getHttpRequest{
    self.tf_name                = (UITextField *)[self.view viewWithTag:100];
    self.tf_currentposition     = (UITextField *)[self.view viewWithTag:101];
    self.tf_currentEnterprise   = (UITextField *)[self.view viewWithTag:102];
    self.tf_workTime            = (UITextField *)[self.view viewWithTag:103];
    self.tf_mobile              = (UITextField *)[self.view viewWithTag:104];
    HDTalentInfo *info = [HDTalentInfo new];
    info.sHumanNo                = self.positionno? self.positionno: @"";
    info.sName                      = self.tf_name.text? self.tf_name.text: @"";
    info.sCurPosition               = self.tf_currentposition.text? self.tf_currentposition.text: @"";
    info.sCurCompanyName            = self.tf_currentEnterprise.text? self.tf_currentEnterprise.text: @"";
    info.sWorkYears                 = self.tf_workTime.text? self.tf_workTime.text: @"";
    info.sPhone                    = self.tf_mobile.text? self.tf_mobile.text: @"";
    info.sRemark                    = @"";
    info.sWorkYears = [HDWorkExpInfo getWorkYearTimeDifference:[info.sWorkYears integerValue]];
    if (info.sName.length == 0 || info.sCurPosition.length == 0 || info.sCurCompanyName.length == 0 || info.sWorkYears.length == 0 || info.sPhone.length == 0  ) {
        [HDUtility mbSay:@"参数不能为空"];
    }else{
        [[HDHttpUtility sharedClient] addPeopleAndRecommend:[HDGlobalInfo instance].userInfo talent:info completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage,NSDictionary *talents) {
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            WJEvaluateResumeCtr *evaluate = [[WJEvaluateResumeCtr alloc] init];
            evaluate.PersonalNo = [talents objectForKey:@"PersonalNo"];
            evaluate.RecommendID = [talents objectForKey:@"RecommendID"];
            [self.navigationController pushViewController:evaluate animated:YES];
        }];

    }

}

- (IBAction)select:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}
@end
