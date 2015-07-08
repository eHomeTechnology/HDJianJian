//
//  HDSearchOrderCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/15.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//
#define viewWith [UIScreen mainScreen].bounds.size.width
#import "HDSearchOrderCtr.h"
#import "WJFindBrokerCell.h"
#import "HDExtendListCtr.h"
#import "WJOrderListCtr.h"
#import "WJSearchOrderCache.h"

@interface HDSearchOrderCtr ()<HDExtendListDelegate>
//关键字
@property (strong, nonatomic) IBOutlet UITextField *tf_keyword;

//关键字视图
@property (strong, nonatomic) IBOutlet UIView *v_keywordView;

//搜索按钮
@property (strong,nonatomic)UIButton * btn_search;

//赏金视图
@property (strong, nonatomic) IBOutlet UIView *v_bountyView;
@property (weak, nonatomic) IBOutlet UITextField *tf_bountyText;

//删除历史视图
@property (strong, nonatomic) IBOutlet UIView *v_deleteHistoryView;

@property (strong, nonatomic) IBOutlet UITableView *tbv_search;
@property (strong) HDUserInfo        *user;
@property (strong) NSMutableArray    *mar_value;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_tbvBottom;
@property (strong) AFHTTPRequestOperation       *op;
@property (strong) NSArray *ary_positionData;

#pragma mark - 临时选择类型
/**
 *  行业
 */
@property (nonatomic,strong)NSString *industryStr;
@property (nonatomic,strong)NSString *industryID;
/**
 *  职位类别
 */
@property (nonatomic,strong)NSString *positionStr;
@property (nonatomic,strong)NSString *positionID;
/**
 *  工作地点
 */
@property (nonatomic,strong)NSString *cityNameStr;
@property (nonatomic,strong)NSString *cityNameID;
/**
 *  用于判断所选类型
 */
@property (nonatomic,assign)NSInteger chooseIndex;
/**
 *  搜索历史缓存
 */
@property (nonatomic,strong)NSMutableArray *ary_searchHistory;
@end

@implementation HDSearchOrderCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    self.tf_bountyText.keyboardType = UIKeyboardTypeNumberPad;
   
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_SEARCH_ORDER");
    _user = [HDGlobalInfo instance].userInfo;
    NSMutableArray *mar_trade  = [HDTradeInfo getTradeInfosWithKeys:[_user.sTradeKey componentsSeparatedByString:@"|"]];
    NSMutableArray *mar_post   = [HDPostInfo getPostItemsWithKeys:[_user.sPostKey componentsSeparatedByString:@"|"]];
    HDAreaItem     *areaItem   = [HDAreaInfo getAreaItemWithkey:_user.sAreaKey];
    NSArray *ar = @[
                    @[
                        (mar_trade? mar_trade: [[NSMutableArray alloc] initWithArray:@[[HDTradeInfo new]]]),
                        (mar_post? mar_post: [[NSMutableArray alloc] initWithArray:@[[HDPostItem new]]]),
                        @[(areaItem? areaItem: [HDAreaItem new])]
                        ]
                    ];
    _mar_value          = [[NSMutableArray alloc] initWithArray:ar];
}



- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self resetupValues];
     self.ary_searchHistory = [NSMutableArray arrayWithArray:[WJSearchOrderCache MR_findAll]];
    [self.tbv_search reloadData];
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
    _lc_tbvBottom.constant = 50;
    [self.view setNeedsUpdateConstraints];
}

- (void)resetupValues{
    NSMutableDictionary *mdc = [HDGlobalInfo instance].mdc_preset;
    if (mdc.count > 1) {
        NSArray *ar = @[(mdc[@KEY_PRESET_TRADE]? mdc[@KEY_PRESET_TRADE]: @[[HDTradeInfo new]]), (mdc[@KEY_PRESET_POST]? mdc[@KEY_PRESET_POST]: @[[HDPostItem new]]),(mdc[@KEY_PRESET_AREA]? mdc[@KEY_PRESET_AREA]: @[[HDAreaItem new]])];
        [_mar_value replaceObjectAtIndex:0 withObject:ar];
        [self.tbv_search reloadData];
    }
}

