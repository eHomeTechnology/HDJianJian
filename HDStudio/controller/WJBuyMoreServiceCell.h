//
//  WJBuyMoreServiceCell.h
//  JianJian
//
//  Created by liudu on 15/6/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBuyMoreServiceCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_head;
@property (strong, nonatomic) IBOutlet UILabel *lb_title;
@property (strong, nonatomic) IBOutlet UILabel *lb_content;

+ (WJBuyMoreServiceCell *)getBuyMoreServiceCell;
@end

@interface WJServiceSuccessCell : UITableViewCell

@property (strong) IBOutlet UIImageView *img_select;
@property (strong) IBOutlet UIView      *v_greenLine;
@property (strong) IBOutlet UIView      *v_grayLine;
@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UILabel     *lb_content;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_contentWithHeight;
- (void)getServiceSuccessData:(NSDictionary*)dic;
+ (WJServiceSuccessCell *)getServiceSuccessCell;
@end