//
//  WJPayDetails.m
//  JianJian
//
//  Created by liudu on 15/5/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJPayDetails.h"
#import "WJPayDetaisCell.h"

@interface WJPayDetails ()
@property (strong, nonatomic) IBOutlet UIView       *v_head;
@property (strong, nonatomic) IBOutlet UITableView  *tbv;
@property (strong) WJTradeRecordListInfo            *listInfo;
@property (strong, nonatomic) IBOutlet UILabel *lb_price;

@end

@implementation WJPayDetails

- (id)initWithInfo:(WJTradeRecordListInfo *)info{
    if (!info) {
        Dlog(@"传入参数有误");
        return nil;
    }
    if (self = [super init]) {
        self.listInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableViewHead];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_PAY_DETAILS");
}

- (void)setTableViewHead{
    self.v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 50);
    if ([_listInfo.sTradeTypeText isEqualToString:@"支出"]) {
        self.lb_price.text = FORMAT(@"-%0.2f",[_listInfo.sAmount floatValue]/100);
    }else{
        self.lb_price.text = FORMAT(@"+%0.2f",[_listInfo.sAmount floatValue]/100);
    }
    [self.tbv setTableHeaderView:self.v_head];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"WJPayDetaisCell";
    WJPayDetaisCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil){
        cell = [self getPayDetaisCell];
    }
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    cell.lb_transactType.text   = _listInfo.sTradeTypeText;
    cell.lb_createdTime.text    = _listInfo.sCreatedTime;
    cell.lb_transactID.text     = _listInfo.sTransactID;
    cell.lb_otherNickName.text  = _listInfo.sOtherNickName;
    cell.lb_content.text        = _listInfo.sContent;
    cell.lc_content.constant    = [self viewHeight:cell.lb_content.text uifont:14];
    return cell;
}

- (WJPayDetaisCell *)getPayDetaisCell{
    WJPayDetaisCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJPayDetaisCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJPayDetaisCell class]]) {
            cell = (WJPayDetaisCell *)obj;
            break;
        }
    }
    return cell;
}

//自适应高度度
-(CGFloat)viewHeight:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake([UIScreen mainScreen].bounds.size.width-85-35, 500.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat height = size.height;
    return height;
}

@end
