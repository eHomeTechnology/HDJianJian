//
//  HDAcountViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyJianJianCtr.h"
#import "HDTableView.h"
#import "HDProfileViewCtr.h"
#import "HDChangePwdCtr.h"
#import "HDApproveViewCtr.h"

@interface HDMyJianJianCtr (){

    IBOutlet HDTableView *tbv;
}

@end

@implementation HDMyJianJianCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:{
            [self.navigationController pushViewController:[HDProfileViewCtr new] animated:YES];
            break;
        }
        case 1:{
            [self.navigationController pushViewController:[HDApproveViewCtr new] animated:YES];
            break;
        }
        case 2:{
            [self.navigationController pushViewController:[HDChangePwdCtr new] animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HDSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @[LS(@"账户管理"), LS(@"我的认证"), LS(@"账户安全")][indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark Event and Response

#pragma mark -
#pragma mark setter and getter
- (void)setup{
    self.navigationItem.title = LS(@"HD_TITLE_MY_JIANJIAN");
}


@end
