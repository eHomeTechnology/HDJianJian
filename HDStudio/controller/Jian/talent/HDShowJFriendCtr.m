//
//  HDShowJFriendCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDShowJFriendCtr.h"
#import "HDHttpUtility.h"

@interface HDShowJFriendCtr (){
    
    IBOutlet UIView         *v_detail;
    
    IBOutlet UILabel        *lb_refereeName;
    IBOutlet UILabel        *lb_refereeCurCompany;
    IBOutlet UILabel        *lb_refereeCurPosition;
    IBOutlet UILabel        *lb_refereeMPhone;
    IBOutlet UILabel        *lb_createTime;
    IBOutlet UITextView     *tv_remark;
    
    IBOutlet UIImageView    *imv_00;
    IBOutlet UIImageView    *imv_01;
    IBOutlet UIImageView    *imv_02;
    IBOutlet UIImageView    *imv_03;
    IBOutlet UIImageView    *imv_04;
    
    IBOutlet UIImageView    *imv_10;
    IBOutlet UIImageView    *imv_11;
    IBOutlet UIImageView    *imv_12;
    IBOutlet UIImageView    *imv_13;
    IBOutlet UIImageView    *imv_14;
    
    IBOutlet UIImageView    *imv_20;
    IBOutlet UIImageView    *imv_21;
    IBOutlet UIImageView    *imv_22;
    IBOutlet UIImageView    *imv_23;
    IBOutlet UIImageView    *imv_24;
    
    IBOutlet UIImageView    *imv_30;
    IBOutlet UIImageView    *imv_31;
    IBOutlet UIImageView    *imv_32;
    IBOutlet UIImageView    *imv_33;
    IBOutlet UIImageView    *imv_34;
    
    IBOutlet UIImageView    *imv_40;
    IBOutlet UIImageView    *imv_41;
    IBOutlet UIImageView    *imv_42;
    IBOutlet UIImageView    *imv_43;
    IBOutlet UIImageView    *imv_44;

}
@property (strong) IBOutlet UITableView      *tbv;
@property (strong) HDRecommendInfo  *recommendInfo;
@property (strong) HDEvaluateInfo   *evaluateInfo;
@end

@implementation HDShowJFriendCtr

- (id)initWithInfo:(HDRecommendInfo *)info{

    if (self = [super init]) {
        
        self.recommendInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_TITLE_JFRIEND_EVALUATE");
    [self setTableView];
    [self setUserInterfaceWithData];
}
- (void)setTableView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tbv setTableHeaderView:v];
}

- (void)setUserInterfaceWithData{
    lb_refereeName.text         = _recommendInfo.sRefereeName;
    lb_refereeCurCompany.text   = _recommendInfo.sRefereeCompanyName;
    lb_refereeCurPosition.text  = _recommendInfo.sRefereePosition;
    lb_refereeMPhone.text       = _recommendInfo.sRefereeMPhone;
    if (!self.evaluateInfo) {
        HDHUD *hud = [HDHUD showLoading:@"更新数据..." on:self.navigationController.view];
        [[HDHttpUtility sharedClient] getEvaluateInfomation:_recommendInfo.sRecommendId user:[HDGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDEvaluateInfo *info) {
            [hud hiden];
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
            }
            self.evaluateInfo   = info;
            [self refreshRecommedView:info];
        }];
    }else{
        [self refreshRecommedView:self.evaluateInfo];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshRecommedView:(HDEvaluateInfo *)info{
    
    tv_remark.font      = [UIFont systemFontOfSize:17];
    tv_remark.text      = info.sRemark;
    lb_createTime.text  = info.sCreateTime;
    [self lightStar:@[imv_00, imv_01, imv_02, imv_03, imv_04] value:[info.sMatchPoint1 intValue]];
    [self lightStar:@[imv_10, imv_11, imv_12, imv_13, imv_14] value:[info.sMatchPoint2 intValue]];
    [self lightStar:@[imv_20, imv_21, imv_22, imv_23, imv_24] value:[info.sMatchPoint3 intValue]];
    [self lightStar:@[imv_30, imv_31, imv_32, imv_33, imv_34] value:[info.sMatchPoint4 intValue]];
    [self lightStar:@[imv_40, imv_41, imv_42, imv_43, imv_44] value:[info.sMatchPoint5 intValue]];
}

- (void)lightStar:(NSArray *)ar_stars value:(int)value{
    if (ar_stars.count != 5 || value > 5 || value < 0) {
        Dlog(@"Error:传入参数错误");
        return;
    }
    for (int i = 0; i < value; i++) {
        if (![ar_stars[i] isKindOfClass:[UIImageView class]]) {
            Dlog(@"Error:传入参数有误");
            break;
        }
        UIImageView *imv = ar_stars[i];
        [imv setImage:HDIMAGE(@"icon_starHi")];
    }
    
}


#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark -
#pragma mark UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 560;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell.contentView addSubview:v_detail];
    NSDictionary *dict1                 = NSDictionaryOfVariableBindings(v_detail);
    [v_detail setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"|-8-[v_detail]-8-|")
                                                                 options:0
                                                                 metrics:nil
                                                                   views:dict1]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v_detail]-8-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:dict1]];
    return cell;
}


@end
