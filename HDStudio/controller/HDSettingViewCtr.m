//
//  HDPhotoViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDSettingViewCtr.h"
#import "HDChangePwdCtr.h"
#import "HDFeedbackCtr.h"
#import "HDAboutUsCtr.h"
#import "HDTableView.h"
#import "TOWebViewController.h"
#import "HDNewsViewCtr.h"

@interface HDSettingViewCtr (){

    IBOutlet UIView *v_footer;
    NSDictionary *dic_versionInfo;
}

@property (strong) IBOutlet UITableView *tbv;

@end

@implementation HDSettingViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableViewHead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews{

}

- (void)setTableViewHead{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tbv setTableHeaderView:v];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:{
            [self.navigationController pushViewController:[HDAboutUsCtr new] animated:YES];
            break;
        }
        case 1:{
            HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
            [[HDHttpUtility sharedClient] updateVersion:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSDictionary *dic) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                if (dic) {
                    [HDUtility say2:FORMAT(@"发现新的版本：%@,\n前往下载？", dic[@"VersionName"]) Delegate:self];
                    dic_versionInfo = dic;
                }else{
                    [HDUtility mbSay:@"您当前为最新系统!"];
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableViewDatasource
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HDSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = @[LS(@"TXT_ME_ABOUT_US"), LS(@"TXT_ME_CHECK_FOR_IPDATE")][indexPath.row];
    return cell;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:dic_versionInfo[@"Url"]];
    if (!url) {
        
        return;
    }
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - 
#pragma mark Event and Response

- (IBAction)doLogout:(UIButton *)sender{
    [HDGlobalInfo instance].userInfo = nil;
    [HDGlobalInfo instance].hasLogined = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:LOGIN_PWD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    EMError *error = nil;
    [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:&error];
    if (error) {
        Dlog(@"警告：环信注销失败，%@", error.description);
    }
    UITabBarController *tab = (UITabBarController *)kWindow.rootViewController;
    if (tab.viewControllers.count > 4) {
        UINavigationController *nav = tab.viewControllers[3];
        if (nav.viewControllers.count > 0) {
            HDNewsViewCtr *newsCtr = nav.viewControllers[0];
            [newsCtr.mar_subscribers removeAllObjects];
            [newsCtr.tbv reloadData];
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController.tabBarController setSelectedIndex:0];
}

#pragma mark - 
#pragma mark - Setter and getter

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_FEEDBACK");
    v_footer.frame = CGRectMake(0, 0, HDDeviceSize.width, 55);
    self.tbv.tableFooterView = v_footer;
}

@end
