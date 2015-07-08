//
//  HDCandidateCell.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDNoRecommendCell : UITableViewCell

@end

@interface HDRecommendCell : UITableViewCell

@property (strong) IBOutlet UILabel     *lb_Name;
@property (strong) IBOutlet UILabel     *lb_curPstiNCmp;
@property (strong) IBOutlet UILabel     *lb_refereeName;
@property (strong) IBOutlet UILabel     *lb_matchCount;
@property (strong) IBOutlet UILabel     *lb_createdTime;

@property (strong) IBOutlet UIButton    *btn_copyIcon;
@property (strong) IBOutlet UIButton    *btn_copyText;
@property (strong) IBOutlet UIButton    *btn_shareIcon;
@property (strong) IBOutlet UIButton    *btn_shareText;

@end
