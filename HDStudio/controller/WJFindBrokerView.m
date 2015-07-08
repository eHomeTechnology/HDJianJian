//
//  WJFindBrokerView.m
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJFindBrokerView.h"
#import "HDTableView.h"
#import "HDExtendListCtr.h"
#import "WJBrokerListCtr.h"
#import "WJSearchCell.h"

@interface WJFindBrokerView()<UINavigationControllerDelegate, HDExtendListDelegate>{
    UIButton *btn_search;
}
@property (strong) HDTableView         *tbv;
@property (strong) HDUserInfo                   *user;
@property (strong) NSMutableArray               *mar_value;
@property (strong) AFHTTPRequestOperation       *op;


#pragma mark - 临时选择类型
/**
 *  擅长行业
 */
@property (nonatomic,strong)NSString *sIndustryName;
@property (nonatomic,strong)NSString *sIndustryKey;
/**
 *  擅长职位
 */
@property (nonatomic,strong)NSString *sPositionName;
@property (nonatomic,strong)NSString *sPositionKey;
/**
 *  工作年限
 */
@property (nonatomic,strong)NSString *sWorkTimeName;
@property (nonatomic,strong)NSString *sWorkTimeKey;
/**
 *  所在城市
 */
@property (nonatomic,strong)NSString *sCityName;
@property (nonatomic,strong)NSString *sCityKey;
/**
 *  用于判断所选类型
 */
@property (nonatomic,assign)NSInteger chooseIndex;
@end

@implementation WJFindBrokerView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.tbv = [[HDTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    self.tbv.delegate = self;
    self.tbv.dataSource = self;
    [self addSubview:self.tbv];
    [self setTableHeader];
    [self setTableFooter];
    return self;
}

- (void)setTableHeader{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tbv.frame.size.width, 55)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0,0, HDDeviceSize.width, 1.0f)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.882 alpha:1.000];
    [headerView addSubview:lineView];

    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(19, 12, 70, 30)];
    titleLab.text = @"关键字";
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor darkGrayColor];
    [headerView addSubview:titleLab];
    
    UIView * searchView = [[UIView alloc]initWithFrame:CGRectMake(90, 12,HDDeviceSize.width-100 , 30)];
    searchView.backgroundColor = [UIColor colorWithWhite:0.882 alpha:1.000];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 3, 23, 23)];
    imageView.image = [UIImage imageNamed:@"icon_search"];
    [searchView addSubview:imageView];
    UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(35, 0, searchView.frame.size.width-40, 30)];
    textField.placeholder = @"请输入关键字/昵称/荐荐号";
    textField.delegate = self;
    textField.tag   = 999;
    [searchView addSubview:textField];
    [headerView addSubview:searchView];
    [self.tbv setTableHeaderView:headerView];
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
    UITextField *textField = (UITextField *)[self viewWithTag:999];
    if (textField.text.length == 1){
        [HDUtility mbSay:@"请输入2个及其以上关键字"];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"keyword",
                         self.sPositionKey? self.sPositionKey: @"",@"functionCode",
                         self.sIndustryKey? self.sIndustryKey: @"", @"businessCode",
                         self.sWorkTimeKey? self.sWorkTimeKey: @"", @"startworkDT",
                         self.sCityKey? self.sCityKey: @"", @"area",
                         @"",@"roleType",
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
        
        if ([self.bDelegate respondsToSelector:@selector(toFindBrokerViewController:)]) {
            [self.bDelegate toFindBrokerViewController:list];
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDExtendListCtr *ctr = nil;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    
                    break;
                }
                    break;
                case 1:
                {
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    break;
                }
                    break;
                case 2:
                {
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeWorkExp object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    break;
                }
                    break;
                case 3:
                {
                    ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:nil maxSelectCount:1];
                    ctr.delegate = self;
                    break;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    ctr.delegate        = self;
    self.chooseIndex    = indexPath.row;
    
    if ([self.bDelegate respondsToSelector:@selector(toFindBrokerViewController:)]) {
        [self.bDelegate toFindBrokerViewController:ctr];
    }
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

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"WJSearchCell";
    WJSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [WJSearchCell getJianCell];
        cell.lc_lineHeight.constant = 0.5f;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell updateConstraints];
    }
    cell.lb_title.text = @[LS(@"WJ_SEARCH_BROKER_BUSINESS"),
                           LS(@"WJ_SEARCH_BROKER_POSITION"),
                           LS(@"WJ_SEARCH_BROKER_WORKYEARS"),
                           LS(@"WJ_SEARCH_BROKER_CITY")
                           ][indexPath.row];
    
    if (indexPath.row == 0) {
        cell.tf_value.text = self.sIndustryName? self.sIndustryName: @"不限";
    }else if (indexPath.row == 1){
        cell.tf_value.text = self.sPositionName? self.sPositionName: @"不限";
    }else if (indexPath.row == 2){
        cell.tf_value.text = self.sWorkTimeName? self.sWorkTimeName: @"不限";
    }else{
        cell.toViewLeftWidth.constant = cell.toViewRightWidth.constant = - 12.0f;
        cell.tf_value.text = self.sCityName? self.sCityName: @"不限";
    }
    return cell;
}

#pragma mark - HDExtendListDelegate 处理返回数据
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    
    if (mar.count == 0) {
          Dlog(@"Error:回调返回参数有误");
        return ;
    }
    HDValueItem *valueInfo = mar[0];
    switch (type) {
        case HDExtendTypeTrade:
        {
            self.sIndustryName  = valueInfo.sValue;
            self.sIndustryKey   = valueInfo.sKey;
        }
            break;
        case HDExtendTypePost:
        {
            self.sPositionName  = valueInfo.sValue;
            self.sPositionKey   = valueInfo.sKey;
        }
            break;
        case HDExtendTypeWorkExp:
        {
            self.sWorkTimeName  = valueInfo.sValue;
            self.sWorkTimeKey   = valueInfo.sKey;
        }
            break;
        case HDExtendTypeArea:
        {
            self.sCityName  = valueInfo.sValue;
            self.sCityKey   = valueInfo.sKey;
        }
            break;
            
        default:
            break;
    }
    [self.tbv reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];//注:view为TextField的背景View,如Self.View
}

- (void)clear{
    self.sIndustryName  = nil;
    self.sCityName      = nil;
    self.sWorkTimeName  = nil;
    self.sPositionName  = nil;
    [self.tbv reloadData];
}

@end
