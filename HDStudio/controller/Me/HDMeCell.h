//
//  HDMeCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDIndexButton.h"

@interface HDMeCell : UITableViewCell

@property (strong) IBOutlet UIImageView *imv_icon;
@property (strong) IBOutlet UILabel     *lb_title;
@property (strong) IBOutlet UILabel     *lb_subTitle;
@property (strong) IBOutlet UILabel     *lb_number0;
@property (strong) IBOutlet UILabel     *lb_number1;
@property (strong) IBOutlet UILabel     *lb_number2;
@property (strong) IBOutlet UILabel     *lb_number3;
@property (strong) IBOutlet UILabel     *lb_text0;
@property (strong) IBOutlet UILabel     *lb_text1;
@property (strong) IBOutlet UILabel     *lb_text2;
@property (strong) IBOutlet UILabel     *lb_text3;
@property (strong) IBOutlet UIImageView *imv_reward;
@property (strong) IBOutlet HDIndexButton    *btn_subTitle;
@property (strong) IBOutlet HDIndexButton    *btn_0;
@property (strong) IBOutlet HDIndexButton    *btn_1;
@property (strong) IBOutlet HDIndexButton    *btn_2;
@property (strong) IBOutlet HDIndexButton    *btn_3;

@property (strong) IBOutlet UIView      *v_line1;
@property (strong) IBOutlet UIView      *v_line2;
@property (strong) IBOutlet NSLayoutConstraint *lc_widthTextLabel2;
@property (strong) IBOutlet NSLayoutConstraint *lc_widthTextLabel3;
@property (strong) IBOutlet NSLayoutConstraint *lc_widthNumber2;
@property (nonatomic, strong) NSIndexPath       *indexPath;
@property (nonatomic, strong) HDMyJianJianInfo  *myJianJianInfo;

+ (HDMeCell *)getCell;
@end


@interface HDOpinionCell : UITableViewCell

+ (HDOpinionCell *)getOpinionCell;

@end