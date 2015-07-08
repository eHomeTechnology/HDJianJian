//
//  WJEvaluateResumeCell.h
//  JianJian
//
//  Created by Ri on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsView.h"
@interface WJEvaluateResumeCell : UITableViewCell<StarsViewDelegate>
/**
 *  专业能力
 */
@property (weak, nonatomic) IBOutlet StarsView *v_professional;
@property (strong,nonatomic)NSString * str_professional;

/**
*  管理能力
*/
@property (weak, nonatomic) IBOutlet StarsView *v_management;
@property (strong,nonatomic)NSString * str_management;

/**
*  沟通能力
*/
@property (weak, nonatomic) IBOutlet StarsView *v_communication;
@property (strong,nonatomic)NSString * str_communication;

/**
*  职业素养
*/
@property (weak, nonatomic) IBOutlet StarsView *v_professionalQuality;
@property (strong,nonatomic)NSString * str_professionalQuality;

/**
*  工作态度
*/
@property (weak, nonatomic) IBOutlet StarsView *v_workAttitude;
@property (strong,nonatomic)NSString * str_workAttitude;

/**
 *  总体评价
 */
+ (WJEvaluateResumeCell *)getCell;

@end


@interface HDDescribeCell : UITableViewCell

@property (strong) IBOutlet UITextView *tv;
+ (HDDescribeCell *)getCell;

@end
