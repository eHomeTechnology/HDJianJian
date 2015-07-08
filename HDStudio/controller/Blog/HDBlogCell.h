//
//  HDBlogCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJBrokerInfo.h"
#import "HDBlogPositionView.h"
#import "HDIndexButton.h"

@class HDBlogCell;
@protocol HDBlogCellDelegate <NSObject>

- (void)blogCell:(HDBlogCell *)blogCell;
@end

@interface HDBlogCell : UITableViewCell <HDBlogPositionViewDelegate>

@property (strong) IBOutlet UILabel  *lb_name;
@property (strong) IBOutlet UILabel  *lb_time;
@property (strong) IBOutlet UILabel  *lb_collectCount;
@property (strong) IBOutlet UIView   *v_content;
@property (strong) IBOutlet UILabel  *lb_top;
@property (strong) IBOutlet HDIndexButton   *btn_avatar;
@property (strong) IBOutlet HDIndexButton   *btn_collect;
@property (strong) IBOutlet HDIndexButton   *btn_chat;
@property (strong) IBOutlet HDIndexButton   *btn_chatTex;;
@property (strong) IBOutlet HDIndexButton   *btn_payAttention;
@property (strong) IBOutlet NSLayoutConstraint *lc_topHeight;
@property (assign) BOOL                     isExtended;
@property (strong) NSIndexPath              *indexPath;
@property (assign) id <HDBlogCellDelegate>  delegate;

@property (nonatomic, strong) HDBlogInfo    *blogInfo;

+ (HDBlogCell *)getBlogCell;

@end


@interface HDBrokerCell : UITableViewCell

@property (strong) IBOutlet HDIndexButton *btn_avatar;
@property (strong) IBOutlet UILabel  *lb_name;
@property (strong) IBOutlet UILabel  *lb_position;
@property (strong) IBOutlet UILabel  *lb_company;
@property (strong) IBOutlet HDIndexButton   *btn_payAttention;
@property (nonatomic, strong) WJBrokerInfo  *brokerInfo;

+ (HDBrokerCell *)getBrokerCell;

@end






