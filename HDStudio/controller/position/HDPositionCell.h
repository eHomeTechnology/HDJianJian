//
//  HDPositionCell.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDPositionCell : UITableViewCell

@property (strong) IBOutlet UIImageView     *imv_head;
@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UILabel         *lb_Hit;
@property (strong) IBOutlet UILabel         *lb_upcount;
@property (strong) IBOutlet UILabel         *lb_publishTime;
@property (strong) IBOutlet UIButton        *btn_preview;
@property (strong) IBOutlet UIButton        *btn_copy;
@property (strong) IBOutlet UIButton        *btn_share;
@property (strong) IBOutlet UIButton        *btn_goRecommend;
@end

@interface HDNoPositionCell : UITableViewCell

@property (strong) IBOutlet UIButton     *btn_add;

@end