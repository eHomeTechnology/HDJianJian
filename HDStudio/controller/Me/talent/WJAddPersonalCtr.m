//
//  WJAddPersonalCtr.m
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJAddPersonalCtr.h"
#import "WJAddPersonalCell.h"
#import "HDExtendListCtr.h"
#import "HDTableView.h"

@interface WJAddPersonalCtr ()<HDExtendListDelegate>

@property (strong) IBOutlet HDTableView *tbv;
@property (strong) IBOutlet UIView      *v_foot;
@property (strong) IBOutlet UITextView  *tv;
@property (strong) IBOutlet NSLayoutConstraint *lc_tbvBottom;
@property (strong) HDTalentInfo         *talentInfo;
@property (assign) NSInteger            personalType;
/**
 *  学历
 **/
@property (strong) NSString *sEducationName;
@property (strong) NSString *sEducationKey;
/**
 *  当前所在地
 **/
@property (strong) NSString *sAreaName;
@property (strong) NSString *sAreaKey;
/**
 *  姓名
 */
@property (strong) NSString *sName;
/**
 *  当前职位
 */
@property (strong) NSString *sPosition;
/**
 *  当前公司
 */
@property (strong) NSString *sCompany;
/**
 *  工作年限
 */
@property (strong) NSString *sWorkYear;
/**
 *  联系方式
 */
@property (strong) NSString *sContact;
/**
 *  性别
 */
@property (strong) NSString *sSex;
@end

@implementation WJAddPersonalCtr

#pragma mark -
#pragma mark - life cycle

- (id)initWithTalentInfo:(HDTalentInfo *)talent type:(WJPersonalType)type{
    if (self = [super init]) {
        self.talentInfo = talent;
        NSLog(@"%@====r",self.talentInfo);
        _personalType   = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setNavidationItemBarButton];
}

- (void)setup{
    if (_personalType == WJPersonalTypeAdd) {
        self.navigationItem.title = LS(@"WJ_TITLE_ADD_PERSONAL");
        self.talentInfo = [HDTalentInfo new];
        return;
    }
    self.navigationItem.title = LS(@"WJ_TITLE_EDIT_PERSONAL");
    self.tv.text = self.talentInfo.sRemark;
    self.tv.delegate = self;
    self.tv.tag      = 999;
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
}


