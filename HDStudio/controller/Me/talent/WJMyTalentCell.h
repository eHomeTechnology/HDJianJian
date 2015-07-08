//
//  WJMyTalentCell.h
//  JianJian
//
//  Created by liudu on 15/6/10.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJMyTalentCell : UITableViewCell

@property (strong) IBOutlet UIImageView *img_head;
@property (strong) IBOutlet UILabel     *lb_name;
@property (strong) IBOutlet UILabel     *lb_message;
@property (strong) IBOutlet UILabel     *lb_curPosition;
@property (strong) IBOutlet UILabel     *lb_progressState;
@property (strong) IBOutlet UIButton    *btn_progressState;
@property (strong) IBOutlet NSLayoutConstraint *lc_progressState;

+ (WJMyTalentCell *)getMyTalentCell;
@end
