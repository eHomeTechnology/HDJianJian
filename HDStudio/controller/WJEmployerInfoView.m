//
//  WJEmployerInfoView.m
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJEmployerInfoView.h"
#import "WJEmployerCell.h"

@interface WJEmployerInfoView ()
{
    NSInteger isFirstAddImage;
}
@property (strong) IBOutlet UITableView *tbv;
@property (strong) NSMutableArray *mar_images;

@end

@implementation WJEmployerInfoView

- (id)initWithFrame:(CGRect)frame{
    self = [[NSBundle mainBundle]loadNibNamed:@"WJEmployerInfoView" owner:self options:nil][0];
    if (!self) {
        return nil;
    }
    self.frame = frame;
    isFirstAddImage = 0;
    self.tbv.delegate = self;
    self.tbv.dataSource = self;
    self.tbv.tableFooterView = [UIView new];
    return self;
}

#pragma mark -
#pragma mark UITableView Datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return _mar_images.count == 0? 2: 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.contentView.frame.size.height + 20;
    }else{
        UIImage *img = _mar_images[indexPath.row];
        return HDDeviceSize.width * img.size.height / img.size.width;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return _mar_images.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 10;
}


#pragma mark UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            static NSString *cellIdentifer = @"WJEmployerCell";
            WJEmployerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
            if (cell == nil) {
                cell = [WJEmployerCell getEmployerCell];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.lb_company.text = _info.employerInfo.sName;
            cell.lb_industry.text = _info.employerInfo.sTradeText;
            cell.lb_property.text = _info.employerInfo.sPropertyText;
            return cell;
        }
        case 1:{
            static NSString *cellIdentifer = @"WJCheckEmployerCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, HDDeviceSize.width-20, 30)];
                description.text = @"雇主描述";
                [cell.contentView addSubview:description];
                
                UIView *v_line = [[UIView alloc] initWithFrame:CGRectMake(0, 35, HDDeviceSize.width, 0.5)];
                v_line.backgroundColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
                [cell.contentView addSubview:v_line];
                
                CGRect rect = [[HDJJUtility flattenHTML:_info.employerInfo.sRemark string:@"\n"] boundingRectWithSize:CGSizeMake(HDDeviceSize.width-30, 1200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:FONTNAME_HelveticaNeueMedium(15)} context:nil];
                UILabel *lb_description = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, rect.size.width, rect.size.height)];
                lb_description.text = [HDJJUtility flattenHTML:_info.employerInfo.sRemark string:@"\n"];
                
                lb_description.font = FONTNAME_HelveticaNeueMedium(14);
                lb_description.numberOfLines = 0;
                cell.contentView.frame = CGRectMake(0, 0, HDDeviceSize.width, 35+rect.size.height);
                [cell.contentView addSubview:lb_description];
            }
            return cell;
        }
        case 2:{
            static NSString *cellIdentifer = @"HDEmployerImageCell";
            HDEmployerImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
            if (cell == nil) {
                cell = [HDEmployerImageCell getCell];
            }
            cell.imv.image  = _mar_images[indexPath.row];
            return cell;
        
        }
        default:
            return nil;
    }
}

- (void)setInfo:(WJPositionInfo *)info{
    _info = info;
    if (!_mar_images) {
        _mar_images = [NSMutableArray new];
    }
    for (int i = 0; i < info.employerInfo.mar_urls.count; i++) {
        [HDJJUtility getImage:info.employerInfo.mar_urls[i] withBlock:^(NSString *code, NSString *message, UIImage *img) {
            if (img) {
                [_mar_images addObject:img];
            }
            [self.tbv reloadData];
        }];
    }
    
}

@end
