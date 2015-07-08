//
//  HDSelectDescCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDSelectDescCtr.h"
#import "WJPositionInfo.h"
#import "HDNewPositionCtr.h"
#import "HDTableView.h"

#define HEIGHT_CELL_NORMAL 222

@implementation ExtendButton

@end

@implementation HDSelectDescCell

@end

@interface HDSelectDescCtr (){

}

@property (strong) IBOutlet HDTableView *tbv;
@property (strong) NSArray              *ar_positions;
@property (strong) NSMutableArray       *mar_height;
@property (strong) IBOutlet UIView      *v_head;
@end

@implementation HDSelectDescCtr

- (id)initWithPositions:(NSArray *)ar{
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:ar];
    for (int i = 0; i < mar.count; i++) {
        WJPositionInfo *info = mar[i];
        if (info.sRemark.length == 0) {
            [mar removeObject:info];
            i = 0;
        }
    }
    if (self = [super init]) {
        _ar_positions = mar;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_SELECT_PSTI_DESC");
    _v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 44);
    self.tbv.tableHeaderView = _v_head;
    _mar_height = [NSMutableArray new];
    for (int i = 0; i < _ar_positions.count; i++) {
        [_mar_height addObject:@(HEIGHT_CELL_NORMAL)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cellExtendAction:(ExtendButton *)sender{
    if (((NSNumber *)_mar_height[sender.tag]).floatValue > HEIGHT_CELL_NORMAL) {
        [_mar_height replaceObjectAtIndex:sender.tag withObject:@(HEIGHT_CELL_NORMAL)];
        [_tbv reloadData];
        return;
    }
    [_mar_height replaceObjectAtIndex:sender.tag withObject:@(sender.height+62)];
    [_tbv reloadData];
}

- (void)cellImportAction:(ExtendButton *)sender{
    if (self.descDelegate && [self.descDelegate respondsToSelector:@selector(selectDescDelegate:)]) {
        [self.descDelegate selectDescDelegate:sender.position];
    }
    for (UIViewController *ctr in self.navigationController.viewControllers) {
        if ([ctr isKindOfClass:[HDNewPositionCtr class]]) {
            [self.navigationController popToViewController:ctr animated:YES];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((NSNumber *)_mar_height[indexPath.section]).floatValue;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.ar_positions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer = @"HDSelectDescCell";
    HDSelectDescCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [self getCell];
    }
    
    WJPositionInfo *position    = _ar_positions[indexPath.section];;
    CGSize size = [position.sRemark boundingRectWithSize:CGSizeMake(HDDeviceSize.width-60, 9999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:14]}
                                                 context:nil].size;
    cell.btn_extend.hidden = NO;
    if (size.height < 160) {
        cell.btn_extend.hidden = YES;
    }
    [cell.btn_extend setBackgroundImage:HDIMAGE(@"btn_extend") forState:UIControlStateNormal];
    if (((NSNumber *)_mar_height[indexPath.section]).floatValue > HEIGHT_CELL_NORMAL) {
        [cell.btn_extend setBackgroundImage:HDIMAGE(@"btn_contract") forState:UIControlStateNormal];
    }
    cell.btn_extend.height      = size.height;
    cell.btn_import.position    = position;
    cell.tv.text                = position.sRemark;
    cell.btn_extend.tag         = indexPath.section;
    cell.btn_import.tag         = indexPath.section;
    [cell.btn_extend  addTarget:self action:@selector(cellExtendAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_import  addTarget:self action:@selector(cellImportAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (HDSelectDescCell *)getCell{
    HDSelectDescCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDSelectDescCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDSelectDescCell class]]) {
            cell = (HDSelectDescCell *)obj;
            break;
        }
    }
    return cell;
}

@end
