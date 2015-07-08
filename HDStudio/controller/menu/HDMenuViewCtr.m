//
//  SNMenuViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-2.
//  Copyright (c) 2014年 DennisHu. All rights reserved.
//

#import "HDMenuViewCtr.h"
#import "HDRecommendViewCtr.h"
#import "HDSettingViewCtr.h"
#import "HDProfileViewCtr.h"
#import "UIViewController+JDSideMenu.h"

@interface MenuCell : UITableViewCell

@property (strong) UIView *vHighlight;
@end

@implementation MenuCell

@end

@interface HDMenuViewCtr (){
    IBOutlet UIView         *v_head;
    IBOutlet UIButton       *btn_head;
    IBOutlet UILabel        *lb_shopName;
    IBOutlet NSLayoutConstraint *lc_tableTrailing;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HDMenuViewCtr

- (void)viewDidLoad
{
    [super viewDidLoad];
    lb_shopName.text                            = [HDGlobalInfo instance].userInfo.sShopName;
    btn_head.layer.cornerRadius                 = 33;
    btn_head.layer.masksToBounds                = YES;
    v_head.frame                                = CGRectMake(0, 0, HDDeviceSize.width, 150);
    self.tableView.tableHeaderView              = v_head;
    MenuCell *cell = (MenuCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.vHighlight.hidden  = NO;
}

- (void)viewWillLayoutSubviews{
    if (isRetina4_0 || isRetina3_5) {
        lc_tableTrailing.constant   = 60;
    }
    if (isRetina4_7) {
        lc_tableTrailing.constant   = 115;
    }
    if (isRetina5_5) {
        lc_tableTrailing.constant   = 150;
    }
    [self.view needsUpdateConstraints];
}
- (void)viewDidAppear:(BOOL)animated{
    NSString *sPathLogo = [HDGlobalInfo instance].shopInfo.sPathLogo;
    if (sPathLogo.length > 0) {
        [btn_head setImage:[UIImage imageWithContentsOfFile:sPathLogo] forState:UIControlStateNormal];
    }
}
- (IBAction)doShowProfile:(id)sender{
    [self.sideMenuController hideMenuAnimated:YES];
}

- (IBAction)doLogout:(id)sender{
    
    [self.sideMenuController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sideMenuController hideMenuAnimated:YES];
    for (int i = 0; i < 4; i++) {
        MenuCell *cell          = (MenuCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.vHighlight.hidden  = YES;
    }
    MenuCell *cell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.vHighlight.hidden  = NO;
    switch (indexPath.row) {
        case 0:{
//            HDMainViewCtr *ctr          = [HDMainViewCtr new];
//            ctr.navigationItem.title    = @"首页";
//            HDNavigationController *nav = [[HDNavigationController alloc] initWithRootViewController:ctr];
//            [self.sideMenuController setContentController:nav animated:YES];
            break;
        }
        case 1:{
//            HDPositionViewCtr *ctr      = [HDPositionViewCtr new];
//            ctr.navigationItem.title    = @"职位管理";
//            HDNavigationController *nav = [[HDNavigationController alloc] initWithRootViewController:ctr];
//            [self.sideMenuController setContentController:nav animated:YES];
            break;
        }
        case 2:{
            HDRecommendViewCtr *ctr     = [HDRecommendViewCtr new];
            ctr.navigationItem.title    = @"人选管理";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
            [self.sideMenuController setContentController:nav animated:YES];
            break;
        }
        case 3:{
            HDSettingViewCtr *ctr       = [HDSettingViewCtr new];
            ctr.navigationItem.title    = @"系统设置";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
            [self.sideMenuController setContentController:nav animated:YES];
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
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor                = [UIColor clearColor];
        cell.textLabel.textColor            = [UIColor whiteColor];
        cell.selectedBackgroundView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 110)];
        cell.selectionStyle                 = UITableViewCellSelectionStyleNone;
        cell.textLabel.font                 = [UIFont systemFontOfSize:20];
        cell.accessoryType                  = UITableViewCellAccessoryDisclosureIndicator;
        cell.vHighlight                     = [[UIView alloc] init];
        cell.vHighlight.frame               = CGRectMake(0, 0, CGRectGetWidth(cell.frame), 70);
        cell.vHighlight.backgroundColor     = HDCOLOR_RED;
        [cell addSubview:cell.vHighlight];
        [cell sendSubviewToBack:cell.vHighlight];
        cell.vHighlight.hidden              = YES;
    }
    if (indexPath.row % 2 == 1) {
        UIView *vBack                       = [[UIView alloc] init];
        vBack.frame                         = CGRectMake(0, 0, CGRectGetWidth(cell.frame), 70);
        vBack.backgroundColor               = [UIColor whiteColor];
        vBack.alpha                         = 0.04;
        [cell addSubview:vBack];
        [cell sendSubviewToBack:vBack];
    }
    cell.textLabel.text     = @[@"  首页", @"  职位管理", @"  人选管理", @"  系统设置"][indexPath.row];
    return cell;
}

@end
