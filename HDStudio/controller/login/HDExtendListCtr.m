//
//  HDExtendListCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/31.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDExtendListCtr.h"
#import "MJNIndexView.h"
#import "CCLocationManager.h"
#import "HDJJUtility.h"


#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

@implementation HDExtendCell

+ (HDExtendCell *)getCell{
    HDExtendCell *cell  = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"HDExtendCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDExtendCell class]]) {
            cell = (HDExtendCell *)obj;
            break;
        }
    }
    return cell;
}

@end

@interface HDExtendListCtr ()<MJNIndexViewDataSource, CLLocationManagerDelegate>{

    CLLocationManager   *locationmanager;
    NSMutableArray      *mar_selectedItems;
    int                 iMaxCount;
}

@property (strong) IBOutlet UITableView     *tbv;
@property (strong) IBOutlet UILabel         *lb_curTitle;
@property (strong) IBOutlet UILabel         *lb_curValue;
@property (strong) NSMutableArray           *mar_values;
@property (assign) HDExtendType             extendType;
@property (strong) MJNIndexView             *indexView;

@end

@implementation HDExtendListCtr

- (id)initWithExtendType:(HDExtendType)type object:(id)object maxSelectCount:(int)count{
    if (self = [self initWithExtendType:type withObject:object]) {
        iMaxCount   = count;
    }
    return self;
}

- (id)initWithExtendType:(HDExtendType)type withObject:(id)object{
    
    if (self = [super init]) {
        _extendType = type;
        if (object) {
            if ([object isKindOfClass:[NSArray class]]) {
                mar_selectedItems = [[NSMutableArray alloc] initWithArray:object];
            }else if ([object isKindOfClass:[NSString class]]){
                NSString *key = object;
                NSArray *ar = [key componentsSeparatedByString:@"|"];
                mar_selectedItems = [NSMutableArray new];
                for (int i = 0; i < ar.count; i++) {
                    NSString *str = ar[i];
                    HDValueItem *value = [HDValueItem getValueInfoWithKey:str type:type];
                    if (!value) {
                        Dlog(@"Error:未找到对应全局变量值");
                        continue;
                    }
                    [mar_selectedItems addObject:value];
                }
            }
            
        }else{
            mar_selectedItems = [NSMutableArray new];
        }
        switch (type) {
            case HDExtendTypeArea:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_area];
                if (mar_selectedItems.count == 0) {
                    [UIApplication sharedApplication].idleTimerDisabled = TRUE;
                    locationmanager     = [[CLLocationManager alloc] init];
                    [locationmanager requestAlwaysAuthorization];
                    [locationmanager requestWhenInUseAuthorization];
                    locationmanager.delegate    = self;
                }
                
                break;
            }
            case HDExtendTypeTrade:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_trade];
                break;
            }
            case HDExtendTypePost:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_post];
                break;
            }
            case HDExtendTypeWorkExp:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_workExp];
                break;
            }
            case HDExtendTypeSalary:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_salary];
                break;
            }
            case HDExtendTypeEducation:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_education];
                break;
            }
            case HDExtendTypeProperty:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_property];
                break;
            }
            case HDExtendTypeBank:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_bank];
                break;
            }
            case HDExtendTypeReward:{
                self.mar_values     = [[NSMutableArray alloc] initWithArray:[HDGlobalInfo instance].mar_reward];
                break;
            }
            default:
                break;
        }
        //插入不限
        if (type == HDExtendTypeArea || type == HDExtendTypePost) {
            HDAreaItem *item    = [HDAreaItem new];
            item.sValue         = @"不限";
            item.sKey           = @"0";
            HDAreaInfo *info    = [[HDAreaInfo alloc] init];
            info.sValue         = @"不限";
            info.sKey           = @"0";
            [info.mar_items addObject:item];
            [self.mar_values insertObject:info atIndex:0];
        }else{
            HDValueItem *info   = [HDValueItem new];
            info.sValue         = @"不限";
            info.sKey           = @"0";
            [self.mar_values insertObject:info atIndex:0];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetGlobalVeriable];
}