#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 0.1)];
        return v;
    }
    return self.v_foot;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        return;
    }
    switch (indexPath.row) {
        case 2:{
            HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeEducation object:nil maxSelectCount:1];
            ctr.delegate = self;
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 3:{
            HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:nil maxSelectCount:1];
            ctr.delegate = self;
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 8;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJAddPersonalCell";
    WJAddPersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [WJAddPersonalCell getAddPersonalCell];
    }
    cell.tf_content.delegate = self;
    cell.tf_content.tag      = 200+indexPath.row;
    cell.tf_content.hidden  = NO;
    cell.tf_content.enabled  = YES;
    cell.lb_title.text      = @[@[@"人选姓名", @"性       别", @"学       历", @"当前所在地", @"当前职位", @"当前公司", @"工作年限", @"联系方式"], @[@"完整简历"]][indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.tf_content.keyboardType = UIKeyboardTypeDefault;
                if (self.talentInfo.sName.length != 0) {
                    self.sName = self.talentInfo.sName;
                }
                    cell.tf_content.text = self.sName?self.sName:@"";
            }
                break;
            case 1:
            {
                cell.tf_content.hidden  = YES;
                cell.v_boy.hidden       = NO;
                cell.v_girl.hidden      = NO;
                cell.img_boy.tag        = 100;
                cell.img_girl.tag       = 101;
                if (self.talentInfo.sSex.length != 0) {
                    if ([self.talentInfo.sSex integerValue] == 0) {
                        cell.img_boy.hidden     = YES;
                        cell.img_girl.hidden    = YES;
                    }else if([self.talentInfo.sSex integerValue] == 1){
                        cell.img_boy.hidden = NO;
                        cell.img_girl.hidden = YES;
                    }else{
                        cell.img_boy.hidden     = YES;
                        cell.img_girl.hidden    = NO;
                    }
                }else{
                    if ([self.sSex integerValue] == 0) {
                        cell.img_boy.hidden     = YES;
                        cell.img_girl.hidden    = YES;
                    }else if([self.sSex integerValue] == 1){
                        cell.img_boy.hidden = NO;
                        cell.img_girl.hidden = YES;
                    }else{
                        cell.img_boy.hidden     = YES;
                        cell.img_girl.hidden    = NO;
                    }
                }
                
                [cell.btn_boy addTarget:self action:@selector(selectBoy) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_girl addTarget:self action:@selector(selectGirl) forControlEvents:UIControlEventTouchUpInside];
                
            }
                break;
            case 2:
            {
                cell.tf_content.enabled = NO;
                cell.img_down.hidden = NO;
                cell.lc_downWith_width.constant = 15;
                if (self.talentInfo.sEduLevel.length != 0) {
                    self.sEducationName = self.talentInfo.sEduLevel;
                    self.sEducationKey  = self.talentInfo.sEduLecelKey;
                    
                }
                cell.tf_content.text = self.sEducationName? self.sEducationName: @"";
            }
                break;
            case 3:
            {
                cell.tf_content.enabled = NO;
                cell.img_down.hidden = NO;
                cell.lc_downWith_width.constant = 15;
                if (self.talentInfo.sAreaText.length != 0) {
                    self.sAreaName = self.talentInfo.sAreaText;
                    self.sAreaKey  = self.talentInfo.sArea;
                }
                cell.tf_content.text = self.sAreaName? self.sAreaName: @"";
            }
                break;
            case 4:
            {
                cell.tf_content.keyboardType = UIKeyboardTypeDefault;
                if (self.talentInfo.sCurPosition.length != 0) {
                    self.sPosition = self.talentInfo.sCurPosition;
                }
                cell.tf_content.text = self.sPosition?self.sPosition:@"";
            }
                break;
            case 5:
            {
                cell.tf_content.keyboardType = UIKeyboardTypeDefault;
                if (self.talentInfo.sCurCompanyName.length != 0) {
                    self.sCompany = self.talentInfo.sCurCompanyName;
                }
                cell.tf_content.text = self.sCompany?self.sCompany:@"";
            }
                break;
            case 6:
            {
                cell.lb_year.hidden = NO;
                cell.lc_yearWithWidth.constant = 44;
                cell.tf_content.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                if (self.talentInfo.sWorkYears.length != 0) {
                    NSArray *array = [self.talentInfo.sWorkYears componentsSeparatedByString:@"年"];
                    Dlog(@"时间---%@",array[0]);
                    //self.sWorkYear = self.talentInfo.sWorkYears;
                    self.sWorkYear = array[0];
                }
                cell.tf_content.text = self.sWorkYear? self.sWorkYear:@"";
            }
                break;
            case 7:
            {
                cell.tf_content.placeholder = @"建议填写,提高人选机会";
                cell.tf_content.keyboardType = UIKeyboardTypeNumberPad;
                if (self.talentInfo.sPhone.length != 0) {
                    self.sContact = self.talentInfo.sPhone;
                }
                cell.tf_content.text = self.sContact?self.sContact:@"";
            }
                break;
                
            default:
                break;
        }
    }else{
        cell.v_line.hidden = YES;
        cell.tf_content.hidden = YES;
    }
    [self.view updateConstraints];
    return cell;
}

#pragma mark - HDExtendListDelegate
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error: 回调返回参数有误");
        return;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeEducation:
        {
            self.sEducationName = valueInfo.sValue;
            self.sEducationKey  = valueInfo.sKey;
        }
            break;
        case HDExtendTypeArea:
        {
            self.sAreaName = valueInfo.sValue;
            self.sAreaKey  = valueInfo.sKey;
        }
            break;
            
        default:
            break;
    }
    [self.tbv reloadData];
}
#pragma mark - UITextViewDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark event response

- (void)selectBoy{
    UIImageView *img_boy   = (UIImageView *)[self.view viewWithTag:100];
    UIImageView *img_girl  = (UIImageView *)[self.view viewWithTag:101];
    img_boy.hidden  = NO;
    img_girl.hidden = YES;
    self.sSex = @"1";
}

- (void)selectGirl{
    UIImageView *img_boy   = (UIImageView *)[self.view viewWithTag:100];
    UIImageView *img_girl  = (UIImageView *)[self.view viewWithTag:101];
    img_girl.hidden = NO;
    img_boy.hidden  = YES;
    self.sSex = @"2";
}

