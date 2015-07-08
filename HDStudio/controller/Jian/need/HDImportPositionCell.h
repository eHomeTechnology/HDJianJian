//
//  HDImportPositionCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDImportPositionCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_positionName;
@property (strong) IBOutlet UILabel     *lb_education;
@property (strong) IBOutlet UILabel     *lb_ageLimit;
@property (strong) IBOutlet UILabel     *lb_locus;
@property (strong) IBOutlet UILabel     *lb_times;
@property (strong) IBOutlet UIButton    *btn_select;
+ (HDImportPositionCell *)getImportPositionCell;

@end