#pragma mark - 搜索
- (void)searchWithBtn{
    if (!self.positionID&&!self.industryID&&!self.cityNameID&&self.tf_bountyText.text.length == 0) {
        
    }else{
        //数据缓存
        WJSearchOrderCache * searchCache = [WJSearchOrderCache MR_createEntity];
        searchCache.positionId = self.positionID?self.positionID:@"";
        searchCache.positionStr = self.positionStr||![self.positionStr isEqualToString:@"不限"]?self.positionStr:@"";
    
        searchCache.industryId = self.industryID?self.industryID:@"";
        searchCache.industryStr = self.industryStr||![self.industryStr isEqualToString:@"不限"]?self.industryStr:@"";
    
        searchCache.workPlaceId = self.cityNameID?self.cityNameID:@"";
        searchCache.workPlaceStr = self.cityNameStr||![self.cityNameStr isEqualToString:@"不限"]?self.cityNameStr:@"";
        searchCache.keywordStr = self.tf_bountyText.text?self.tf_bountyText.text:@"";
        searchCache.bountyStr =  self.tf_bountyText.text? self.tf_bountyText.text:@"";
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:nil];
    }
        [self getHttpRequest];
}

- (void)getHttpRequest{
     HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.tf_keyword.text?self.tf_keyword.text:@"",@"keyword",
                         self.positionID?self.positionID:@"",@"functionCode",
                         self.industryID?self.industryID:@"",@"businessCode",
                         self.cityNameID?self.cityNameID:@"",@"area",
                         @"",@"userno",
                         @"1",@"rewardMin",
                         @"",@"rewardMax",
                         @"",@"istop",
                         @"",@"isreward",nil];

    [[HDHttpUtility sharedClient] checkPosition:[HDGlobalInfo instance].userInfo typeDic:dic sort:@"1" pageIndex:@"1" size:@"24" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents){
           [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
         WJOrderListCtr *order = [[WJOrderListCtr alloc] initWithPositionDic:dic isOrderList:YES];
        [self.navigationController pushViewController:order animated:YES];
    }];
    
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        NSArray *ar = _mar_value[0];
        [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_TRADE]      = ar[0];
        [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_POST]       = ar[1];
        [HDGlobalInfo instance].mdc_preset[@KEY_PRESET_AREA]       = [[NSMutableArray alloc] initWithArray:ar[2]];
        HDExtendListCtr *ctr = nil;
       // NSObject *obj = ar[indexPath.row];
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:{
                        ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:nil maxSelectCount:1];
                        break;
                    }
                    case 1:{
                        ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost object:nil maxSelectCount:1];
                        break;
                    }
                    case 2:{
                        ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:nil maxSelectCount:1];
                        break;
                    }
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }
        ctr.delegate       = self;
        self.chooseIndex   = indexPath.row;
        [self.navigationController pushViewController:ctr animated:YES];
    }else{
        WJSearchOrderCache * searchCache = self.ary_searchHistory[indexPath.row];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:searchCache.keywordStr?searchCache.keywordStr:@"",@"keyword",
                             searchCache.positionId?searchCache.positionId:@"",@"functionCode",
                             searchCache.industryId?searchCache.industryId:@"",@"businessCode",
                             searchCache.workPlaceId?searchCache.workPlaceId:@"",@"area",
                             @"",@"userno",
                             @"1",@"rewardMin",
                             searchCache.bountyStr?searchCache.bountyStr:@"",@"rewardMax",
                             @"",@"istop",
                             @"",@"isreward",nil];
        
        [[HDHttpUtility sharedClient] checkPosition:[HDGlobalInfo instance].userInfo typeDic:dic sort:@"8" pageIndex:@"1" size:@"24" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSMutableArray *talents){
            if (!isSuccess) {
                [HDUtility mbSay:sMessage];
                return ;
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.tf_keyword.text?self.tf_keyword.text:@"",@"keyword",
                                 self.positionID?self.positionID:@"",@"functionCode",
                                 self.industryID?self.industryID:@"",@"businessCode",
                                 self.cityNameID?self.cityNameID:@"",@"area",
                                 @"",@"userno",
                                 @"1",@"rewardMin",
                                 self.tf_bountyText.text?self.tf_bountyText.text:@"",@"rewardMax",
                                 @"",@"istop",
                                 @"",@"isreward",nil];
            WJOrderListCtr *order = [[WJOrderListCtr alloc] initWithPositionDic:dic isOrderList:YES];
            [self.navigationController pushViewController:order animated:YES];
        }];
    }
}