- (void)viewDidLayoutSubviews{
    if (!self.indexView) {
        self.indexView = [[MJNIndexView alloc] initWithFrame:self.tbv.frame];
        self.indexView.dataSource = self;
        self.indexView.fontColor = [UIColor blueColor];
        [self.view addSubview:self.indexView];
        [self.view bringSubviewToFront:self.indexView];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark MJNIndexViewDataSource
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    if (_extendType == HDExtendTypeArea || _extendType == HDExtendTypePost) {
        NSMutableArray *mar_section = [NSMutableArray new];
        for (int i = 0; i < self.mar_values.count; i++) {
            HDAreaInfo *info = self.mar_values[i];
            if (info.sValue.length == 0) {
                continue;
            }
            if (info.sValue.length > 4) {
                NSString *s = FORMAT(@"%@..", [info.sValue substringToIndex:3]);
                [mar_section addObject:s];
                continue;
            }
            [mar_section addObject:info.sValue];
        }
        return mar_section;
    }
    return nil;
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    [self.tbv scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0  inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        [mar_selectedItems removeAllObjects];
    }else{
        for (HDValueItem *info in mar_selectedItems) {
            if ([info.sValue isEqualToString:@"不限"] || [info.sKey intValue] < 0) {
                [mar_selectedItems removeObject:info];
            }
        }
    }
    switch (_extendType) {
        case HDExtendTypeArea:{
            mar_selectedItems = [NSMutableArray new];
            HDAreaInfo  *info = _mar_values[indexPath.section];
            HDAreaItem  *item = info.mar_items[indexPath.row];
            [mar_selectedItems addObject:item];
            _lb_curValue.text = item.sValue;
            [_tbv reloadData];
            break;
        }
        case HDExtendTypePost:{
            HDPostInfo *postInfo = _mar_values[indexPath.section];
            HDPostItem *item = postInfo.mar_items[indexPath.row];
            if (iMaxCount == 1) {
                mar_selectedItems = [NSMutableArray new];
                [mar_selectedItems addObject:item];
                _lb_curValue.text = item.sValue;
                [_tbv reloadData];
                return;
            }
            for (HDPostItem *postItem in mar_selectedItems) {
                if ([postItem.sKey isEqualToString:item.sKey]) {
                    [mar_selectedItems removeObject:postItem];
                    _lb_curValue.text   = [self spliceTheValue:mar_selectedItems];
                    [self.tbv reloadData];
                    return;
                }
            }
            if (mar_selectedItems.count > iMaxCount-1) {
                [HDUtility mbSay:FORMAT(@"只能选%d项", iMaxCount)];
                return;
            }
            HDPostInfo *pInfo = _mar_values[indexPath.section];
            [mar_selectedItems addObject:pInfo.mar_items[indexPath.row]];
            _lb_curValue.text   = [self spliceTheValue:mar_selectedItems];
            [self.tbv reloadData];
            break;
        }
        case HDExtendTypeTrade:{
            HDTradeInfo *trade = _mar_values[indexPath.row];
            if (iMaxCount == 1) {
                mar_selectedItems = [NSMutableArray new];
                [mar_selectedItems addObject:trade];
                _lb_curValue.text = trade.sValue;
                [_tbv reloadData];
                return;
            }
            for (HDTradeInfo *tradeInfo in mar_selectedItems) {
                if ([tradeInfo.sKey isEqualToString:trade.sKey]) {
                    [mar_selectedItems removeObject:tradeInfo];
                    _lb_curValue.text   = [self spliceTheValue:mar_selectedItems];
                    [self.tbv reloadData];
                    return;
                }
            }
            if (mar_selectedItems.count > 2) {
                [HDUtility mbSay:@"只能选3项"];
                return;
            }
            HDTradeInfo *pInfo  = _mar_values[indexPath.row];
            [mar_selectedItems addObject:pInfo];
            _lb_curValue.text   = [self spliceTheValue:mar_selectedItems];
            [self.tbv reloadData];
            break;
        }
        case HDExtendTypeWorkExp:
        case HDExtendTypeSalary:
        case HDExtendTypeProperty:
        case HDExtendTypeBank:
        case HDExtendTypeReward:
        case HDExtendTypeEducation:{
            mar_selectedItems   = [NSMutableArray new];
            HDValueItem *info   = _mar_values[indexPath.row];
            [mar_selectedItems addObject:info];
            _lb_curValue.text   = info.sValue;
            [_tbv reloadData];
            break;
        }
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_extendType == HDExtendTypeArea || _extendType == HDExtendTypePost){
        HDAreaInfo *info = self.mar_values[section];
        return info.sValue;
    }
    if (_extendType == HDExtendTypeTrade) {
        return @"所有行业";
    }
    return @"所有年限";
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_extendType == HDExtendTypeArea || _extendType == HDExtendTypePost){
        return self.mar_values.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_extendType == HDExtendTypeArea || _extendType == HDExtendTypePost){
        HDAreaInfo *info = _mar_values[sectionIndex];
        return info.mar_items.count;
    }
    return _mar_values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HDExtendCell *cell  = [HDExtendCell getCell];
    cell.imv_icon.image = HDIMAGE(@"iconRead");
    if (_extendType == HDExtendTypeArea || _extendType == HDExtendTypePost){
        HDAreaInfo *info    = self.mar_values[indexPath.section];
        HDAreaItem *item    = info.mar_items[indexPath.row];
        cell.lb_title.text  = item.sValue;
        for (int i = 0; i < mar_selectedItems.count; i++) {
            if ([item.sKey isEqualToString:((HDAreaItem *)mar_selectedItems[i]).sKey]) {
                cell.imv_icon.image = HDIMAGE(@"iconReadHi");
            }
        }
        return cell;
    }
    HDValueItem *info = _mar_values[indexPath.row];
    cell.lb_title.text  = info.sValue;
    for (int i = 0; i < mar_selectedItems.count; i++) {
        HDValueItem *selected = mar_selectedItems[i];
        if ([selected.sKey isEqualToString:info.sKey]) {
            cell.imv_icon.image = HDIMAGE(@"iconReadHi");
        }
    }
    return cell;
}
#pragma mark -
#pragma mark Privite

