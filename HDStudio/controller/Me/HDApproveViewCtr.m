//
//  HDApproveViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDApproveViewCtr.h"
#import "HDTableView.h"
#import "HDApproveCell.h"
#import "HDAskForApproveCtr.h"

@implementation HDApproveInfo

@end

@interface HDApproveViewCtr (){
    NSMutableArray *mar_approveInfos;
    BOOL isLastPage;
}

@property (strong) IBOutlet HDTableView *tbv;

@end

@implementation HDApproveViewCtr

#pragma mark -
#pragma mark life cycel
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightBarbuttonItem];
    [self httpGetMyApprove];
}

- (void)viewDidAppear:(BOOL)animated{
    [self httpGetMyApprove];
}

- (void)viewWillAppear:(BOOL)animated{
    Dlog(@"----");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return section == 1? 30: 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, HDDeviceSize.width-40, 20)];
    lb.textAlignment    = NSTextAlignmentCenter;
    lb.textColor        = HDCOLOR_RED;
    lb.text             = @"在此展示您的专长和职业阅历，吸引雇主并获得信赖";
    lb.font             = [UIFont systemFontOfSize:14];
    lb.adjustsFontSizeToFitWidth = YES;
    return lb;
}
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HDApproveInfo *info = mar_approveInfos[indexPath.row];
    if (info.sRemark.length > 0 && info.approveStatus == HDApproveStatusNotPassed) {
        return 100;
    }
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return mar_approveInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"approveCell";
    HDApproveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDApproveCell getCell];
    }
    cell.approveInfo = mar_approveInfos[indexPath.row];
    return cell;
}

#pragma mark - 
#pragma mark Private method

- (void)httpGetMyApprove{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getMyApproveInformation:[HDGlobalInfo instance].userInfo pageIndex:0 size:24 completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *array) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        mar_approveInfos = [[NSMutableArray alloc] initWithArray:array];
        self.tbv.hidden = mar_approveInfos.count == 0;
        [self.tbv reloadData];
    }];
    
}

#pragma mark -
#pragma mark Event && Response
- (IBAction)doAskForApprove:(UIButton *)sender{
    [self.navigationController pushViewController:[HDAskForApproveCtr new] animated:YES];
}

#pragma mark -
#pragma mark getter and setter

- (void)setup{
    mar_approveInfos    = [NSMutableArray new];
    isLastPage          = YES;
    self.navigationItem.title = @"我的认证";
}

- (void)setRightBarbuttonItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 70, 25);
    [btn setTitle:@"申请认证" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn addTarget:self action:@selector(doAskForApprove:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius  = 12.;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor   = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth   = 1.0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end