#pragma mark - UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else{
        return self.ary_searchHistory.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        [self.v_keywordView setFrame:CGRectMake(0, 0,HDDeviceSize.width, 55)];
        return self.v_keywordView;
    }else{
        UILabel * lb_history = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 35)];
        lb_history.text = @"  搜索历史";
        lb_history.textColor = [UIColor colorWithRed:0.66f green:0.66f blue:0.66f alpha:1.00f];
        return self.ary_searchHistory.count==0?nil:lb_history;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 55)];
        footerView.backgroundColor = [UIColor clearColor];
        
        self.btn_search = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btn_search setFrame:CGRectMake(20, 5, HDDeviceSize.width-40, 45)];
        [self.btn_search setTitle:@"搜索" forState:UIControlStateNormal];
        [self.btn_search setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btn_search setBackgroundColor:[UIColor colorWithRed:0.85f green:0.16f blue:0.01f alpha:1.00f]];
        [self.btn_search addTarget:self action:@selector(searchWithBtn) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:self.btn_search];
        return footerView;
    }else{
        [self.v_deleteHistoryView setFrame: CGRectMake(0, 0, HDDeviceSize.width, 55)];
        [self.btn_clearCache addTarget:self action:@selector(clearWihtCaches) forControlEvents:UIControlEventTouchUpInside];
        return self.ary_searchHistory.count==0?nil:self.v_deleteHistoryView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 55;
    }else{
        return 35;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 55;
    }else{
        return 55;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            static NSString *cellIdentifer = @"WJBountyCell";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [self.v_bountyView setFrame: CGRectMake(0, 0, HDDeviceSize.width, 55)];
                [cell.contentView addSubview:self.v_bountyView];
               
            }
            return cell;
        }else{
            static NSString *cellIdentifer = @"WJFindBrokerCell";
            WJFindBrokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
            if (cell == nil) {
                cell = [self getJianCell];
                cell.lc_lineHeight.constant = 0.5f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell updateConstraints];
               
            }
            cell.lb_title.text = @[LS(@"TXT_JJ_ORDER_TRADE"),
                                   LS(@"TXT_JJ_ORDER_POSITION"),
                                   LS(@"TXT_JJ_ORDER_AREAS")][indexPath.row];
            if (indexPath.row == 0) {
                cell.tf_value.text = self.industryStr? self.industryStr: @"不限";
            }else if (indexPath.row == 1){
                cell.tf_value.text = self.positionStr? self.positionStr: @"不限";
            }else if (indexPath.row == 2){
                cell.toViewLeftWidth.constant = cell.toViewRightWidth.constant = - 12.0f;
                cell.tf_value.text =self.cityNameStr? self.cityNameStr: @"不限";
            }
            return cell;
        }
    }else{
        static NSString *cellIdentifer = @"WJDeleteHistoryCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        WJSearchOrderCache * searchCache = self.ary_searchHistory[indexPath.row];
        if (searchCache.keywordStr.length == 0) {
            cell.textLabel.text = [self joiningTogether:[NSArray arrayWithObjects:searchCache.industryStr,searchCache.positionStr,searchCache.workPlaceStr, nil]];
        }else{
            cell.textLabel.text = [self joiningTogether:[NSArray arrayWithObjects:searchCache.keywordStr,searchCache.industryStr,searchCache.positionStr,searchCache.workPlaceStr, nil]];
        }
        return cell;
    }
}

//拼接字符串
- (NSString *)joiningTogether:(NSArray*)ar{
    if (ar.count == 0) {
        return @"";
    }
    NSString * s = ar[0];
    for (int i = 1; i < MIN(ar.count, 3); i++) {
        s = [s stringByAppendingString:FORMAT(@"+%@", ar[i])];
    }
    return s;
    
}

#pragma mark - HDExtendListDelegate 处理返回数据
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    
    if (mar.count == 0) {
        return ;
    }
    if (self.chooseIndex == 0) {
        HDTradeInfo *trade = mar[0];
        self.industryStr = trade.sValue;
        //self.industryStr = [self spliceTheValue:mar];
        self.industryID = trade.sKey;
    }else if (self.chooseIndex == 1){
        HDPostItem *post = mar[0];
        self.positionStr = post.sValue;
        self.positionID = post.sKey;
    }else{
        HDAreaItem *area = mar[0];
        self.cityNameStr = area.sValue;
        self.cityNameID = area.sKey;
    }
    [self.tbv_search reloadData];
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

#pragma mark - 清除历史记录
- (void)clearWihtCaches{
    NSLog(@"清除历史记录");
    for (WJSearchOrderCache * cache in [WJSearchOrderCache MR_findAll]) {
        [cache MR_deleteEntity];
        [[NSManagedObjectContext MR_contextForCurrentThread
          ] MR_saveToPersistentStoreWithCompletion:nil];
    }
    [self.ary_searchHistory removeAllObjects];
    [self.tbv_search reloadData];
}

#pragma mark---TextField隐藏键盘----
//隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];//注:view为TextField的背景View,如Self.View
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
