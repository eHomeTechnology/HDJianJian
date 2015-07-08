//
//  HDImportViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDImportViewCtr.h"
#import "HDSelectPositionCtr.h"
#import "HDSelectDescCtr.h"
#import "HDNewPositionCtr.h"

@interface HDImportViewCtr (){


}
@property (assign) HDSearchImportType       theType;
@property (strong) NSMutableArray           *mar_company;
@property (strong) HDCompanyInfo            *selectedInfo;
@property (strong) AFHTTPRequestOperation   *op;
@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UITableView     *tbv;
@property (strong) IBOutlet UITextField     *tf_companyName;
@property (strong) IBOutlet NSLayoutConstraint *lc_confirmBottom;
@end


@implementation HDImportViewCtr

- (id)initWithType:(HDSearchImportType)type{
    if (self = [super init]) {
        _theType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{

    self.navigationItem.title   = LS(@"TXT_TITLE_SEARCH");
    if (_theType == HDSearchImportTypeDescribe) {
        _lb_title.text          = LS(@"TXT_JJ_ENTER_POSITION_NAME");
    }
    _tbv.hidden                 = YES;
    [_tf_companyName addTarget:self action:@selector(doValueChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HDCompanyInfo *info     = _mar_company[indexPath.row];
    _tf_companyName.text    = info.sName;
    _selectedInfo           = info;
    _tbv.hidden             = YES;
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _mar_company.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    HDCompanyInfo *info = _mar_company[indexPath.row];
    cell.textLabel.text = info.sName;
    return cell;
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![_tf_companyName isFirstResponder]) {
        _tbv.hidden = YES;
    }
    [_tf_companyName resignFirstResponder];
}

- (void)dealloc{
    
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.view endEditing:YES];
    [self doConfirm:nil];
    return YES;
}

#pragma mark - Event and Respond

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_confirmBottom.constant  = kbSize.height + 10;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_confirmBottom.constant = 90;
    [self.view setNeedsUpdateConstraints];
}

- (void)doValueChanged:(id)sender{
    Dlog(@"_tf_companyName.text = %@", _tf_companyName.text);
    _tbv.hidden = !_tf_companyName.text.length;
    _selectedInfo = nil;
    if (_tf_companyName.text.length == 0) {
        return;
    }
    NSString *sUrl = [HDGlobalInfo instance].addressInfo.sCloudsite_webroot;
    if (_theType == HDSearchImportTypePosition) {
        [self httpSearchForCompanyName:sUrl];
        return;
    }
    [self httpSearchForPositionNames:sUrl];
}

- (void)httpSearchForPositionNames:(NSString *)url{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
    NSString *s = @"http://192.168.100.74:22222/API";
    _op = [[HDHttpUtility instanceWithUrl:url] queryForPositionNames:_tf_companyName.text completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar) {
        if (!isSuccess) {
            if ([url isEqualToString:s]) {
                [HDUtility mbSay:sMessage];
                return;
            }
            [self httpSearchForPositionNames:s];
            return;
        }
        _mar_company = [[NSMutableArray alloc] initWithArray:ar];
        [_tbv reloadData];
    }];
}

- (void)httpSearchForPositions:(NSString *)url{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
    NSString *s = @"http://192.168.100.74:22222/API";
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility instanceWithUrl:url] queryForPositions:_tf_companyName.text completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar) {
        if (!isSuccess) {
            if ([url isEqualToString:s]) {
                [HDUtility mbSay:sMessage];
                [hud hiden];
                return;
            }
            [self httpSearchForPositions:s];
            [hud hiden];
            return;
        }
        NSMutableArray *mar_positions = [[NSMutableArray alloc] initWithArray:ar];
        HDNewPositionCtr *newPositionCtr = nil;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[HDNewPositionCtr class]]) {
                newPositionCtr = (HDNewPositionCtr *)controller;
            }
        }
        HDSelectDescCtr *ctr    = [[HDSelectDescCtr alloc] initWithPositions:mar_positions];
        ctr.descDelegate        = newPositionCtr;
        [hud hiden];
        [self.navigationController pushViewController:ctr animated:YES];
    }];
}

- (void)httpSearchForCompanyName:(NSString *)url{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
    NSString *s = @"http://192.168.100.74:22222/API";
    _op = [[HDHttpUtility instanceWithUrl:url] queryForCompanyName:_tf_companyName.text completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *ar) {
        if (!isSuccess) {
            if ([url isEqualToString:s]) {
                [HDUtility mbSay:sMessage];
                return;
            }
            [self httpSearchForCompanyName:s];
            return;
        }
        _mar_company = [[NSMutableArray alloc] initWithArray:ar];
        [_tbv reloadData];
    }];
}

- (IBAction)doConfirm:(id)sender{
    if (_tf_companyName.text.length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_COMPAMY_NAME")];
        return;
    }
    if (_theType == HDSearchImportTypeDescribe) {
        [self.view endEditing:YES];
        [self httpSearchForPositions:[HDGlobalInfo instance].addressInfo.sCloudsite_webroot];
        return;
    }
    if (_mar_company.count == 0) {
        [HDUtility mbSay:LS(@"TXT_NOT_FOUND_THE_COMPANY")];
        return;
    }
    if (!_selectedInfo) {
        if (_mar_company.count > 1) {
            [HDUtility mbSay:LS(@"TXT_PLEASE_CHOOSE_A_COMPANY")];
            return;
        }
        if ([_tf_companyName.text isEqual:((HDCompanyInfo *)_mar_company[0]).sName]) {
            _selectedInfo = _mar_company[0];
        }
    }
    HDSelectPositionCtr *ctr = [[HDSelectPositionCtr alloc] initWithCompanyInfo:_selectedInfo];
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
