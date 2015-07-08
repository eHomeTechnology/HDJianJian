//
//  WJBrokerMessageCell.h
//  JianJian
//
//  Created by liudu on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBrokerMessageCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UITextField *tf_content;
@property (strong) IBOutlet UIImageView *img_down;
@property (strong) IBOutlet UIView      *v_line;
@property (strong) IBOutlet UITextField *tf_introduction;

+ (WJBrokerMessageCell *)getBrokerMessageCell;
@end


@interface WJBrokerMessageCell0 : UITableViewCell

@property (strong) IBOutlet UITextView *tv_content;

+ (WJBrokerMessageCell0 *)getBrokerMessageCell0;
@end