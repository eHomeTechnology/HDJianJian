//
//  HDAddTalentCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAddTalentCtr.h"
#import "HDTalentViewCtr.h"
#import "HDFromEmailCtr.h"
#import "HDFromInternetCtr.h"
#import "HDFromLocalCtr.h"


@interface HDAddTalentCtr ()

@property (strong) IBOutlet UITableView *tbv;

@end


@implementation HDAddTalentCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_TITLE_ADD_TALENT");
    [self setTableViewHead];
}
- (void)setTableViewHead{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tbv setTableHeaderView:v];
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
            HDTalentViewCtr *ctr = [HDTalentViewCtr new];
            ctr.navigationItem.title    = LS(@"TXT_JJ_MANUAL_ADD_TALENT");
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 1:{
            [self.navigationController pushViewController:[HDFromEmailCtr new] animated:YES];
            break;
        }
        case 2:{
            [self.navigationController pushViewController:[HDFromInternetCtr new] animated:YES];
            break;
        }
        case 3:{
            [self.navigationController pushViewController:[HDFromLocalCtr new] animated:YES];
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
    return 60;
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
    static NSString *cellIdentifier = @"standerd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text     = @[LS(@"TXT_JJ_MANUAL_ENTER"), LS(@"TXT_JJ_FROM_EMAIL"), LS(@"TXT_JJ_FROM_INTERNET"), LS(@"TXT_JJ_FROM_COMPUTER")][indexPath.row];
    cell.imageView.image    = @[HDIMAGE(@"icon_shougong"), HDIMAGE(@"icon_youxiang"), HDIMAGE(@"icon_daoru"), HDIMAGE(@"icon_diannao")][indexPath.row];
    
    return cell;
}

@end
