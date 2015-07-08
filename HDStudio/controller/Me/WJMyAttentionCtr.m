//
//  WJMyAttentionCtr.m
//  JianJian
//
//  Created by liudu on 15/7/7.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJMyAttentionCtr.h"
#import "WJBrokerCell.h"
#import "HDChatViewCtr.h"

@interface WJMyAttentionCtr ()

@property (strong) IBOutlet UITableView     *tbv;
@property (strong) IBOutlet UILabel         *lb_null;
@property (strong) IBOutlet UIImageView     *v_null;
@property (strong) NSString                 *typeStr;
@property (strong) NSMutableArray           *listAry;

@end

@implementation WJMyAttentionCtr

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -- UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"WJBrokerCell";
    WJBrokerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [WJBrokerCell getBrokerCell];
    }
    WJLinkmanListInfo *listInfo = [self.listAry objectAtIndex:indexPath.row];
    cell.lb_name.text = listInfo.sNickName;
    cell.lc_nameWithWidth.constant  = [self viewWidth:listInfo.sNickName uifont:17];
    cell.lb_place.text              = listInfo.sWorkPlaceText;
    if (listInfo.sWorkPlaceText.length == 0) {
        cell.img_location.hidden    = YES;
    }else{
        cell.img_location.hidden    = NO;
    }
    cell.lb_industry.text           = FORMAT(@"%@ | %@",listInfo.sCurPosition, listInfo.sCurCompany);
    if (listInfo.sCurPosition.length == 0 && listInfo.sCurCompany.length == 0) {
        cell.lb_industry.text       = @"";
    }
    cell.lb_position.text           = listInfo.sFunctionText;
    [HDJJUtility getImage:listInfo.sAvatar withBlock:^(NSString *code, NSString *message, UIImage *img) {
        cell.imv_head.image         = img;
    }];
     cell.img_certification.hidden  = !listInfo.sRoleType.boolValue;
    if (listInfo.IsFocus) {
        cell.img_add.image          = HDIMAGE(@"icon_chatRed");
        cell.lb_add.text            = @"聊天";
        cell.btn_addAttention.tag   = indexPath.row;
        [cell.btn_addAttention addTarget:self action:@selector(addAttention:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.img_add.image          = HDIMAGE(@"icon_addAttention");
        cell.lb_add.text            = @"加关注";
        cell.btn_addAttention.tag   = indexPath.row;
        [cell.btn_addAttention addTarget:self action:@selector(addAttention:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

//自适应宽度
-(CGFloat)viewWidth:(NSString*)str uifont:(int)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font],NSFontAttributeName, nil];
    CGSize constraint = CGSizeMake(120, 20.0f);
    CGSize  size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat width = size.width+1;
    return width;
}


#pragma mark - Event and Respond
- (void)addAttention:(UIButton *)btn{
    WJLinkmanListInfo *listInfo = [self.listAry objectAtIndex:btn.tag];
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    if (listInfo.IsFocus) {
        HDChatViewCtr *ctr = [[HDChatViewCtr alloc] initWithChatterId:listInfo.sUserID];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark -
#pragma mark getter and setter

- (void)setup{
    self.navigationItem.title   = LS(@"WJ_TITLE_MY_ATTENTION");
   // self.navigationItem.title   = LS(@"WJ_TITLE_MY_FANS");
    self.tbv.separatorStyle =  UITableViewCellSeparatorStyleNone;
}

@end


