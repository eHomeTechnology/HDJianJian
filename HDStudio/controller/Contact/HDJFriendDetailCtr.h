//
//  HDJFriendDetailCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDJFDetailCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_name;
@property (strong) IBOutlet UILabel *lb_rPosition;
@property (strong) IBOutlet UILabel *lb_cCompany;
@property (strong) IBOutlet UILabel *lb_cPosition;
@property (strong) IBOutlet UILabel *lb_workYear;
@property (strong) IBOutlet UILabel *lb_mPhone;
@property (strong) IBOutlet UILabel *lb_eCount;
@property (strong) IBOutlet UILabel *lb_createTime;
@property (strong) IBOutlet UIButton *btn_dialing;
@property (strong) IBOutlet UIButton *btn_progress;

@end


@interface HDJFriendDetailCtr : UIViewController

- (id)initWithJFriendInfo:(HDJFriendInfo *)info;

@end
