//
//  WJSearchCell.h
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJSearchCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lb_title;
@property (strong, nonatomic) IBOutlet UILabel *tf_value;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toViewLeftWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toViewRightWidth;
@property (strong) IBOutlet NSLayoutConstraint *lc_lineHeight;
+ (WJSearchCell *)getJianCell;
@end
