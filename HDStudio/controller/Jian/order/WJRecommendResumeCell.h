//
//  WJRecommendResumeCell.h
//  JianJian
//
//  Created by liudu on 15/4/29.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJRecommendResumeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lb_title;
@property (strong, nonatomic) IBOutlet UITextField *tf_content;
@property (strong, nonatomic) IBOutlet UILabel *lb_workYears;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lc_workYearsWidth;
+ (WJRecommendResumeCell *)getRecommendResumeCell;
@end
