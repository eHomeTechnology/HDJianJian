//
//  HDJJFriendsCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDJJFriendCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_name;
@property (strong) IBOutlet UILabel     *lb_company;
@property (strong) IBOutlet UILabel     *lb_position;
@property (strong) IBOutlet UILabel     *lb_phone;
@property (strong) IBOutlet UILabel     *lb_time;
@property (strong) IBOutlet UIButton    *btn_dialing;

@end

@interface HDJJFriendsCtr : UIViewController

@end
