//
//  HDApproveCell.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDIndexTextField : UITextField

@property (strong) NSIndexPath *indexPath;

@end

@interface HDSimpleEnterCell : UITableViewCell

@property (strong) IBOutlet HDIndexTextField *tf_title;
+ (HDSimpleEnterCell *)getCell;

@end

@interface HDAddPictureCell : UITableViewCell

@property (strong) IBOutlet NSLayoutConstraint *lc_addLeadiing;
@property (strong) IBOutlet UIImageView    *imv0;
@property (strong) IBOutlet UIImageView    *imv1;
@property (strong) IBOutlet UIImageView    *imv2;
@property (strong) IBOutlet UIButton       *btn_delet0;
@property (strong) IBOutlet UIButton       *btn_delet1;
@property (strong) IBOutlet UIButton       *btn_delet2;
@property (strong) IBOutlet UIButton       *btn_add;

@property (nonatomic, strong) NSMutableArray *mar_images;
+ (HDAddPictureCell *)getCell;
@end

@interface HDApproveCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_title;
@property (strong) IBOutlet UILabel *lb_subTitle;
@property (strong) IBOutlet UILabel *lb_status;
@property (strong) IBOutlet UILabel *lb_remark;

@property (nonatomic, strong) HDApproveInfo     *approveInfo;
@property (strong) IBOutlet NSLayoutConstraint  *lc_heightRemark;
+ (HDApproveCell *)getCell;
@end
