//
//  HDBlogPositionView.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogPositionView.h"
#import "HDBlogPositionCell.h"

@interface HDBlogPositionView(){
    HDBlogInfo *blogInfo;
}
@end

@implementation HDBlogPositionView
@synthesize blogInfo = blogInfo;

- (void)setBlogInfo:(HDBlogInfo *)blog{
    blogInfo            = blog;
    _btn_extend.hidden  = blog.ar_positions.count < 3;
    _lc_heightExtend.constant = blog.ar_positions.count < 3? 0.: 44.;
    [_btn_extend setSelected:blogInfo.isExtended];
    BOOL isNotNeedExtend = blog.ar_positions.count <= 2;
    _btn_extend.hidden = isNotNeedExtend;
    _lc_heightExtend.constant = isNotNeedExtend? 0.: 44.;
    [self updateConstraints];
    [_tbv reloadData];
}

+ (CGFloat)heightOfBlogPositionView:(HDBlogInfo *)blog{
    CGFloat height = 0.;
    CGFloat h = HDDeviceSize.width == 320? 90:(HDDeviceSize.width == 375? 100: 110);
    if (blog.isExtended) {
        for (int i = 0; i < blog.ar_positions.count; i++) {
            WJPositionInfo *p = blog.ar_positions[i];
            height = height + (p.employerInfo.mar_urls.count > 0? (60+h): 60);
        }
        return height + 44;
    }
    for (int i = 0; i < MIN(blog.ar_positions.count, 2); i++) {
        WJPositionInfo *p = blog.ar_positions[i];
        height = height + (p.employerInfo.mar_urls.count > 0? (60+h): 60);
    }
    if (blog.ar_positions.count <= 2) {
        return height;
    }
    return height + 44;
}


- (IBAction)doExtend:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(blogPositionView:)]) {
        [self.delegate blogPositionView:self];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    WJPositionInfo *position = blogInfo.ar_positions[indexPath.row];
    Dlog(@"position = %@", position.sPositionName);
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_BLOG_CELL_POSITION_ACTION object:position userInfo:@{@"key": @"position"}];
}

#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WJPositionInfo *position = blogInfo.ar_positions[indexPath.row];
    CGFloat height = HDDeviceSize.width == 320? 90:(HDDeviceSize.width == 375? 100: 110);
    if (position.employerInfo.mar_urls.count > 0) {
        return 60 + height;
    }
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return blogInfo.ar_positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"HDBlogPositionCell";
    HDBlogPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [HDBlogPositionCell getBlogPositionCell];
    }
    WJPositionInfo *position    = blogInfo.ar_positions[indexPath.row];
    cell.lb_positionName.text   = position.sPositionName;
    cell.imv_shang.hidden       = !position.sReward.length;
    cell.lb_reward.hidden       = !position.sReward.length;
    cell.lb_reward.text         = position.sReward;
    cell.lc_rewardWidth.constant= [HDJJUtility withOfString:cell.lb_reward.text font:cell.lb_reward.font widthMax:100];
    [cell updateConstraints];
    NSString *str               = position.sSalaryText.length > 0? position.sSalaryText: @"";
    if (position.sAreaText.length > 0) {
        [str stringByAppendingString:str.length > 0? FORMAT(@" | %@", position.sAreaText): position.sAreaText];
    }
    if (position.employerInfo.sName.length > 0) {
        [str stringByAppendingString:str.length > 0? FORMAT(@" | %@", position.employerInfo.sName): position.employerInfo.sName];
    }
    for (UIImageView *imv in @[cell.imv0, cell.imv1, cell.imv2]) {
        [imv setImage:nil];
    }
    cell.lb_subscribe.text      = str;
    for (int i = 0; i < position.employerInfo.mar_urls.count; i++) {
        [HDJJUtility getImage:position.employerInfo.mar_urls[i] withBlock:^(NSString *code, NSString *message, UIImage *img) {
            UIImageView *imv =  @[cell.imv0, cell.imv1, cell.imv2][i];
            if (code.integerValue == 0) {
                [imv setImage:img];
                return ;
            }
            [imv setImage:HDIMAGE(@"icon_jian")]    ;
        }];
    }
    return cell;
}


@end
