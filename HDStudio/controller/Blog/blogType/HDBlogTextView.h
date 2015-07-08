//
//  HDBlogTextView.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDBlogInfo.h"

@interface HDBlogTextView : UIView

@property (strong) IBOutlet UILabel *lb_text;
@property (strong) IBOutlet UIImageView *imv0;
@property (strong) IBOutlet UIImageView *imv1;
@property (strong) IBOutlet UIImageView *imv2;

@property (nonatomic, strong) HDBlogInfo        *blogInfo;
@property (strong) IBOutlet NSLayoutConstraint  *lc_textHeight;

+ (CGFloat)heightOfTextView:(HDBlogInfo *)blog;
@end
