//
//  WJCheckEmployer.m
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckEmployer.h"
#import "WJEmployerCell.h"

@interface WJCheckEmployer ()
@property (strong) WJPositionInfo   *positionInfo;
@property (strong, nonatomic) IBOutlet UITableView *tbv;
@property (strong) NSMutableArray *mar_images;

@end

@implementation WJCheckEmployer

- (id)initWithInfo:(WJPositionInfo *)info{
    if (self = [super init]) {
        self.positionInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UITableView Datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }else if (indexPath.section == 1){
        NSString *str = self.positionInfo.employerInfo.sRemark;
        CGFloat height = [HDJJUtility heightOfString:str font:[UIFont systemFontOfSize:14] width:HDDeviceSize.width - 40 maxHeight:999999];
        return MAX(height + 45, 90);
    }else{
        CGFloat height = 0;
        for (int i = 0; i < self.mar_images.count; i++) {
            UIImage *img = self.mar_images[i];
            CGFloat ht = HDDeviceSize.width * img.size.height/img.size.width;
            height += ht;
        }
        return height;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.positionInfo.employerInfo.mar_urls.count == 0) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

#pragma mark UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        static NSString *cellIdentifer = @"WJEmployerCell";
        WJEmployerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if (cell == nil) {
            cell = [WJEmployerCell getEmployerCell];
        }
        cell.lb_company.text    = self.positionInfo.employerInfo.sName;
        cell.lb_industry.text   = self.positionInfo.employerInfo.sTradeText;
        cell.lb_property.text   = self.positionInfo.employerInfo.sPropertyText;
        return cell;
    }else if (indexPath.section == 1){
        static NSString *cellIdentifer = @"WJDescribeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, HDDeviceSize.width - 20, 30)];
        description.text = @"雇主描述";
        [cell.contentView addSubview:description];
        
        UIView *v_line = [[UIView alloc] initWithFrame:CGRectMake(10, 34, HDDeviceSize.width, 0.5)];
        v_line.backgroundColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.82f alpha:0.5f];
        [cell.contentView addSubview:v_line];
        
        NSString *str = self.positionInfo.employerInfo.sRemark;
        CGFloat height = [HDJJUtility heightOfString:str font:[UIFont systemFontOfSize:14] width:HDDeviceSize.width - 40 maxHeight:999999];
        UILabel *lb_remark      = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, HDDeviceSize.width- 40, height)];
        lb_remark.text          = str;
        lb_remark.font          = [UIFont systemFontOfSize:14];
        lb_remark.numberOfLines = 0;
        [cell.contentView addSubview:lb_remark];
        return cell;
    }else{
        static NSString *str = @"WJImageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        CGFloat y = 0;
        for (int i = 0; i < self.mar_images.count; i++) {
            UIImage *img = self.mar_images[i];
            CGFloat height = HDDeviceSize.width * img.size.height/img.size.width;
            UIImageView *img_head = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, HDDeviceSize.width, height)];
            y += height;
            img_head.image = img;
            [cell.contentView addSubview:img_head];
        }
        return cell;
    }    
}

#pragma mark - setter and getter
- (void)setup{
    self.navigationItem.title = LS(@"TXT_JJ_CHECK_EMPLOYER");
    self.mar_images = [NSMutableArray new];
}
- (void)setImages{
    for (int i = 0; i < self.positionInfo.employerInfo.mar_urls.count; i++) {
        [HDJJUtility getImage:self.positionInfo.employerInfo.mar_urls[i] withBlock:^(NSString *code, NSString *message, UIImage *img) {
            if (img) {
                [_mar_images addObject:img];
            }
            [self.tbv reloadData];
        }];
    }
}
@end
