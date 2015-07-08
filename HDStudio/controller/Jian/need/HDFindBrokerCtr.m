//
//  HDFindBrokerCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDFindBrokerCtr.h"
#import "HDSettingViewCtr.h"
#import "HDProfileViewCtr.h"
#import "WJFindBrokerCell.h"
#import "HDExtendListCtr.h"
#import "WJBrokerListCtr.h"
#import "HDTableView.h"



@interface HDFindBrokerCtr ()<UITextFieldDelegate,UINavigationControllerDelegate,HDExtendListDelegate>
{
    UIButton *btn_search;
}

@property (strong, nonatomic) IBOutlet UIView *v_line;
@property (strong, nonatomic) IBOutlet UIView *v_seach;
@property (strong) IBOutlet HDTableView         *tbv;
@property (strong) HDUserInfo                   *user;
@property (strong) NSMutableArray               *mar_value;
@property (strong) AFHTTPRequestOperation       *op;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;


#pragma mark - 临时选择类型
/**
 *  擅长行业
 */
@property (nonatomic,strong)NSString *industryStr;
@property (nonatomic,strong)NSString *industryID;
/**
 *  擅长职位
 */
@property (nonatomic,strong)NSString *positionStr;
@property (nonatomic,strong)NSString *positionID;
/**
 *  工作年限
 */
@property (nonatomic,strong)NSString *workTimeStr;
@property (nonatomic,strong)NSString *workTimeID;
/**
 *  所在城市
 */
@property (nonatomic,strong)NSString *cityNameStr;
@property (nonatomic,strong)NSString *cityNameID;
/**
 *  用于判断所选类型
 */
@property (nonatomic,assign)NSInteger chooseIndex;
@end

@implementation HDFindBrokerCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableFooter];
    [self setTableHeader];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_FIND_TALENT_BROKER");
    _user = [HDGlobalInfo instance].userInfo;
  
    NSMutableArray *mar_trade  =  [HDTradeInfo getTradeInfosWithKeys:[_user.sTradeKey componentsSeparatedByString:@"|"]];
    NSMutableArray *mar_post   =  [HDPostInfo getPostItemsWithKeys:[_user.sPostKey componentsSeparatedByString:@"|"]];
    HDAreaItem     *areaItem   =  [HDAreaInfo getAreaItemWithkey:_user.sAreaKey];
    HDWorkExpInfo  *workExp    =  [HDWorkExpInfo getWorkInfoWithStartWorkDT:_user.sStartWorkDT];
    NSArray *ar = @[
                    @[
                        (mar_trade? mar_trade: [[NSMutableArray alloc] initWithArray:@[[HDTradeInfo new]]]),
                        (mar_post? mar_post: [[NSMutableArray alloc] initWithArray:@[[HDPostItem new]]]),
                        @[workExp? workExp: [HDWorkExpInfo new]],
                        @[(areaItem? areaItem: [HDAreaItem new])]
                     ]
                    ];
    _mar_value          = [[NSMutableArray alloc] initWithArray:ar];
    self.industryStr    = @"不限";
    self.positionStr    = @"不限";
    self.workTimeStr    = @"不限";
    self.cityNameStr    = @"不限";
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self resetupValues];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 50.;
    [self.view setNeedsUpdateConstraints];
}

