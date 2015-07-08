//
//  HDProfileViewCtr.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDIndexPathTextField : UITextField

@property (strong) NSIndexPath *indexPath;

@end

@interface HDJianIntroCell : UITableViewCell

@property (strong) IBOutlet UITextView *tv;
@end

@interface HDProfileCell : UITableViewCell
@property (strong) IBOutlet UILabel      *lb_title;
@property (strong) IBOutlet HDIndexPathTextField  *tf_value;
@property (strong) IBOutlet UIButton     *btn_pullDown;
@property (strong) IBOutlet UILabel      *lb_nian;
+ (HDProfileCell *)getCell;

@end

@interface HDProfileViewCtr : UIViewController

@end
