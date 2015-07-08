//
//  HDJianViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDJianViewCtr.h"
#import "HDJianCell.h"
#import "HDMyPositionCtr.h"
#import "HDAddTalentCtr.h"
#import "HDMyTalentCtr.h"
#import "HDFindBrokerCtr.h"
#import "HDServerCenterCtr.h"
#import "HDSearchOrderCtr.h"
#import "HDMyOrderCtr.h"
#import "HDNewPositionCtr.h"


@interface HDJianViewCtr (){
    UIImage *img_head;
    
}
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) NSMutableArray *mar_section1;    //我需要人才title
@property (strong) NSMutableArray *mar_section2;    //我推荐人才title
@property (strong) NSMutableArray *mar_section3;    //我的人才title

@end

@implementation HDJianViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setImageHead];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup{
    self.navigationItem.title   = LS(@"TXT_TITLE_JIAN");
}

- (void)setImageHead{
    [HDJJUtility getImage:[HDGlobalInfo instance].userInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        if ([code intValue] == 0) {
            img_head = img;
        }else{
            img_head = HDIMAGE(@"icon_headFalse");
        }
        [self.tbv reloadData];
    }];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:{//贱友圈
            //[self.navigationController pushViewController:[HDJFriendCircleCtr new] animated:YES];
            break;
        }
        case 1:{//我需要人才
            switch (indexPath.row) {
                case 0:{
                    if (self.mar_section1.count == 0) {
                        self.mar_section1 = [[NSMutableArray alloc] init];
                        NSArray *ar_icon = @[HDIMAGE(@"subIcon_releasePosition"), HDIMAGE(@"subIcon_myPosition"), HDIMAGE(@"subIcon_searchForJFriend")];
                        NSArray *ar_title = @[LS(@"TXT_JJ_FABU_ZHIWEI"), LS(@"TXT_JJ_WODE_ZHIWEI"), LS(@"TXT_JJ_ZHAO_RENCAI_JINGJIREN")];
                        for (int i = 0; i < ar_title.count; i++) {
                            NSMutableDictionary *mdc = [[NSMutableDictionary alloc] init];
                            [mdc setObject:ar_icon[i] forKey:@"icon"];
                            [mdc setObject:ar_title[i] forKey:@"title"];
                            [self.mar_section1 addObject:mdc];
                        }
                    }else{
                        [self.mar_section1 removeAllObjects];
                    }
                    [self.tbv reloadData];
                    break;
                }
                case 1:{//发布职位
                    HDNewPositionCtr *ctr = [[HDNewPositionCtr alloc] init];
                    [self.navigationController pushViewController:ctr animated:YES];
                    break;
                }
                case 2:{//我的职位
                    HDMyPositionCtr *position       = [[HDMyPositionCtr alloc] initWithObject:self];
                    [self.navigationController pushViewController:position animated:YES];
                    break;
                }
                case 3:{//找荐客
                    [self.navigationController pushViewController:[HDFindBrokerCtr new] animated:YES];
                   
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2:{//我推荐人才
            switch (indexPath.row) {
                case 0:{
                    if (self.mar_section2.count == 0) {
                        self.mar_section2 = [[NSMutableArray alloc] init];
                        NSArray *ar_icon = @[HDIMAGE(@"subIcon_searchForOrder"), HDIMAGE(@"subIcon_myOrder")];
                        NSArray *ar_title = @[LS(@"TXT_JJ_ZHAO_DINGDAN"), LS(@"TXT_JJ_WODE_DINGDAN")];
                        for (int i = 0; i < ar_title.count; i++) {
                            NSMutableDictionary *mdc = [[NSMutableDictionary alloc] init];
                            [mdc setObject:ar_icon[i] forKey:@"icon"];
                            [mdc setObject:ar_title[i] forKey:@"title"];
                            [self.mar_section2 addObject:mdc];
                        }
                    }else{
                        [self.mar_section2 removeAllObjects];
                    }
                    [self.tbv reloadData];
                    break;
                }
                case 1:{//找订单
                    [self.navigationController pushViewController:[HDSearchOrderCtr new] animated:YES];
                    break;
                }
                case 2:{//我的订单
                    [self.navigationController pushViewController:[HDMyOrderCtr new] animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3:{//我的人才
            switch (indexPath.row) {
                case 0:{
                    if (self.mar_section3.count == 0) {
                        self.mar_section3   = [[NSMutableArray alloc] init];
                        NSArray *ar_icon    = @[HDIMAGE(@"subIcon_newTalent"), HDIMAGE(@"subIcon_myTalent")];
                        NSArray *ar_title   = @[LS(@"TXT_JJ_XINZEN_RENCAI"), LS(@"TXT_JJ_WODE_RENCAIKU")];
                        for (int i = 0; i < ar_title.count; i++) {
                            NSMutableDictionary *mdc = [[NSMutableDictionary alloc] init];
                            [mdc setObject:ar_icon[i] forKey:@"icon"];
                            [mdc setObject:ar_title[i] forKey:@"title"];
                            [self.mar_section3 addObject:mdc];
                        }
                    }else{
                        [self.mar_section3 removeAllObjects];
                    }
                    [self.tbv reloadData];
                    break;
                }
                case 1:{//新增人才
                    [self.navigationController pushViewController:[HDAddTalentCtr new] animated:YES];
                    break;
                }
                case 2:{//我的人才库
                    [self.navigationController pushViewController:[HDMyTalentCtr new] animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 4:{
            [self.navigationController pushViewController:[HDServerCenterCtr new] animated:YES];
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
    if (indexPath.row > 0) {
        return 45;
    }
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 1) {
        return self.mar_section1.count + 1;
    }
    if (sectionIndex == 2) {
        return self.mar_section2.count + 1;
    }
    if (sectionIndex == 3) {
        return self.mar_section3.count + 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"jian";
    HDJianCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self getJianCell];
    }
    cell.imv_value.hidden   = YES;
    cell.v_redDot.hidden    = YES;
    cell.lb_title.font      = [UIFont systemFontOfSize:17];
    cell.accessoryType      = UITableViewCellAccessoryNone;
    cell.lb_title.text      = @[LS(@"TXT_JJ_JIAN_YOU_QUAN"), LS(@"TXT_JJ_WO_XUYAO_RENCAI"), LS(@"TXT_JJ_WO_TUIJIAN_RENCAI"), LS(@"TXT_JJ_WODE_RENCAI"), LS(@"TXT_JJ_FUWU_ZHONGXIN")][indexPath.section];
    cell.imv_head.image     = @[HDIMAGE(@"icon_newFriend"), HDIMAGE(@"icon_jianyou"), HDIMAGE(@"icon_rencai"), HDIMAGE(@"icon_hangyequnzu"), HDIMAGE(@"icon_shoujilianxiren")][indexPath.section];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.imv_value.hidden   = NO;
        cell.v_redDot.hidden    = NO;
        cell.imv_value.image    = img_head;
    }
    if (indexPath.section == 1 && indexPath.row > 0) {
        NSDictionary *dic = self.mar_section1[indexPath.row - 1];
        cell.imv_head.image     = dic[@"icon"];
        cell.lb_title.text      = dic[@"title"];
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 2 && indexPath.row > 0) {
        NSDictionary *dic = self.mar_section2[indexPath.row - 1];
        cell.imv_head.image     = dic[@"icon"];
        cell.lb_title.text      = dic[@"title"];
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 3 && indexPath.row > 0) {
        NSDictionary *dic = self.mar_section3[indexPath.row - 1];
        cell.imv_head.image     = dic[@"icon"];
        cell.lb_title.text      = dic[@"title"];
        cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row > 0) {
        cell.lb_title.font      = [UIFont systemFontOfSize:15];
    }
    return cell;
}

- (HDJianCell *)getJianCell{
    HDJianCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDJianCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJianCell class]]) {
            cell = (HDJianCell *)obj;
            break;
        }
    }
    return cell;
}
@end
