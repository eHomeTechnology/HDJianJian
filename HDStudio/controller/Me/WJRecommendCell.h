//
//  WJRecommendCell.h
//  JianJian
//
//  Created by liudu on 15/6/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJRecommendCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UITextField *tf_content;
@property (strong) IBOutlet UIButton    *btn_check;

+ (WJRecommendCell *)getRecommendCell;

@end

@interface WJRecommendCell0 : UITableViewCell
@property (strong) IBOutlet UITextView *tv_content;

+ (WJRecommendCell0 *)getRecommendCell0;

@end