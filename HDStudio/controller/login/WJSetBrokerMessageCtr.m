//
//  WJSetBrokerMessageCtr.m
//  JianJian
//
//  Created by liudu on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSetBrokerMessageCtr.h"
#import "WJBrokerMessageCell.h"
#import "HDExtendListCtr.h"
#import "HDBlogViewCtr.h"
#import "LDCry.h"
#import "BaseFunc.h"
#import "HDTableView.h"

@interface WJSetBrokerMessageCtr ()<HDExtendListDelegate>

@property (strong) IBOutlet HDTableView *tbv;
@property (strong) IBOutlet UIView      *v_head1;
@property (strong) IBOutlet UIView      *v_foot;
@property (strong) NSMutableArray       *mar_values;
@property (strong) IBOutlet NSLayoutConstraint   *lc_tbvBottom;
@property (assign) BOOL     isThirdRegister;
@property (strong) NSString *sRemark;
//职位地区行业选择
@property (nonatomic,strong)NSString * sAreaKey;
@property (nonatomic,strong)NSString * sTradeKey;
@property (nonatomic,strong)NSString * sPostKey;
@property (nonatomic,strong)NSString * sAreaName;
@property (nonatomic,strong)NSString * sTradeName;
@property (nonatomic,strong)NSString * sPostName;
/**
 *  当前职位
 */
@property (nonatomic,strong)NSString * nowPost;
/**
 *  当前公司
 */
@property (nonatomic,strong) NSString * nowCompany;

@end

@implementation WJSetBrokerMessageCtr

- (id)initWithIsThirdRegister:(BOOL)isRegister{
    self = [super init];
    if (self) {
        _isThirdRegister = isRegister;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_SET_BROKER_MESSAGE");
    _mar_values = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    [self scrollBottom];
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view updateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view updateConstraints];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 3) {
        return 80;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.01)];
        return v;
    }
    return self.v_head1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.01)];
        return v;
    }
    return self.v_foot;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
            
                }
                    break;
                case 1:{
                
                }
                    break;
                case 2:{
                    HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    [self.navigationController pushViewController:ctr animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{
                    HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    [self.navigationController pushViewController:ctr animated:YES];
                }
                    break;
                case 1:{
                    HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    [self.navigationController pushViewController:ctr animated:YES];
                }
                    break;
                case 2:{
            
                }
                    break;
                case 3:{
                
                }
                    break;
                
                default:
                    break;
            }
            break;
        
        default:
            break;
    }
    
}

#pragma mark - 代理获取
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error: 回调返回参数有误");
        return;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeArea:
        {
            self.sAreaName = valueInfo.sValue;
            self.sAreaKey  = valueInfo.sKey;
        }
            break;
        case HDExtendTypeTrade:
        {
            self.sTradeName = valueInfo.sValue;
            self.sTradeKey  = valueInfo.sKey;
        }
            break;
        case HDExtendTypePost:
        {
            self.sPostName = valueInfo.sValue;
            self.sPostKey  = valueInfo.sKey;
        }
            break;
        default:
            break;
    }
    [self.tbv reloadData];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _sRemark = textView.text;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    _sRemark = textView.text;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1 && indexPath.row == 3) {
        static NSString *cellIdentifier = @"WJBrokerMessageCell0";
        WJBrokerMessageCell0 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [WJBrokerMessageCell0 getBrokerMessageCell0];
        }
        cell.tv_content.delegate = self;
        cell.tv_content.tag      = 999;
        return cell;
    }
    static NSString *cellIdentifier = @"WJBrokerMessageCell";
    WJBrokerMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJBrokerMessageCell getBrokerMessageCell];
    }
    cell.lb_title.hidden            = NO;
    cell.v_line.hidden              = NO;
    cell.tf_content.hidden          = NO;
    cell.tf_introduction.hidden     = YES;
    cell.img_down.hidden            = NO;
    cell.tf_content.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lb_title.text   = @[@[@"当前职位", @"当前公司", @"所在城市"], @[@"擅长行业", @"擅长职位", @"荐客简介", @""]][indexPath.section][indexPath.row];
    cell.tf_content.delegate      = self;
    cell.tf_introduction.delegate = self;
    cell.tf_content.placeholder = @[@[@"", @"如需保密可匿名填写", @"请选择"], @[@"请选择", @"请选择", @""]][indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        cell.tf_content.tag = 10000+indexPath.row;
    }else{
        cell.tf_content.tag = 10000+indexPath.row+3;
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    cell.img_down.hidden = YES;
                    cell.tf_content.text = self.nowPost;
                }
                    break;
                case 1:
                {
                    cell.img_down.hidden = YES;
                    cell.tf_content.text = self.nowCompany;
                }
                    break;
                case 2:
                {
                    cell.tf_content.userInteractionEnabled = NO;
                    cell.tf_content.text = self.sAreaName;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    cell.tf_content.userInteractionEnabled = NO;
                    cell.tf_content.text = self.sTradeName;
                }
                    break;
                case 1:
                {
                    cell.tf_content.userInteractionEnabled = NO;
                    cell.tf_content.text = self.sPostName;
                }
                    break;
                case 2:
                {
                    cell.img_down.hidden    = YES;
                    cell.v_line.hidden      = YES;
                    cell.tf_content.hidden  = YES;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UITextField * nowPost    = (UITextField*)[self.view viewWithTag:10000];
    UITextField * nowCompany = (UITextField*)[self.view viewWithTag:10001];
    if (textField == nowPost) {
        self.nowPost = textField.text;
    }else if (textField == nowCompany){
        self.nowCompany = textField.text;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -- touch and response
//开启我的荐客旅程
- (IBAction)openJourney:(UIButton *)sender {

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.nowPost,@"curposition",
                         self.nowCompany,@"curcompany",
                         self.sAreaKey,@"area",
                         self.sTradeKey,@"trade",
                         self.sPostKey,@"post",
                         _sRemark, @"announce",nil];
    NSLog(@"%@",dic);
    if (self.nowPost.length == 0) {
        [HDUtility mbSay:@"请输入当前职位"];
        return;
    }
    if (self.nowCompany.length == 0) {
        [HDUtility mbSay:@"请输入当前公司"];
        return;
    }
    if (_sRemark.length == 0) {
        [HDUtility mbSay:@"请输入荐客简介"];
        return;
    }
    if (self.sAreaKey.length == 0) {
        [HDUtility mbSay:@"请选择所在城市"];
        return;
    }
    if (self.sTradeKey.length == 0) {
        [HDUtility mbSay:@"请选择擅长行业"];
        return;
    }
    if (self.sPostKey.length == 0) {
        [HDUtility mbSay:@"请选择擅长职位"];
        return;
    }
    
    [[HDHttpUtility sharedClient] presetThirdPartyUserInfo:[HDGlobalInfo instance].userInfo parameters:dic completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction)noOpenJourney:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}

- (void)doCancel:(id)sender{
    [HDGlobalInfo instance].hasLogined = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REGISTER_SUCCESS object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)spliceTheValue:(NSArray *)ar{
    if (ar.count == 0) {
        return @"";
    }
    NSString *s = ((HDWorkExpInfo *)ar[0]).sValue;
    for (int i = 1; i < ar.count; i++) {
        s = [s stringByAppendingString:FORMAT(@"+%@", ((HDWorkExpInfo *)ar[i]).sValue)];
    }
    return s;
}

@end