- (void)resetupValues{
    NSMutableDictionary *mdc = [HDGlobalInfo instance].mdc_preset;
    if (mdc.count > 1) {
        NSArray *ar = @[(mdc[@KEY_PRESET_TRADE]? mdc[@KEY_PRESET_TRADE]: @[[HDTradeInfo new]]), (mdc[@KEY_PRESET_POST]? mdc[@KEY_PRESET_POST]: @[[HDPostItem new]]),(mdc[@KEY_PRESET_WORKEXP]? mdc[@KEY_PRESET_WORKEXP]: @[[HDWorkExpInfo new]]),(mdc[@KEY_PRESET_AREA]? mdc[@KEY_PRESET_AREA]: @[[HDAreaItem new]])];
        [_mar_value replaceObjectAtIndex:0 withObject:ar];
        [self.tbv reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillLayoutSubviews{

}

- (void)setTableFooter{
    if (self.tbv.tableFooterView) {
        [self.tbv.tableFooterView removeFromSuperview];
        self.tbv.tableFooterView = nil;
    }
    UIView *v_footer = [[UIView alloc] initWithFrame:CGRectMake(15, 0, HDDeviceSize.width-30, 55)];
    v_footer.backgroundColor = [UIColor clearColor];
    [self.tbv setTableFooterView:v_footer];
    
    btn_search = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width-30, 55)];
    btn_search.backgroundColor = HDCOLOR_RED;
    [btn_search setTitle:LS(@"TXT_JJ_SEARCH") forState:UIControlStateNormal];
    [btn_search addTarget:self action:@selector(searchOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [v_footer addSubview:btn_search];
}

- (void)searchOnClick:(UIButton *)send{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    UITextField *textField = (UITextField *)[self.view viewWithTag:999];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:textField.text, @"keyword",
                                self.positionID? self.positionID: @"", @"functionCode",
                                self.industryID? self.industryID: @"", @"businessCode",
                                self.workTimeID? self.workTimeID: @"", @"startworkDT",
                                self.cityNameID? self.cityNameID: @"", @"area",
                                @"0",@"roleType",
                                @"",@"istop", nil];
    [[HDHttpUtility sharedClient] getBrokerList:[HDGlobalInfo instance].userInfo dic:dic pageIndex:@"1" size:@"24" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents){
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        WJBrokerListCtr *list = [[WJBrokerListCtr alloc]init];
        list.brokerDataAry = talents;
        list.typeDic = dic;
        [self.navigationController pushViewController:list animated:YES];
    }];
}

- (void)setTableHeader{
    self.v_seach.frame = CGRectMake(0, 0, HDDeviceSize.width, 70);
    self.v_line.frame  = CGRectMake(20, 69, HDDeviceSize.width, 0.5f);
    [self.tbv setTableHeaderView:self.v_seach];
}


#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *ar = _mar_value[0];
    [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_TRADE]   = ar[0];
    [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_POST]    = ar[1];
    [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_WORKEXP] = [[NSMutableArray alloc] initWithArray:ar[2]];
    [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_AREA]    = [[NSMutableArray alloc] initWithArray:ar[3]];
    HDExtendListCtr *ctr = nil;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    // ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade withObject:nil];
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:nil maxSelectCount:1];
                    break;
                }
                case 1:{
                     //ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost withObject:nil];
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost object:nil maxSelectCount:1];
                    break;
                }
                case 2:{
                    //ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeWorkExp withObject:nil];
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeWorkExp object:nil maxSelectCount:1];
                    break;
                }
                case 3:{
                    //ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea withObject:nil];
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:nil maxSelectCount:1];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        
        default:
            break;
    }
    ctr.delegate        = self;
    self.chooseIndex    = indexPath.row;
    //((HDTabBarController *)self.navigationController.tabBarController).hideTabbar = YES;
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark -  
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"WJFindBrokerCell";
    WJFindBrokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getJianCell];
        cell.lc_lineHeight.constant = 0.5f;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell updateConstraints];
    }
    cell.lb_title.text = @[LS(@"TXT_YOUR_SERVED_TRADE"),
                           LS(@"TXT_YOUR_SERVED_POSITION"),
                           LS(@"TXT_YOUR_WORKED_YEARS"),
                           LS(@"TXT_YOUR_WORKED_AREAS")
                             ][indexPath.row];
    
    if (indexPath.row == 0) {
        cell.tf_value.text = self.industryStr?self.industryStr:@"不限";
    }else if (indexPath.row == 1){
        cell.tf_value.text = self.positionStr?self.positionStr:@"不限";
    }else if (indexPath.row == 2){
        cell.tf_value.text = self.workTimeStr?self.workTimeStr:@"不限";
    }else{
        cell.toViewLeftWidth.constant = cell.toViewRightWidth.constant = - 12.0f;
        cell.tf_value.text = self.cityNameStr?self.cityNameStr:@"不限";
    }
    return cell;
}

#pragma mark - HDExtendListDelegate 处理返回数据
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{

    if (mar.count == 0) {
        return ;
    }
    if (self.chooseIndex == 0) {
        HDTradeInfo *trade = mar[0];
        self.industryStr = trade.sValue;
        self.industryID = trade.sKey;
    }else if (self.chooseIndex == 1){
        HDPostItem *post = mar[0];
        self.positionStr = post.sValue;
        self.positionID = post.sKey;
    }else if (self.chooseIndex == 2){
        HDWorkExpInfo *work = mar[0];
        self.workTimeStr = work.sValue;
        self.workTimeID = work.sKey;
    }else{
        HDAreaItem *area = mar[0];
        self.cityNameStr = area.sValue;
        self.cityNameID = area.sKey;
    }
    [self.tbv reloadData];
}


- (WJFindBrokerCell *)getJianCell{
    WJFindBrokerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJFindBrokerCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJFindBrokerCell class]]) {
            cell = (WJFindBrokerCell *)obj;
            break;
        }
    }
    return cell;
}

#pragma mark---TextField隐藏键盘----
//隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];//注:view为TextField的背景View,如Self.View
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
