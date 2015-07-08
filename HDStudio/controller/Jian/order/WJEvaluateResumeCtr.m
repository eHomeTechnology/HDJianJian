//
//  WJEvaluateResume.m
//  JianJian
//
//  Created by liudu on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJEvaluateResumeCtr.h"
#import "WJEvaluateResumeCell.h"
#import "WJRecommenInfoCtr.h"
#import "HDTableView.h"
#import "WJRecommendSucCtr.h"

@interface WJEvaluateResumeCtr ()<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet HDTableView *tbv;
@property (strong, nonatomic) IBOutlet UIView *v_head;
@property (strong, nonatomic) IBOutlet UIView *v_foot;
@property (strong, nonatomic) IBOutlet UIButton *btn_commitEvaluate;
@property (strong) NSString *professional;
@property (strong) NSString *management;
@property (strong) NSString *communication;
@property (strong) NSString *professionalQuality;
@property (strong) NSString *workAttitude;
@property (strong) NSString *tf_evaluate;
@property (strong) HDEvaluateInfo       *info;
@property (strong) WJEvaluateResumeCell *cell;
@property (strong) NSString *sDescribe;
@property (strong) AFHTTPRequestOperation *op;
@property (strong) IBOutlet NSLayoutConstraint *lc_tbvBottom;
@end

@implementation WJEvaluateResumeCtr

- (id)initWithRecommendTalent:(NSString *)talentNo recommenNo:(NSString *)recommendNo{
    if (self = [super init]) {
        self.PersonalNo = talentNo;
        self.RecommendID = recommendNo;
    }
    return self;
}
- (void)viewWillLayoutSubviews{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 110);
    self.v_foot.frame = CGRectMake(0, 0, HDDeviceSize.width, 80);
    [self.tbv setTableFooterView:self.v_foot];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"TXT_JJ_EVALUATION_CANDIDATE");
    self.tbv.delegate = self;
    self.tbv.dataSource = self;
    _sDescribe = @"";
    self.tbv.backgroundColor = [UIColor clearColor];
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
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? 218: 134;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellId = @"WJEvaluateResumeCell";
        _cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!_cell) {
            _cell = [WJEvaluateResumeCell getCell];
            [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return _cell;
    }
    static NSString *cellId = @"11121212131231";
    HDDescribeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [HDDescribeCell getCell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell.tv setDelegate:self];
    return cell;
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _sDescribe = textView.text;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    _sDescribe = textView.text;
}
#pragma mark - Event and Respond
- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view setNeedsUpdateConstraints];
    
}
- (IBAction)commitEvaluate:(UIButton *)sender {
    [self httpCommitRequest];
}

- (void)httpCommitRequest{
    _info = [HDEvaluateInfo new];
    _info.sRecommendId = self.RecommendID;
    _info.sPersonalNo  = self.PersonalNo;
    _info.sMatchPoint1 = _cell.str_professional?_cell.str_professional: @"";
    _info.sMatchPoint2 = _cell.str_management? _cell.str_management: @"";
    _info.sMatchPoint3 = _cell.str_communication? _cell.str_communication: @"";
    _info.sMatchPoint4 = _cell.str_professionalQuality? _cell.str_professionalQuality: @"";
    _info.sMatchPoint5 = _cell.str_workAttitude? _cell.str_workAttitude: @"";
    _info.sRemark = _sDescribe;
    if (_info.sMatchPoint1.length == 0 || _info.sMatchPoint2.length == 0 || _info.sMatchPoint3.length == 0 || _info.sMatchPoint4.length == 0 || _info.sMatchPoint5.length == 0 || _info.sRemark.length == 0) {
        [HDUtility mbSay:@"参数不能为空"];
        return;
    }
    _op = [[HDHttpUtility sharedClient] saveEvaluateInfo:[HDGlobalInfo instance].userInfo evaluate:_info completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *matchId) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _info = [HDEvaluateInfo new];
        WJRecommenInfoCtr *infomation = [[WJRecommenInfoCtr alloc] init];
        infomation.recommendid  = self.RecommendID;
        infomation.personalno   = self.PersonalNo;
        infomation.matchid      = matchId;
        [self.navigationController pushViewController:[WJRecommendSucCtr new] animated:YES];
    }];

}
@end
