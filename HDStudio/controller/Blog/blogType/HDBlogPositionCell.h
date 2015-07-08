//
//  HDBlogPositionCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBlogPositionCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_positionName;
@property (strong) IBOutlet UILabel     *lb_subscribe;
@property (strong) IBOutlet UIImageView *imv0;
@property (strong) IBOutlet UIImageView *imv1;
@property (strong) IBOutlet UIImageView *imv2;
@property (strong) IBOutlet UIImageView *imv_shang;
@property (strong) IBOutlet UILabel     *lb_reward;
@property (strong) IBOutlet NSLayoutConstraint *lc_rewardWidth;
+ (HDBlogPositionCell *)getBlogPositionCell;
@end
