//
//  HDMyPositionCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDMyPositionCell : UITableViewCell

@property (strong) IBOutlet UIImageView     *imv_head;
@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UILabel         *lb_hit;
@property (strong) IBOutlet UILabel         *lb_recommend;
@property (strong) IBOutlet UILabel         *lb_time;
//@property (strong) IBOutlet CELLButton      *btn_preview;
//@property (strong) IBOutlet CELLButton      *btn_edit;
//@property (strong) IBOutlet CELLButton      *btn_share;
//@property (strong) IBOutlet CELLButton      *btn_unshelve;
//@property (strong) IBOutlet CELLButton      *btn_recommend;

@end

@interface HDOffPositionCell : UITableViewCell

@property (strong) IBOutlet UIImageView     *imv_head;
@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UILabel         *lb_hit;
@property (strong) IBOutlet UILabel         *lb_recommend;
@property (strong) IBOutlet UILabel         *lb_time;
//@property (strong) IBOutlet CELLButton      *btn_preview;
//@property (strong) IBOutlet CELLButton      *btn_reshelve;
//@property (strong) IBOutlet CELLButton      *btn_recommend;

@end

