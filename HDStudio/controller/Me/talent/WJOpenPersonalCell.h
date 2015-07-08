//
//  WJOpenPersonalCell.h
//  JianJian
//
//  Created by liudu on 15/6/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJOpenPersonalCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UITextField *tf_content;
@property (strong) IBOutlet UIImageView *img_down;
@property (strong) IBOutlet UILabel     *lb_money;

+ (WJOpenPersonalCell *)getOpenPersonalCell;
@end

@interface WJOpenPersonalCell0 : UITableViewCell

@property (strong) IBOutlet UILabel *lb_name;
@property (strong) IBOutlet UILabel *lb_message;
@property (strong) IBOutlet UILabel *lb_position;

+ (WJOpenPersonalCell0 *)getOpenPersonalCell0;
@end