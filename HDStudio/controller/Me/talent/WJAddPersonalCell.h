//
//  WJAddPersonalCell.h
//  JianJian
//
//  Created by liudu on 15/6/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJAddPersonalCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UIView      *v_line;
@property (strong) IBOutlet UITextField *tf_content;
@property (strong) IBOutlet UIView      *v_boy;
@property (strong) IBOutlet UIView      *v_girl;
@property (strong) IBOutlet UIButton    *btn_boy;
@property (strong) IBOutlet UIButton    *btn_girl;
@property (strong) IBOutlet UIImageView *img_boy;
@property (strong) IBOutlet UIImageView *img_girl;
@property (strong) IBOutlet UIImageView *img_down;  // 向下箭头
@property (strong) IBOutlet UILabel     *lb_year;   //年以上

@property (strong) IBOutlet NSLayoutConstraint *lc_downWith_width;
@property (strong) IBOutlet NSLayoutConstraint *lc_yearWithWidth;
+ (WJAddPersonalCell *)getAddPersonalCell;

@end
