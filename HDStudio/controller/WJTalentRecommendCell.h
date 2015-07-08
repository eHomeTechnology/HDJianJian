//
//  WJTalentRecommendCell.h
//  JianJian
//
//  Created by liudu on 15/5/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJTalentRecommendCell : UITableViewCell
@property (strong) IBOutlet UILabel *lb_business;
@property (strong) IBOutlet UILabel *lb_position;
@property (strong) IBOutlet UILabel *lb_workPlace;

@property (strong, nonatomic) IBOutlet UILabel *lb_businessContent;
@property (strong, nonatomic) IBOutlet UILabel *lb_positionContent;
@property (strong, nonatomic) IBOutlet UILabel *lb_workPlaceContent;



+ (WJTalentRecommendCell *)getTalentRecommendCell;
@end
