//
//  WJRecommendInformation.m
//  JianJian
//
//  Created by liudu on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJRecommenInfoCtr.h"
#import "WJRecommendResumeCell.h"
#import "WJRecommendSucCtr.h"

@interface WJRecommenInfoCtr ()

@property (strong, nonatomic) IBOutlet UITableView *tbv;
@property (strong, nonatomic) IBOutlet UIView *v_head;
@property (strong, nonatomic) IBOutlet UIView *v_foot;

@property (strong) UITextField *tf_name;
@property (strong) UITextField *tf_currentposition;
@property (strong) UITextField *tf_currentEnterprise;
@property (strong) UITextField *tf_mobile;

@property (strong, nonatomic) IBOutlet UIButton *btn_recommendInfo;
- (IBAction)recommendInfo:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *btn_leifeng;
- (IBAction)leifeng:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *confirm;
- (IBAction)comfirm:(UIButton *)sender;
@end

@implementation WJRecommenInfoCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_JJ_RECOMMEND_INFORMATION");
    self.tbv.backgroundColor = [UIColor colorWithRed:0.91f green:0.92f blue:0.92f alpha:1.00f];
    self.btn_recommendInfo.selected = YES;
}

- (void)viewWillLayoutSubviews{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 140);
    self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 105);
    [self.tbv setTableHeaderView:self.v_head];
    [self.tbv setTableFooterView:self.v_foot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.btn_leifeng.selected == YES) {
        return 0;
    }
    return 4;
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
        cell = [self getRecommendResumeCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSArray *ary = [NSArray arrayWithObjects:@"您的姓名",@"目前职位",@"目前公司",@"联系方式", nil];
    cell.lb_title.text = ary[indexPath.row];
    cell.tf_content.tag = 100+indexPath.row;
    cell.lc_workYearsWidth.constant = 0;
    cell.lb_workYears.text = nil;
    [cell updateConstraints];
    return cell;

}
- (WJRecommendResumeCell *)getRecommendResumeCell{
    WJRecommendResumeCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJRecommendResumeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJRecommendResumeCell class]]) {
            cell = (WJRecommendResumeCell *)obj;
            break;
        }
    }
    return cell;
}


- (IBAction)recommendInfo:(UIButton *)sender {
    sender.selected = YES;
    self.btn_leifeng.selected = NO;
    [self.tbv reloadData];
}
- (IBAction)leifeng:(UIButton *)sender {
    sender.selected = YES;
    self.btn_recommendInfo.selected = NO;
    [self.tbv reloadData];
}

- (IBAction)comfirm:(UIButton *)sender {
    self.tf_name = (UITextField *)[self.view viewWithTag:100];
    self.tf_currentposition = (UITextField *)[self.view viewWithTag:101];
    self.tf_currentEnterprise = (UITextField *)[self.view viewWithTag:102];
    self.tf_mobile = (UITextField *)[self.view viewWithTag:103];
    WJSaveRecommendInfo *info = [WJSaveRecommendInfo new];
    info.personalno         = self.personalno? self.personalno: @"";
    info.matchid            = self.matchid? self.matchid: @"";
    info.recommendId        = self.recommendid? self.recommendid: @"";
    info.name               = self.tf_name.text? self.tf_name.text: @"";
    info.currentposition    = self.tf_currentposition.text? self.tf_currentposition.text: @"";
    info.currentEnterprise  = self.tf_currentEnterprise.text? self.tf_currentEnterprise.text: @"";
    info.mobile             = self.tf_mobile.text? self.tf_mobile.text: @"";
    if (self.btn_recommendInfo.selected == YES) {
        info.ishide = @"false";
    }else{
        info.name               = @"";
        info.currentposition    = @"";
        info.currentEnterprise  = @"";
        info.mobile             = @"";
        info.ishide = @"true";
    }
    [[HDHttpUtility sharedClient] saveRecommendPeople:[HDGlobalInfo instance].userInfo recommend:info completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [self.navigationController pushViewController:[WJRecommendSucCtr new] animated:YES];
    }];
}
@end
