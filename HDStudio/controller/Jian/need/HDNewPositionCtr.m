//
//  HDNewPositionCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewPositionCtr.h"
#import "HDTableView.h"
#import "HDExtendListCtr.h"
#import "HDNewPosition2Ctr.h"
#import "HDImportViewCtr.h"
#import "HDNewPositionCell.h"

@interface HDNewPositionCtr ()<UITextFieldDelegate, UITextViewDelegate, HDExtendListDelegate>{
    CGFloat     height;
    NSArray     *ar_title;
    UITextView  *tv;
    BOOL        isEditPosition;
    IBOutlet UIView     *v_sectionHead;
    IBOutlet UIView     *v_guide;
    IBOutlet UIButton   *btn_next;
}
@property (strong) AFHTTPRequestOperation   *op;
@property (strong) WJPositionInfo           *positionInfo;
@property (strong) IBOutlet HDTableView     *tbv;
@property (strong) IBOutlet NSLayoutConstraint *lc_tbvBottom;
@end

@implementation HDNewPositionCtr

- (id)initWithPosition:(WJPositionInfo *)position{
    if (self = [super init]) {
        if (!position) {
            return self;
        }
        _positionInfo   = position;
        isEditPosition  = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHead];
    if (!isEditPosition) {
        [self setNavigationBarButton];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section != 2) {
        return;
    }
    HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:[@[@(HDExtendTypeArea), @(HDExtendTypePost), @(HDExtendTypeSalary), @(HDExtendTypeWorkExp), @(HDExtendTypeEducation)][indexPath.row] integerValue] object:nil maxSelectCount:1];
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 2) {
        return nil;
    }
    v_sectionHead.frame = CGRectMake(0, 0, HDDeviceSize.width, 40);
    return v_sectionHead;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        CGFloat height_ = [HDUtility measureHeightOfUITextView:tv];
        return MIN(MAX(55, height_+40), 100000);;
    }
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 1) {
        return 2;
    }
    if (sectionIndex == 2) {
        return 5;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && indexPath.section == 1) {
        HDPositionDescCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"HDPositionDescCell"];
        if (cell0 == nil) {
            cell0 = [HDPositionDescCell getPositionDescCell];
        }
        cell0.tv.text       = _positionInfo.sRemark;
        cell0.tv.delegate   = self;
        cell0.tv.textColor  = [UIColor blackColor];
        cell0.tv.alpha      = 1.0;
        tv                  = cell0.tv;
        if ([cell0.tv.text length] == 0) {
            cell0.tv.textColor  = [UIColor grayColor];
            cell0.tv.alpha      = 0.5;
            cell0.tv.text       = LS(@"TXT_JJ_POSITION_DESC_PLACEHOLD");
        }
        cell0.selectionStyle    = UITableViewCellSelectionStyleNone;
        return cell0;
    }
    
    HDNewPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDNewPositionCell"];
    if (cell == nil) {
        cell = [HDNewPositionCell getNewPositionCell];
    }
    cell.lb_title.text      = ar_title[indexPath.section][indexPath.row];
    cell.imv_icon.hidden    = indexPath.section == 2? NO: YES;
    cell.v_line.hidden      = NO;
    cell.tf_content.hidden  = NO;
    cell.v_lineTrailing.hidden              = YES;
    cell.tf_content.userInteractionEnabled  = YES;
    if (indexPath.section == 0) {
        cell.tf_content.placeholder = LS(@"TXT_JJ_CANNOT_BE_NIL");
        cell.tf_content.delegate    = self;
        [cell.tf_content addTarget:self action:@selector(doPositionNameEditing:) forControlEvents:UIControlEventEditingChanged];
        cell.tf_content.text        = _positionInfo.sPositionName;
        cell.selectionStyle         = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (indexPath.section == 1) {
        cell.v_line.hidden      = YES;
        cell.tf_content.hidden  = YES;
        cell.selectionStyle         = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 2) {
        cell.tf_content.userInteractionEnabled = NO;
        cell.tf_content.placeholder = LS(@"TXT_JJ_PLEASE_SELECT");
    }
    cell.tf_content.text    = @[_positionInfo.sAreaText     ? _positionInfo.sAreaText:      @"",
                                _positionInfo.sFunctionText ? _positionInfo.sFunctionText:  @"",
                                _positionInfo.sSalaryText   ? _positionInfo.sSalaryText:    @"",
                                _positionInfo.sWorkExpText  ? _positionInfo.sWorkExpText:   @"",
                                _positionInfo.sEducationText? _positionInfo.sEducationText: @""
                                ][indexPath.row];
    return cell;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    _positionInfo.sPositionName = textField.text;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:LS(@"TXT_JJ_POSITION_DESC_PLACEHOLD")]) {
        textView.text       = @"";
    }
    textView.alpha      = 1.0f;
    textView.textColor  = [UIColor blackColor];
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    _positionInfo.sRemark = textView.text;
    [_tbv beginUpdates];
    [_tbv endUpdates];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _positionInfo.sRemark = textView.text;
    return YES;
}

