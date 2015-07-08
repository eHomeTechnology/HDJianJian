//
//  HDJFriendDetailCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDJFriendDetailCtr.h"
#import "HDJJFriendsCtr.h"

@implementation HDJFDetailCell

- (void)awakeFromNib{
    
    _btn_progress.layer.cornerRadius    = 18;
    _btn_progress.layer.masksToBounds   = YES;
}

@end

@interface HDJFriendDetailCtr ()<UIActionSheetDelegate>{

    NSMutableArray          *mar_feedback;
}

@property (strong) HDJFriendInfo            *JJFriendInfo;
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) IBOutlet UIView          *v_section0;
@property (strong) IBOutlet UIView          *v_section1;
@end

@implementation HDJFriendDetailCtr

- (id)initWithJFriendInfo:(HDJFriendInfo *)info{

    if (self = [super init]) {
        _JJFriendInfo = info;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_JJ_FRIEND_DETAIL");
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    [self.tbv setTableHeaderView:v];
    mar_feedback = [HDGlobalInfo instance].mar_feedback;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)progressAction:(UIButton *)sender{
    UIActionSheet *as   = [[UIActionSheet alloc] init];
    as.delegate         = self;
    [as addButtonWithTitle:LS(@"TXT_CANCEL")];
    for (int i = 1; i < mar_feedback.count; i++) {
        [as addButtonWithTitle:mar_feedback[i][@"Value"]];
    }
    [as showInView:kWindow];
}
- (void)cellAction:(UIButton *)sender{
    if (sender.tag > 1) {
        Dlog(@"传入参数错误");
        return;
    }
    NSString *sPhone = @[_JJFriendInfo.sRMPhone, _JJFriendInfo.sPMPhone][sender.tag];
    UIAlertView *alert = [HDUtility say2:FORMAT(@"%@%@%@", LS(@"TXT_ARE_U_SURE_DIALING"), sPhone, @"?") Delegate:self];
    alert.tag = sender.tag;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    Dlog(@"buttonIndex = %d, %d", (int)buttonIndex, (int)alertView.tag);
    if (buttonIndex != 1) {
        return;
    }
    NSString *sPhone = @[_JJFriendInfo.sRMPhone, _JJFriendInfo.sPMPhone][alertView.tag];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORMAT(@"tel://%@", sPhone)]];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 55.;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return _v_section0;
    }
    if (section == 1) {
        return _v_section1;
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 131;
    }
    return 202;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"HDJJFriendCell";
        HDJJFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [self getJJFriendCell:indexPath.section];
            cell.lb_time.text = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.btn_dialing.tag    = indexPath.section;
        cell.lb_name.text       = _JJFriendInfo.sRName;
        cell.lb_company.text    = _JJFriendInfo.sRCompany;
        cell.lb_position.text   = _JJFriendInfo.sRPosition;
        cell.lb_phone.text      = _JJFriendInfo.sRMPhone;
        [cell.btn_dialing addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"HDJFDetailCell";
        HDJFDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [self getJFDetailCell:indexPath.section];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_name.text       = _JJFriendInfo.sPName;
        cell.lb_rPosition.text  = _JJFriendInfo.sPositionName;
        cell.lb_cCompany.text   = _JJFriendInfo.sPCompany;
        cell.lb_cPosition.text  = _JJFriendInfo.sPPosition;
        cell.lb_workYear.text   = _JJFriendInfo.sWorkYears;
        cell.lb_mPhone.text     = _JJFriendInfo.sPMPhone;
        cell.lb_eCount.text     = _JJFriendInfo.sMatchCount;
        cell.lb_createTime.text = _JJFriendInfo.sCreatedDt;
        cell.btn_dialing.tag    = indexPath.section;
        [cell.btn_dialing addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_progress addTarget:self action:@selector(progressAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    return nil;
}

- (HDJJFriendCell *)getJJFriendCell:(NSInteger)section{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDJJFriendCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJJFriendCell class]]) {
            return (HDJJFriendCell *)obj;
        }
    }
    return nil;
}
- (HDJFDetailCell *)getJFDetailCell:(NSInteger)section{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDJFDetailCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJFDetailCell class]]) {
            return (HDJFDetailCell *)obj;
        }
    }
    return nil;
}

#pragma mark -
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    Dlog(@"buttonIndex = %d", (int)buttonIndex);
    if (buttonIndex == 0) {
        return;
    }
    [[HDHttpUtility sharedClient] setFeedbackType:[HDGlobalInfo instance].userInfo recommendId:_JJFriendInfo.sRecommendID feedbackType:(int)buttonIndex completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        HDJFDetailCell *cell = (HDJFDetailCell *)[self.tbv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [cell.btn_progress setTitle:mar_feedback[buttonIndex][@"Value"] forState:UIControlStateNormal];
    }];
}
@end
