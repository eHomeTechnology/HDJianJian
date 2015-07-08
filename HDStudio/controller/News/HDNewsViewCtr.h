//
//  HDNewsViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "HDNewsInfo.h"
#import "HDTableView.h"

@interface HDNewsCell : UITableViewCell

@property (strong) IBOutlet UIImageView     *imv_head;
@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UILabel         *lb_value;
@property (strong) IBOutlet UILabel         *lb_time;
@property (strong) IBOutlet UIView          *v_redDot;

@property (nonatomic, strong) HDSubscriberInfo *subscriberInfo;
+ (HDNewsCell *)getCell;
@end

@interface HDNewsViewCtr : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EGORefreshTableDelegate>

@property (strong) IBOutlet HDTableView *tbv;
@property (strong) NSMutableArray   *mar_subscribers;

@end