- (IBAction)saveOnClick:(UIButton *)sender {
    [self.view endEditing:YES];
    HDTalentInfo * talentInfo = [[HDTalentInfo alloc]init];
    talentInfo.sName              = self.sName;
    talentInfo.sSexText           = self.sSex;
    talentInfo.sEduLevel          = self.sEducationKey;
    talentInfo.sAreaText          = self.sAreaKey;
    talentInfo.sCurPosition       = self.sPosition;
    talentInfo.sCurCompanyName    = self.sCompany;
    talentInfo.sWorkYears         = self.sWorkYear;
    talentInfo.sPhone             = self.sContact;
    talentInfo.sRemark            = self.tv.text;
    talentInfo.sHumanNo           = self.talentInfo.sHumanNo;
    if (talentInfo.sName.length == 0){
        [HDUtility mbSay:@"请输入人选姓名"];
        return;
    }
    if (talentInfo.sEduLevel.length == 0) {
        [HDUtility mbSay:@"请选择学历"];
        return;
    }
    if (talentInfo.sAreaText.length == 0) {
        [HDUtility mbSay:@"请输入当前所在地"];
        return;
    }
    if (talentInfo.sCurPosition.length == 0) {
        [HDUtility mbSay:@"请输入当前职位"];
        return;
    }
    if (talentInfo.sCurCompanyName.length == 0) {
        [HDUtility mbSay:@"请输入当前公司"];
        return;
    }
    if (talentInfo.sWorkYears.length == 0) {
        [HDUtility mbSay:@"请输入工作年限"];
        return;
    }
    if (talentInfo.sPhone.length == 0) {
        [HDUtility mbSay:@"请输入联系方式"];
        return;
    }
    if (talentInfo.sRemark.length == 0) {
        [HDUtility mbSay:@"请填写完整简历"];
        return;
    }

    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    switch (_personalType) {
        case WJPersonalTypeAdd:
        {
            [[HDHttpUtility sharedClient] newTalent:[HDGlobalInfo instance].userInfo talent:talentInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            break;
        case WJPersonalTypeEdit:
        {
            [[HDHttpUtility sharedClient] modifyTalent:[HDGlobalInfo instance].userInfo talent:talentInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [hud hiden];
                if (!isSuccess) {
                    [HDUtility mbSay:sMessage];
                    return ;
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:HD_NOTIFICATION_KEY_EDIT_PERSONAL object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        default:
            break;
    }
    
}


- (void)scrollBottom{
    if (self.tbv.contentSize.height < self.tbv.frame.size.height) {
        return;
    }
    [self.tbv setContentOffset:CGPointMake(0, self.tbv.contentSize.height - CGRectGetHeight(self.tbv.frame))];
}
- (void)doCancel:(id)sender{

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField
- (void)textFieldDidEndEditing:(UITextField *)textField{
     UITextField *sName = (UITextField*)[self.tbv viewWithTag:200];
     UITextField *sPosition = (UITextField*)[self.tbv viewWithTag:204];
     UITextField *sCompany = (UITextField*)[self.tbv viewWithTag:205];
     UITextField *sWorkYear = (UITextField*)[self.tbv viewWithTag:206];
     UITextField *sContact = (UITextField*)[self.tbv viewWithTag:207];
    if (textField == sPosition) {
        self.sPosition = sPosition.text;
    }else if (textField == sCompany){
        self.sCompany = sCompany.text;
    }else if (textField == sWorkYear){
        self.sWorkYear = sWorkYear.text;
    }else if (textField == sContact){
        self.sContact = sContact.text;
    }else if (textField == sName){
        self.sName = sName.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextField *sWorkYear = (UITextField*)[self.tbv viewWithTag:206];
    if (textField == sWorkYear) {
        BOOL isHaveDian = YES;
        
        if ([textField.text rangeOfString:@"."].location==NSNotFound){
            isHaveDian=NO;
        }
        if ([string length]>0){
            unichar single=[string characterAtIndex:0];//当前输入的字符
            if ((single >= '0' && single <= '9') || single == '.')//数据格式正确
            {
                //首字母不能为0和小数点
                if([textField.text length]==0){
                    if(single == '.'){
                        [HDUtility mbSay:@"第一个数字不能为小数点"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                    if (single == '0') {
                        [HDUtility mbSay:@"第一个数字不能为0"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                }
                if (single == '.')
                {
                    if(!isHaveDian)//text中还没有小数点
                    {
                        isHaveDian = YES;
                        return YES;
                    }else{
                        [HDUtility mbSay:@"您已经输入过小数点了"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                }else{
                    if (isHaveDian)//存在小数点
                    {
                        //判断小数点的位数
                        NSRange ran = [textField.text rangeOfString:@"."];
                        int tt = (int)(range.location - ran.location);
                        if (tt <= 1){
                            return YES;
                        }else{
                            [HDUtility mbSay:@"您最多输入一位小数"];
                            return NO;
                        }
                    }else{
                        return YES;
                    }
                }
            }else{//输入的数据格式不正确
                 [HDUtility mbSay:@"您输入的格式不正确"];
                [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

#pragma mark - setter getter
- (void)setNavidationItemBarButton{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveOnClick:)];
}

//- (NSString*)timeConversion:(NSInteger)dateInteger{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"yyyy.MM.dd"];
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:dateInteger];
//    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
//    return confromTimespStr;
//}
@end
