//
//  HDShowPositonCell.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDPositionTitleCell : UITableViewCell

@property (strong) IBOutlet UITextField     *tf_title;

@end

@interface HDPositionDescribeCell : UITableViewCell

@property (strong)  IBOutlet UITextView             *tv_positonDesc;
@property (weak)    IBOutlet NSLayoutConstraint     *lc_positionDescHeight;
@property (strong)  IBOutlet UILabel                *lb_placeholder;

@end

@interface HDPositionEnterpriceCell : UITableViewCell

@property (strong) IBOutlet UITextView          *tv_enterpriceDesc;
@property (weak)   IBOutlet NSLayoutConstraint  *lc_enterpriceDescHeight;
@property (strong) IBOutlet UILabel             *lb_placeholder;

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

@end
