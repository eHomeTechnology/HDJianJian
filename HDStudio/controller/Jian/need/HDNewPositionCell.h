//
//  HDNewPositionCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDNewPositionCell : UITableViewCell

@property (strong) IBOutlet UILabel         *lb_title;
@property (strong) IBOutlet UITextField     *tf_content;
@property (strong) IBOutlet UIImageView     *imv_icon;
@property (strong) IBOutlet UIView          *v_line;
@property (strong) IBOutlet UIView          *v_lineTrailing;
@property (strong) IBOutlet NSLayoutConstraint *lc_titleWith;
@property (strong) IBOutlet UIButton        *btn_icon;

+ (HDNewPositionCell *)getNewPositionCell;
@end

@interface HDPositionDescCell : UITableViewCell
@property (strong) IBOutlet UITextView  *tv;
+ (HDPositionDescCell *)getPositionDescCell;
@end

@interface HDPositionPhotoCell : UITableViewCell

@property (strong) IBOutlet UIButton        *btn_addScene;
@property (strong) IBOutlet UIImageView     *imv_scene0;
@property (strong) IBOutlet UIImageView     *imv_scene1;
@property (strong) IBOutlet UIImageView     *imv_scene2;
@property (strong) IBOutlet UIImageView     *imv_scene3;

@property (strong) IBOutlet UIButton        *btn_delete0;
@property (strong) IBOutlet UIButton        *btn_delete1;
@property (strong) IBOutlet UIButton        *btn_delete2;
@property (strong) IBOutlet UIButton        *btn_delete3;

@property (weak) IBOutlet NSLayoutConstraint    *lc_addLeadingScene;
+ (HDPositionPhotoCell *)getPhotoDescCell;

@end

@interface HDEmployeeListCell : UITableViewCell

@property (strong) IBOutlet UILabel  *lb_name;
@property (strong) IBOutlet UILabel  *lb_business;
@property (strong) IBOutlet UILabel  *lb_property;
@property (strong) IBOutlet UIButton *btn_choose;

@property (nonatomic, strong) HDEmployerInfo *employerInfo;

+ (HDEmployeeListCell *)getEmployeeCell;
@end

