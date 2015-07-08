//
//  HDEmployeeListCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/5.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDEmployerListCtr.h"
#import "HDHttpUtility.h"
#import "HDTableView.h"
#import "HDNewPositionCell.h"

@interface HDEmployerListCtr (){

    
}
@property (strong) IBOutlet UIView          *v_head;
@property (strong) IBOutlet HDTableView     *tbv;
@property (strong) AFHTTPRequestOperation   *op;
@property (strong) NSMutableArray           *mar_employees;

@end

@implementation HDEmployerListCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetEmployeeList:^(NSArray *ar, BOOL isLast) {
        _mar_employees = [[NSMutableArray alloc] initWithArray:ar];
        [_tbv reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setup{
    _mar_employees = [NSMutableArray new];
    self.navigationItem.title = LS(@"选择雇主");
    _v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 90);
    [_tbv setTableFooterView:_v_head];
}

- (void)httpGetEmployeeList:(void (^)(NSArray *ar, BOOL isLast))block{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility sharedClient] getEmployeeInfoList:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSMutableArray *mar, BOOL isLastPage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(nil, NO);
            return ;
        }
        block(mar, isLastPage);
    }];
    
}

- (IBAction)doAddEmployee:(id)sender{
    
    
}

- (void)doChoose:(UIButton *)sender{
    HDEmployerInfo *info = _mar_employees[sender.tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(employerListChooseEmployee:)]) {
        [self.delegate employerListChooseEmployee:info];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIButton *btn = [UIButton new];
    btn.tag = indexPath.row;
    [self doChoose:btn];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 40;
    }
    return 0;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"请选择已保存过的雇主信息";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _mar_employees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HDEmployeeListCell";
    HDEmployeeListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDEmployeeListCell getEmployeeCell];
    }
    HDEmployerInfo *info    = _mar_employees[indexPath.row];
    cell.employerInfo       = info;
    cell.btn_choose.tag     = indexPath.row;
    [cell.btn_choose addTarget:self action:@selector(doChoose:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end