#pragma mark HDExtendListDelegate

- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error：回调返回参数有误");
        return;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeArea:{
            _positionInfo.sAreaText     = valueInfo.sValue;
            _positionInfo.sArea         = valueInfo.sKey;
            break;
        }
        case HDExtendTypePost:{
            _positionInfo.sFunctionText = valueInfo.sValue;
            _positionInfo.sFunctionCode = valueInfo.sKey;
            break;
        }
        case HDExtendTypeSalary:{
            _positionInfo.sSalaryText   = valueInfo.sValue;
            _positionInfo.sSalaryCode   = valueInfo.sKey;
            break;
        }
        case HDExtendTypeWorkExp:{
            _positionInfo.sWorkExpText   = valueInfo.sValue;
            _positionInfo.sWorkExpCode   = valueInfo.sKey;
            break;
        }
        case HDExtendTypeEducation:{
            _positionInfo.sEducationText = valueInfo.sValue;
            _positionInfo.sEducationCode = valueInfo.sKey;
            break;
        }
        default:
            break;
    }
    [_tbv reloadData];
}

#pragma mark  HDSelectDescDelegate
- (void)selectDescDelegate:(WJPositionInfo *)position{
    _positionInfo = position;
    [_tbv reloadData];
}

#pragma mark - Event and Respond

- (void)doCancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)doImport:(id)sender{
    v_guide.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height);
    [kWindow addSubview:v_guide];
}

- (IBAction)doGuideViewButtonAction:(UIButton *)sender{
    [v_guide removeFromSuperview];
    switch (sender.tag) {
        case 0:{//关闭
            break;
        }
        case 1:{//导入职位
            [self.navigationController pushViewController:[[HDImportViewCtr alloc] init] animated:YES];
            break;
        }
        case 2:{//导入描述
            [self.navigationController pushViewController:[[HDImportViewCtr alloc] initWithType:HDSearchImportTypeDescribe] animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)doPositionNameEditing:(UITextField *)tf{
    _positionInfo.sPositionName = tf.text;
}
- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view updateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view updateConstraints];
}
- (IBAction)doNext:(id)sender{
    if (_positionInfo.sPositionName.length == 0) {
        [HDJJUtility jjSay:@"请输入职位名称" delegate:self];
        return;
    }
    if (_positionInfo.sPositionName.length > MAX_POSITION_TITLE) {
        [HDJJUtility jjSay:FORMAT(@"您输入的职位名称太长，最多%d个字符", MAX_POSITION_TITLE) delegate:self];
        return;
    }
    if (_positionInfo.sRemark.length == 0) {
        [HDJJUtility jjSay:@"请输入职位描述" delegate:self];
        return;
    }
    if (_positionInfo.sRemark.length > MAX_POSITION_REMARK) {
        [HDJJUtility jjSay:FORMAT(@"您输入的职位描述太长，最多%d个字符", MAX_POSITION_REMARK) delegate:self];
        return;
    }
    if (isEditPosition) {
        HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
        _op = [[HDHttpUtility sharedClient] modifyPosition:[HDGlobalInfo instance].userInfo position:self.positionInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
            [hud hiden];
            [HDUtility mbSay:sMessage];
            if (!isSuccess) {
                return ;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    [self.navigationController pushViewController:[[HDNewPosition2Ctr alloc] initWithPosition:_positionInfo] animated:YES];
}

#pragma mark - Setter and Getter
- (void)setup{
    if (isEditPosition) {
        self.navigationItem.title   = LS(@"修改职位");
        [btn_next setTitle:LS(@"HD_BUTTON_TITLE_CONPLET") forState:UIControlStateNormal];
    }else{
        self.navigationItem.title = LS(@"TXT_TITLE_RELEASE_POSITION");
        _positionInfo           = [WJPositionInfo new];
    }
    ar_title = @[@[LS(@"TXT_JJ_POSITION_NAME")], @[LS(@"TXT_JJ_POSITION_DESCRIBE")], @[LS(@"TXT_JJ_WORK_ADDRESS"), LS(@"TXT_JJ_POSITION_TYPE"), LS(@"TXT_JJ_SALARY_OF_ONE_YEAR"), LS(@"TXT_JJ_WORK_YEARS"), LS(@"TXT_JJ_EDUCATION")]];
}

- (void)setNavigationBarButton{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 70, 25);
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"导入职位" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius     = 12.;
    btn.layer.masksToBounds    = YES;
    btn.layer.borderColor      = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth      = 0.5;
    [btn addTarget:self action:@selector(doImport:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setTableHead{
    UIView *v                   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 20)];
    v.backgroundColor           = [UIColor clearColor];
    self.tbv.tableHeaderView    = v;
    height                      = 55;
    UIView *v_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 50)];
    v_.backgroundColor = [UIColor clearColor];
    [_tbv setTableFooterView:v_];
}
@end
