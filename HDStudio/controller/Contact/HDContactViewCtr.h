//
//  HDContactViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDContactCell : UITableViewCell

@property (strong) IBOutlet UIImageView *imv_head;
@property (strong) IBOutlet UILabel     *lb_title;
+ (HDContactCell *)getCell;

@end

@interface HDContactViewCtr : UIViewController

- (id)initWithSharePosition:(WJPositionInfo *)position;

@end