-(void)getCity
{
    __weak HDExtendListCtr *wself = self;
    [[CCLocationManager shareLocation] getCity:^(NSString *cityString) {
        if (mar_selectedItems.count > 0) {//用户此时如果点击cell选择了城市，中断定位
            return ;
        }
        [wself.lb_curValue setText:cityString];
        for (int i = 0; i < _mar_values.count; i++) {
            HDAreaInfo *info = _mar_values[i];
            for (int j = 0; j < info.mar_items.count; j++) {
                HDAreaItem *item = info.mar_items[j];
                if ([item.sValue isEqualToString:cityString]) {
                    [mar_selectedItems addObject:item];
                    return;
                }
            }
        }
    }];
}

- (void)httpGetGlobalVeriable{
    if ([HDGlobalInfo instance].mar_area.count == 0) {
        [[HDJJUtility new] httpGetGlobalVariable:^(BOOL isSuc) {
            if (!isSuc) {
                return ;
            }
            [self.tbv reloadData];
        }];
    }
}
- (NSString *)spliceTheValue:(NSArray *)ar{
    if (ar.count == 0) {
        return @"";
    }
    NSString *s = ((HDAreaItem *)ar[0]).sValue;
    for (int i = 1; i < MIN(ar.count, iMaxCount); i++) {
        s = [s stringByAppendingString:FORMAT(@"+%@", ((HDAreaItem *)ar[i]).sValue)];
    }
    return s;
}
#pragma mark -
#pragma mark Event and Rsponde
- (void)doConfirm:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(extendListFinalChooseValue:type:)]) {
        [self.delegate extendListFinalChooseValue:mar_selectedItems type:_extendType];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(extendListFinalChooseValueWithKey:type:)]) {
        NSString *sKey = @"";
        for (int i = 0; i < mar_selectedItems.count; i++) {
            HDValueItem *info = mar_selectedItems[i];
            sKey = [sKey stringByAppendingString:FORMAT(@"|%@", info.sKey)];
        }
        if ([sKey hasPrefix:@"|"]) {
            sKey = [sKey substringFromIndex:1];
        }
        [self.delegate extendListFinalChooseValueWithKey:[sKey isEqualToString:@"0"]? @"": sKey type:_extendType];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark Getter and Setter

- (void)setup{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"TXT_CONFIRM") style:UIBarButtonItemStylePlain target:self action:@selector(doConfirm:)];
    [self.tbv registerClass:[HDExtendCell class] forCellReuseIdentifier:@"HDExtendCell"];
    [self.tbv registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    _lb_curTitle.text           = LS(@"选择的项目");
    self.navigationItem.title   = LS(@"请选择");
    switch (_extendType) {
        case HDExtendTypeArea:{
            self.navigationItem.title   = LS(@"TXT_TITLE_SELECT_YOUR_CITY");
            _lb_curTitle.text       = LS(@"TXT_CURRENT_CITY");
            if (mar_selectedItems.count > 0) {
                HDAreaItem *item    = mar_selectedItems[0];
                _lb_curValue.text   = item.sValue;
                return;
            }
            _lb_curValue.text   = LS(@"TXT_LOCATE_...");
            [self getCity];
            break;
        }
        case HDExtendTypeTrade:
        case HDExtendTypePost:{
            NSString *s = nil;
            if (mar_selectedItems.count > 0) {
                s = [self spliceTheValue:mar_selectedItems];
            }
            _lb_curValue.text   = s;
            break;
        }
        case HDExtendTypeWorkExp:
        case HDExtendTypeSalary:
        case HDExtendTypeProperty:
        case HDExtendTypeBank:
        case HDExtendTypeReward:
        case HDExtendTypeEducation:{
            HDValueItem *info = nil;
            if (mar_selectedItems.count > 0) {
                info   = mar_selectedItems[0];
            }
            _lb_curValue.text   = info.sValue;
            break;
        }
        default:
            break;
    }
}
@end
