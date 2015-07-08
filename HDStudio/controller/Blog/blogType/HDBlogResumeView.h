//
//  HDBlogResumeView.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBlogResumeView : UIView

@property (nonatomic, strong) HDBlogInfo *blogInfo;

@property (strong) IBOutlet UILabel *lb_title;
@property (strong) IBOutlet UILabel *lb_subscribe;

@end
