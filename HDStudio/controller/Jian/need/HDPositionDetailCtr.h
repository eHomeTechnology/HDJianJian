//
//  HDPositionDetailCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDPositionDetailCell0 : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UILabel     *lb_salary;
@property (strong) IBOutlet UILabel     *lb_deposit0;
@property (strong) IBOutlet UILabel     *lb_deposit1;
@property (strong) IBOutlet UILabel     *lb_address;
@property (strong) IBOutlet UILabel     *lb_education;
@property (strong) IBOutlet UILabel     *lb_workYear;
@property (strong) IBOutlet UILabel     *lb_company;
@property (strong) IBOutlet UIButton    *btn_company;
@property (strong) IBOutlet UIButton    *btn_setSalary;
+ (HDPositionDetailCell0 *)getCell0;

@end

@interface HDPositionDetailCell1 : UITableViewCell

@property (strong) IBOutlet UITextView *tv_content;
+ (HDPositionDetailCell1 *)getCell1;

@end

@interface HDPositionDetailCtr : UIViewController

- (id)initWithPosition:(NSString *)positionId isOnShelve:(BOOL)isOn;

@end
