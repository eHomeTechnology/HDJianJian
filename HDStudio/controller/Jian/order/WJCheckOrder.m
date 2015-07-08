//
//  WJCheckOrder.m
//  JianJian
//
//  Created by liudu on 15/4/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckOrder.h"
#import "WJCheckOrderCell.h"
#import "WJCheckEmployer.h"
#import "WJRecomendResume.h"
#import "HDMyTalentCtr.h"

@interface WJCheckOrder ()


@property (strong)                     WJPositionInfo  *OrderInfo;
@property (strong, nonatomic) IBOutlet UIView       *v_bottom;
@property (strong, nonatomic) IBOutlet UITableView  *tbv;
@property (strong, nonatomic) IBOutlet UIView       *v_foot;
@property (strong, nonatomic) IBOutlet UIButton     *btn_chat;
@property (strong, nonatomic) IBOutlet UILabel      *lb_name;
@property (strong, nonatomic) IBOutlet UIImageView  *img_head;
@property (strong, nonatomic) IBOutlet UIButton     *ben_addAttention;
@property (strong, nonatomic) IBOutlet UIButton     *btn_collect;
@property (strong, nonatomic) IBOutlet UIButton     *btn_share;
@property (strong, nonatomic) IBOutlet UIButton     *btn_recommend;

@end

@implementation WJCheckOrder



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title       = LS(@"TXT_JJ_ORDER_CHECK");
    self.v_bottom.frame             = CGRectMake(0, HDDeviceSize.height-113, HDDeviceSize.width,49);
    self.tbv.frame                  = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height-113);
    self.tbv.separatorStyle         = UITableViewRowAnimationNone;
    [self getHttpRequest];
}

- (void)getHttpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo pid:self.positionID completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _OrderInfo = (WJPositionInfo *)info;
        [self.tbv reloadData];
    }];
}

#pragma mark - 
#pragma mark UITableView Datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section== 0) {
        return 120;
    }else{
        if (_OrderInfo.sRemark.length == 0) {
            return 50;
        }else{
            UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.textLabel.frame.size.height+40;
        }
    }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        UIView *v_name = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 30)];
        v_name.backgroundColor = [UIColor whiteColor];
      
        UILabel *lb_name = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, HDDeviceSize.width, 20)];
        lb_name.text = _OrderInfo.sPositionName;
        [v_name addSubview:lb_name];
        return v_name;
    }
    UIView *v_position = [[UIView alloc] initWithFrame:CGRectMake(0, 30, HDDeviceSize.width, 60)];
    v_position.backgroundColor = [UIColor whiteColor];
    
    UIView *v_gray = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    v_gray.backgroundColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
    [v_position addSubview:v_gray];
  
    UIView *v_line = [[UIView alloc]initWithFrame:CGRectMake(10, 59, HDDeviceSize.width-20, 0.5)];
    v_line.backgroundColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
    [v_position addSubview:v_line];
    
    UILabel *lb_position = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, HDDeviceSize.width-20, 30)];
    lb_position.text = @"职位描述";
    [v_position addSubview:lb_position];
    return v_position;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 40);
        if (_OrderInfo.brokerInfo.sName.length == 0) {
            self.img_head.hidden = YES;
        }else{
            self.img_head.hidden = NO;
        }
        self.lb_name.text = _OrderInfo.brokerInfo.sName;
        return self.v_foot;
    }else{
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 1)];
        v.backgroundColor = [UIColor colorWithRed:0.94f green:0.94f blue:0.96f alpha:1.00f];
        return v;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }else{
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 40;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString *cellIdentifer = @"WJCheckOrderCell";
        WJCheckOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if (cell == nil) {
            cell = [self getCheckCell];
        }
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.btn_company addTarget:self action:@selector(companyOnClick) forControlEvents:UIControlEventTouchUpInside];
        [cell getChechOrderData:_OrderInfo];
        return cell;
    }
    
    static NSString *cellIdentifer = @"WJOrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect rect = [_OrderInfo.sRemark boundingRectWithSize:CGSizeMake(HDDeviceSize.width, 1200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FONTNAME_HelveticaNeueMedium(15)} context:nil];
    [cell.textLabel setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    cell.textLabel.text = _OrderInfo.sRemark;
    cell.textLabel.font = FONTNAME_HelveticaNeueMedium(15);
    cell.textLabel.numberOfLines = 0;
  
    return cell;
    
}

- (WJCheckOrderCell *)getCheckCell{
    WJCheckOrderCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJCheckOrderCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJCheckOrderCell class]]) {
            cell = (WJCheckOrderCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)companyOnClick{
    WJCheckEmployer *employer = [[WJCheckEmployer alloc] initWithInfo:_OrderInfo];
    [self.navigationController pushViewController:employer animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)chat:(UIButton *)sender {
    NSLog(@"聊聊");
}
- (IBAction)addAttention:(UIButton *)sender {
     NSLog(@"加关注");
}
- (IBAction)collect:(UIButton *)sender {
}
- (IBAction)share:(UIButton *)sender {
}
- (IBAction)recommend:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"新增人选" otherButtonTitles:@"我的人才库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;//透明色
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        WJRecomendResume *recomend = [[WJRecomendResume alloc] init];
        recomend.positionno = _OrderInfo.sPositionNo;
        [self.navigationController pushViewController:recomend animated:YES];
        
    }else if (buttonIndex == 1){
        [self.navigationController pushViewController:[HDMyTalentCtr new] animated:YES];
    }else{
        NSLog(@"取消");
    }
}
@end
