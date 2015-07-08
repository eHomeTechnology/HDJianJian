//
//  HDTalentViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDTalentViewCtr.h"
#import "HDTalentCell.h"
#import "HDTableView.h"
#import "HDAddTalentCtr.h"

@interface HDTalentViewCtr ()<UITextFieldDelegate>{

}

@property (strong) NSMutableArray       *mar_value;
@property (strong) IBOutlet HDTableView *tbv;
@property (strong) IBOutlet UIButton    *btn_save;
@property (strong) HDTalentInfo         *talentInfo;
@property (strong) IBOutlet NSLayoutConstraint   *lc_tbvBottom;
@end

@implementation HDTalentViewCtr

- (id)initWithInfo:(HDTalentInfo *)talent{

    if (self = [super init]) {
        self.talentInfo = talent;
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.title = LS(@"WJ_TITLE_EDIT_TALENT");
    [super viewDidLoad];
    [self setup];
    [self setTableView];
}

- (void)setup{
    _mar_value = [[NSMutableArray alloc] initWithArray:@[@"", @"", @"", @"", @""]];
    if (self.talentInfo) {
        _mar_value = [[NSMutableArray alloc] initWithArray:@[_talentInfo.sName, _talentInfo.sCurPosition, _talentInfo.sCurCompanyName, _talentInfo.sWorkYears, _talentInfo.sPhone]];
        NSString *sWorkYears = _talentInfo.sWorkYears;
        if ([sWorkYears isEqualToString:@"无"]) {
            sWorkYears = nil;
        }
        if ([sWorkYears hasSuffix:@"年"]) {
            sWorkYears = [sWorkYears substringToIndex:sWorkYears.length - 1];
            [_mar_value replaceObjectAtIndex:3 withObject:sWorkYears];
        }
    
    }
}

- (void)setTableView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    v.backgroundColor           = [UIColor clearColor];
    self.btn_save.frame         = CGRectMake(0, 0, HDDeviceSize.width, 60);
    self.tbv.tableFooterView    = self.btn_save;
    [self.tbv setTableHeaderView:v];
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 50;
    [self.view setNeedsUpdateConstraints];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)doSave:(id)sender{
    [self.view endEditing:YES];
    if (((NSString *)_mar_value[0]).length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_NAME")];
        return;
    }
    if (((NSString *)_mar_value[0]).length > 50) {
        [HDUtility mbSay:LS(@"TXT_THE_MAX_NAME_IS_50")];
        return;
    }
    if (((NSString *)_mar_value[1]).length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_POSITION")];
        return;
    }
    if (((NSString *)_mar_value[1]).length > 50) {
        [HDUtility mbSay:LS(@"TXT_THE_MAX_POSITION_IS_50")];
        return;
    }
    if (((NSString *)_mar_value[2]).length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_COMPANY")];
        return;
    }
    if (((NSString *)_mar_value[2]).length > 50) {
        [HDUtility mbSay:LS(@"TXT_THE_MAX_COMPANY_IS_50")];
        return;
    }
    if (((NSString *)_mar_value[3]).length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_WORK_YEARS")];
        return;
    }
    if (((NSString *)_mar_value[3]).intValue > 100) {
        [HDUtility mbSay:LS(@"TXT_THE_MAX_WORK_TIME_100")];
        return;
    }
    if (![HDUtility isValidateMobile:((NSString *)_mar_value[4])]) {
        [HDUtility mbSay:LS(@"TXT_PHONE_NUMBER_INCORRECT")];
        return;
    }

    HDTalentInfo *info      = [HDTalentInfo new];
    info.sName              = _mar_value[0];
    info.sCurPosition       = _mar_value[1];
    info.sCurCompanyName    = _mar_value[2];
    info.sWorkYears         = _mar_value[3];
    info.sPhone            = _mar_value[4];
    if (self.talentInfo) {
        info.sHumanNo    = _talentInfo.sHumanNo;
        info.sRemark        = _talentInfo.sRemark;
        info.sCreatedTime   = _talentInfo.sCreatedTime;
        info.sMatchCount    = _talentInfo.sMatchCount;
        info.sStartWorkTime = _talentInfo.sStartWorkTime;
        [[HDHttpUtility sharedClient] modifyTalent:[HDGlobalInfo instance].userInfo talent:info completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            [HDUtility mbSay:sMessage];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [[HDHttpUtility sharedClient] newTalent:[HDGlobalInfo instance].userInfo talent:info completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            [HDUtility mbSay:sMessage];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)sender{
    [_mar_value replaceObjectAtIndex:sender.tag withObject:sender.text];
    [_tbv reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDTalentViewCell *cell = (HDTalentViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //cell.tf_value.userInteractionEnabled = YES;
    [cell.tf_value becomeFirstResponder];
}

#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *cellIdentifier = @"talentview";
   // HDTalentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //if (cell == nil) {
    HDTalentViewCell *cell                = [self getTalentViewCell];
    cell.tf_value.delegate = self;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
   // }
    cell.lb_accesory.text   = nil;
    cell.lb_title.text      = @[LS(@"TXT_JJ_TALENT_NAME"), LS(@"TXT_JJ_CURRENT_POSITION"), LS(@"TXT_JJ_CURRENT_COMPANY"), LS(@"TXT_JJ_WORK_YEAR"), LS(@"TXT_JJ_CONNECT_WAY")][indexPath.section];
    cell.lc_width.constant = 0.;
    if (indexPath.section == 3) {
        cell.lc_width.constant  = 60;
        cell.lb_accesory.text   = LS(@"TXT_JJ_NIAN_YI_SHANG");
    }
    [cell setNeedsUpdateConstraints];
    cell.tf_value.text  = _mar_value[indexPath.section];
    cell.tf_value.tag   = indexPath.section;
    [cell.tf_value addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    cell.tf_value.keyboardType = UIKeyboardTypeDefault;
    if (indexPath.section > 2) {
        cell.tf_value.keyboardType = UIKeyboardTypeNumberPad;
    }
    return cell;
}

- (HDTalentViewCell *)getTalentViewCell{
    HDTalentViewCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDTalentCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDTalentViewCell class]]) {
            cell = (HDTalentViewCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}

- (void)dealloc{
    
}

@end
